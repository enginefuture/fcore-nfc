import Foundation

struct StoredValueTransitCardParser {
    private struct Application {
        let schemeName: String
        let applicationIdentifier: Data
    }

    private static let applications = [
        Application(
            schemeName: "交通联合 · AID 010105",
            applicationIdentifier: Data([0xA0, 0x00, 0x00, 0x06, 0x32, 0x01, 0x01, 0x05])
        ),
        Application(
            schemeName: "交通联合 · AID 010106",
            applicationIdentifier: Data([0xA0, 0x00, 0x00, 0x06, 0x32, 0x01, 0x01, 0x06])
        ),
        Application(
            schemeName: "City Union 城市一卡通",
            applicationIdentifier: Data([0xA0, 0x00, 0x00, 0x00, 0x03, 0x86, 0x98, 0x07, 0x01])
        )
    ]

    func parse(
        using transceiver: ISO7816Transceiving,
        initiallySelectedApplicationIdentifier: String?
    ) async -> TransitCardDetails? {
        let exchange = ISO7816Exchange(transceiver: transceiver)
        let candidates = orderedApplications(initiallySelectedApplicationIdentifier)

        for application in candidates {
            do {
                let selection = try await exchange.send(
                    .select(applicationIdentifier: application.applicationIdentifier)
                )
                guard selection.isSuccess else { continue }

                let balanceResponse = try? await exchange.send(.getStoredValueBalance)
                return TransitCardDetails(
                    schemeName: application.schemeName,
                    applicationIdentifier: application.applicationIdentifier.hexadecimalString,
                    balanceMinorUnits: balance(from: balanceResponse),
                    currencyCode: "CNY"
                )
            } catch {
                continue
            }
        }

        return nil
    }

    private func orderedApplications(_ initialIdentifier: String?) -> [Application] {
        guard let initialIdentifier else { return Self.applications }
        let normalized = initialIdentifier.uppercased()
        return Self.applications.sorted {
            ($0.applicationIdentifier.hexadecimalString == normalized ? 0 : 1) <
            ($1.applicationIdentifier.hexadecimalString == normalized ? 0 : 1)
        }
    }

    private func balance(from response: ISO7816Response?) -> Int64? {
        guard let response, response.isSuccess, response.data.count == 4 else { return nil }
        return response.data.reduce(0) { partial, byte in
            partial << 8 | Int64(byte)
        }
    }
}
