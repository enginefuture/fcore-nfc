import CoreNFC
import XCTest
@testable import FCoreNFC

final class NDEFPayloadDecoderTests: XCTestCase {
    func testDecodesUTF8TextRecord() {
        let payload = NFCNDEFPayload(
            format: .nfcWellKnown,
            type: Data([0x54]),
            identifier: Data(),
            payload: Data([0x02]) + Data("zh你好".utf8)
        )

        XCTAssertEqual(NDEFPayloadDecoder.decodedValue(from: payload), "你好")
    }

    func testDecodesURIRecord() {
        let payload = NFCNDEFPayload(
            format: .nfcWellKnown,
            type: Data([0x55]),
            identifier: Data(),
            payload: Data([0x04]) + Data("example.com".utf8)
        )

        XCTAssertEqual(NDEFPayloadDecoder.decodedValue(from: payload), "https://example.com")
    }

    func testHexEncodingUsesUppercaseAndLeadingZeroes() {
        XCTAssertEqual(Data([0x00, 0x0A, 0xFF]).hexadecimalString, "000AFF")
    }
}

