import CoreNFC
import Foundation

final class CoreNFCReader: NSObject, NFCReading, NFCTagReaderSessionDelegate {
    private var session: NFCTagReaderSession?
    private var completion: ((Result<NFCCardRecord, NFCScanError>) -> Void)?

    var isAvailable: Bool {
        NFCTagReaderSession.readingAvailable
    }

    func beginScan(completion: @escaping (Result<NFCCardRecord, NFCScanError>) -> Void) {
        guard isAvailable else {
            completion(.failure(.unavailable))
            return
        }
        guard session == nil else {
            completion(.failure(.busy))
            return
        }

        self.completion = completion
        guard let session = NFCTagReaderSession(
            pollingOption: [.iso14443, .iso15693, .iso18092],
            delegate: self,
            queue: .main
        ) else {
            self.completion = nil
            completion(.failure(.unavailable))
            return
        }
        session.alertMessage = "将卡片靠近 iPhone 顶部，并保持不动。"
        self.session = session
        session.begin()
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: any Swift.Error) {
        self.session = nil

        let readerError = error as? CoreNFC.NFCReaderError
        if readerError?.code == .readerSessionInvalidationErrorUserCanceled {
            completion = nil
            return
        }

        finish(.failure(.readingFailed(error.localizedDescription)))
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard tags.count == 1, let tag = tags.first else {
            session.alertMessage = "检测到多张卡片，请只保留一张。"
            session.restartPolling()
            return
        }

        session.connect(to: tag) { [weak self] error in
            guard let self else { return }
            if let error {
                session.invalidate(errorMessage: "连接失败，请重新扫描。")
                self.finish(.failure(.connectionFailed(error.localizedDescription)))
                return
            }
            self.read(tag, in: session)
        }
    }

    private func read(_ tag: NFCTag, in session: NFCTagReaderSession) {
        switch tag {
        case let .iso7816(card):
            var metadata: [String: String] = [:]
            if !card.initialSelectedAID.isEmpty { metadata["Selected AID"] = card.initialSelectedAID }
            if let historicalBytes = card.historicalBytes, !historicalBytes.isEmpty {
                metadata["Historical bytes"] = historicalBytes.hexadecimalString
            }
            if let applicationData = card.applicationData, !applicationData.isEmpty {
                metadata["Application data"] = applicationData.hexadecimalString
            }
            readNDEF(from: card, technology: .iso7816, identifier: card.identifier, metadata: metadata, session: session)

        case let .iso15693(card):
            let metadata = [
                "Manufacturer code": String(format: "%02X", card.icManufacturerCode),
                "IC serial number": card.icSerialNumber.hexadecimalString
            ]
            readNDEF(from: card, technology: .iso15693, identifier: card.identifier, metadata: metadata, session: session)

        case let .feliCa(card):
            let metadata = ["System code": card.currentSystemCode.hexadecimalString]
            readNDEF(from: card, technology: .feliCa, identifier: card.currentIDm, metadata: metadata, session: session)

        case let .miFare(card):
            var metadata = ["Family": mifareFamilyName(card.mifareFamily)]
            if let historicalBytes = card.historicalBytes, !historicalBytes.isEmpty {
                metadata["Historical bytes"] = historicalBytes.hexadecimalString
            }
            readNDEF(from: card, technology: .miFare, identifier: card.identifier, metadata: metadata, session: session)

        @unknown default:
            session.invalidate(errorMessage: "暂不支持这种 NFC 标签。")
            finish(.failure(.readingFailed("未知标签类型")))
        }
    }

    private func readNDEF<Tag: NFCNDEFTag>(
        from tag: Tag,
        technology: NFCTechnology,
        identifier: Data,
        metadata: [String: String],
        session: NFCTagReaderSession
    ) {
        tag.queryNDEFStatus { [weak self] status, capacity, error in
            guard let self else { return }
            var enrichedMetadata = metadata
            enrichedMetadata["NDEF capacity"] = "\(capacity) bytes"

            guard error == nil, status != .notSupported else {
                self.completeScan(
                    NFCCardRecord(technology: technology, identifierHex: identifier.hexadecimalString, metadata: enrichedMetadata),
                    session: session
                )
                return
            }

            enrichedMetadata["NDEF access"] = status == .readWrite ? "Read / write" : "Read only"
            tag.readNDEF { message, error in
                if let error {
                    self.finish(.failure(.readingFailed(error.localizedDescription)))
                    session.invalidate(errorMessage: "无法读取 NDEF 数据。")
                    return
                }

                let records = message?.records.map(NDEFPayloadDecoder.snapshot(from:)) ?? []
                self.completeScan(
                    NFCCardRecord(
                        technology: technology,
                        identifierHex: identifier.hexadecimalString,
                        metadata: enrichedMetadata,
                        ndefRecords: records
                    ),
                    session: session
                )
            }
        }
    }

    private func completeScan(_ card: NFCCardRecord, session: NFCTagReaderSession) {
        session.alertMessage = "读取完成。"
        session.invalidate()
        finish(.success(card))
    }

    private func finish(_ result: Result<NFCCardRecord, NFCScanError>) {
        guard let completion else { return }
        self.completion = nil
        completion(result)
    }

    private func mifareFamilyName(_ family: NFCMiFareFamily) -> String {
        switch family {
        case .unknown: "Unknown"
        case .ultralight: "Ultralight"
        case .plus: "Plus"
        case .desfire: "DESFire"
        @unknown default: "Unknown"
        }
    }
}
