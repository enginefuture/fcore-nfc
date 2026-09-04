import Foundation

struct TransitCardDetails: Codable, Equatable {
    let schemeName: String
    let applicationIdentifier: String
    let balanceMinorUnits: Int64?
    let currencyCode: String

    var formattedBalance: String? {
        guard let balanceMinorUnits else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: NSDecimalNumber(value: Double(balanceMinorUnits) / 100))
    }
}

