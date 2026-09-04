import XCTest
@testable import FCoreNFC

final class NFCCardRecordTests: XCTestCase {
    func testRecordRoundTripsThroughJSON() throws {
        let record = NFCCardRecord(
            technology: .iso7816,
            identifierHex: "0102AB",
            metadata: ["Selected AID": "D2760000850101"]
        )

        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(NFCCardRecord.self, from: data)

        XCTAssertEqual(decoded, record)
    }
}

