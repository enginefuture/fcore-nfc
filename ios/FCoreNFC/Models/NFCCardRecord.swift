import Foundation

enum NFCTechnology: String, Codable, CaseIterable {
    case iso7816 = "ISO 7816"
    case iso15693 = "ISO 15693"
    case feliCa = "FeliCa"
    case miFare = "MIFARE"

    var systemImage: String {
        switch self {
        case .iso7816: "creditcard"
        case .iso15693: "dot.radiowaves.left.and.right"
        case .feliCa: "tram"
        case .miFare: "key"
        }
    }
}

struct NDEFRecordSnapshot: Codable, Equatable, Identifiable {
    let id: UUID
    let typeNameFormat: UInt8
    let typeHex: String
    let identifierHex: String
    let payloadHex: String
    let decodedValue: String?

    init(
        id: UUID = UUID(),
        typeNameFormat: UInt8,
        typeHex: String,
        identifierHex: String,
        payloadHex: String,
        decodedValue: String?
    ) {
        self.id = id
        self.typeNameFormat = typeNameFormat
        self.typeHex = typeHex
        self.identifierHex = identifierHex
        self.payloadHex = payloadHex
        self.decodedValue = decodedValue
    }
}

struct NFCCardRecord: Codable, Equatable, Identifiable {
    let id: UUID
    let scannedAt: Date
    let technology: NFCTechnology
    let identifierHex: String
    let metadata: [String: String]
    let ndefRecords: [NDEFRecordSnapshot]

    init(
        id: UUID = UUID(),
        scannedAt: Date = Date(),
        technology: NFCTechnology,
        identifierHex: String,
        metadata: [String: String] = [:],
        ndefRecords: [NDEFRecordSnapshot] = []
    ) {
        self.id = id
        self.scannedAt = scannedAt
        self.technology = technology
        self.identifierHex = identifierHex
        self.metadata = metadata
        self.ndefRecords = ndefRecords
    }
}

extension Data {
    var hexadecimalString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}

