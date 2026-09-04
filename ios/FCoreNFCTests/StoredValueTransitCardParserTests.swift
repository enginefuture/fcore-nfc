import XCTest
@testable import FCoreNFC

final class StoredValueTransitCardParserTests: XCTestCase {
    func testParsesTUnionBalanceInMinorUnits() async {
        let transport = MockISO7816Transceiver(responses: [
            ISO7816Response(data: Data(), statusWord1: 0x90, statusWord2: 0x00),
            ISO7816Response(data: Data([0x00, 0x00, 0x11, 0xF8]), statusWord1: 0x90, statusWord2: 0x00)
        ])

        let details = await StoredValueTransitCardParser().parse(
            using: transport,
            initiallySelectedApplicationIdentifier: "A000000632010105"
        )

        XCTAssertEqual(details?.schemeName, "交通联合 · AID 010105")
        XCTAssertEqual(details?.balanceMinorUnits, 4_600)
        XCTAssertEqual(details?.currencyCode, "CNY")
    }

    func testTriesNextKnownApplicationWhenSelectionFails() async {
        let transport = MockISO7816Transceiver(responses: [
            ISO7816Response(data: Data(), statusWord1: 0x6A, statusWord2: 0x82),
            ISO7816Response(data: Data(), statusWord1: 0x90, statusWord2: 0x00),
            ISO7816Response(data: Data([0x00, 0x00, 0x00, 0x64]), statusWord1: 0x90, statusWord2: 0x00)
        ])

        let details = await StoredValueTransitCardParser().parse(
            using: transport,
            initiallySelectedApplicationIdentifier: nil
        )

        XCTAssertEqual(details?.schemeName, "交通联合 · AID 010106")
        XCTAssertEqual(details?.balanceMinorUnits, 100)
    }
}
