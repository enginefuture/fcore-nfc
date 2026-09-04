import XCTest
@testable import FCoreNFC

final class ISO7816ExchangeTests: XCTestCase {
    func testSelectCommandEncoding() {
        let aid = Data([0xA0, 0x00, 0x00, 0x06, 0x32, 0x01, 0x01, 0x05])
        let command = ISO7816Command.select(applicationIdentifier: aid)

        XCTAssertEqual(command.encoded.hexadecimalString, "00A4040008A00000063201010500")
    }

    func testCorrectsLengthAfter6CResponse() async throws {
        let transport = MockISO7816Transceiver(responses: [
            ISO7816Response(data: Data(), statusWord1: 0x6C, statusWord2: 0x04),
            ISO7816Response(data: Data([0, 0, 0, 1]), statusWord1: 0x90, statusWord2: 0x00)
        ])

        let response = try await ISO7816Exchange(transceiver: transport).send(.getStoredValueBalance)

        XCTAssertEqual(response.data, Data([0, 0, 0, 1]))
        XCTAssertEqual(transport.commands.map(\.expectedResponseLength), [4, 4])
    }

    func testCollectsGetResponseData() async throws {
        let transport = MockISO7816Transceiver(responses: [
            ISO7816Response(data: Data([0x01]), statusWord1: 0x61, statusWord2: 0x02),
            ISO7816Response(data: Data([0x02, 0x03]), statusWord1: 0x90, statusWord2: 0x00)
        ])

        let response = try await ISO7816Exchange(transceiver: transport).send(.getStoredValueBalance)

        XCTAssertEqual(response.data, Data([0x01, 0x02, 0x03]))
        XCTAssertEqual(transport.commands.last?.instructionCode, 0xC0)
    }
}

final class MockISO7816Transceiver: ISO7816Transceiving {
    private(set) var commands: [ISO7816Command] = []
    private var responses: [ISO7816Response]

    init(responses: [ISO7816Response]) {
        self.responses = responses
    }

    func transmit(_ command: ISO7816Command) async throws -> ISO7816Response {
        commands.append(command)
        return responses.removeFirst()
    }
}

