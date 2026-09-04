import CoreNFC
import Foundation

enum NDEFPayloadDecoder {
    static func snapshot(from payload: NFCNDEFPayload) -> NDEFRecordSnapshot {
        NDEFRecordSnapshot(
            typeNameFormat: payload.typeNameFormat.rawValue,
            typeHex: payload.type.hexadecimalString,
            identifierHex: payload.identifier.hexadecimalString,
            payloadHex: payload.payload.hexadecimalString,
            decodedValue: decodedValue(from: payload)
        )
    }

    static func decodedValue(from payload: NFCNDEFPayload) -> String? {
        guard payload.typeNameFormat == .nfcWellKnown else {
            return String(data: payload.payload, encoding: .utf8)
        }

        if payload.type == Data([0x54]) {
            return decodeText(payload.payload)
        }

        if payload.type == Data([0x55]) {
            return decodeURI(payload.payload)
        }

        return nil
    }

    private static func decodeText(_ data: Data) -> String? {
        guard let status = data.first else { return nil }
        let languageLength = Int(status & 0x3F)
        let textStart = 1 + languageLength
        guard data.count >= textStart else { return nil }

        let encoding: String.Encoding = status & 0x80 == 0 ? .utf8 : .utf16
        return String(data: data.dropFirst(textStart), encoding: encoding)
    }

    private static func decodeURI(_ data: Data) -> String? {
        guard let prefixCode = data.first else { return nil }
        let prefixes = [
            "", "http://www.", "https://www.", "http://", "https://",
            "tel:", "mailto:", "ftp://anonymous:anonymous@", "ftp://ftp.",
            "ftps://", "sftp://", "smb://", "nfs://", "ftp://", "dav://",
            "news:", "telnet://", "imap:", "rtsp://", "urn:", "pop:",
            "sip:", "sips:", "tftp:", "btspp://", "btl2cap://", "btgoep://",
            "tcpobex://", "irdaobex://", "file://", "urn:epc:id:",
            "urn:epc:tag:", "urn:epc:pat:", "urn:epc:raw:", "urn:epc:", "urn:nfc:"
        ]
        let prefix = Int(prefixCode) < prefixes.count ? prefixes[Int(prefixCode)] : ""
        guard let remainder = String(data: data.dropFirst(), encoding: .utf8) else { return nil }
        return prefix + remainder
    }
}

