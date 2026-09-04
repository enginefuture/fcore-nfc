import CoreNFC
import Foundation

protocol ISO7816Transceiving: AnyObject {
    func transmit(_ command: ISO7816Command) async throws -> ISO7816Response
}

enum ISO7816ExchangeError: LocalizedError {
    case invalidCommand
    case excessiveContinuation

    var errorDescription: String? {
        switch self {
        case .invalidCommand: "无法生成有效的 ISO 7816 APDU。"
        case .excessiveContinuation: "卡片返回了过多的连续响应。"
        }
    }
}

final class CoreNFCISO7816Transceiver: ISO7816Transceiving {
    private let tag: NFCISO7816Tag

    init(tag: NFCISO7816Tag) {
        self.tag = tag
    }

    func transmit(_ command: ISO7816Command) async throws -> ISO7816Response {
        guard let apdu = NFCISO7816APDU(data: command.encoded) else {
            throw ISO7816ExchangeError.invalidCommand
        }

        return try await withCheckedThrowingContinuation { continuation in
            tag.sendCommand(apdu: apdu) { data, statusWord1, statusWord2, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(
                        returning: ISO7816Response(
                            data: data,
                            statusWord1: statusWord1,
                            statusWord2: statusWord2
                        )
                    )
                }
            }
        }
    }
}

struct ISO7816Exchange {
    let transceiver: ISO7816Transceiving

    func send(_ command: ISO7816Command) async throws -> ISO7816Response {
        var currentCommand = command
        var accumulatedData = Data()

        for _ in 0..<8 {
            let response = try await transceiver.transmit(currentCommand)

            if response.statusWord1 == 0x6C {
                accumulatedData = Data()
                let correctedLength = response.statusWord2 == 0 ? 256 : Int(response.statusWord2)
                currentCommand = command.replacingExpectedResponseLength(with: correctedLength)
                continue
            }

            accumulatedData.append(response.data)

            if response.statusWord1 == 0x61 {
                let responseLength = response.statusWord2 == 0 ? 256 : Int(response.statusWord2)
                currentCommand = .getResponse(length: responseLength)
                continue
            }

            return ISO7816Response(
                data: accumulatedData,
                statusWord1: response.statusWord1,
                statusWord2: response.statusWord2
            )
        }

        throw ISO7816ExchangeError.excessiveContinuation
    }
}

