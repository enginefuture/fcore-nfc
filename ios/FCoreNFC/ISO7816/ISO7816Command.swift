import Foundation

struct ISO7816Command: Equatable {
    let instructionClass: UInt8
    let instructionCode: UInt8
    let p1: UInt8
    let p2: UInt8
    let data: Data
    let expectedResponseLength: Int

    init(
        instructionClass: UInt8,
        instructionCode: UInt8,
        p1: UInt8,
        p2: UInt8,
        data: Data = Data(),
        expectedResponseLength: Int = -1
    ) {
        precondition(data.count <= 255, "Only short APDUs are supported in this milestone")
        precondition((-1...256).contains(expectedResponseLength), "Invalid short APDU response length")
        self.instructionClass = instructionClass
        self.instructionCode = instructionCode
        self.p1 = p1
        self.p2 = p2
        self.data = data
        self.expectedResponseLength = expectedResponseLength
    }

    static func select(applicationIdentifier: Data) -> ISO7816Command {
        ISO7816Command(
            instructionClass: 0x00,
            instructionCode: 0xA4,
            p1: 0x04,
            p2: 0x00,
            data: applicationIdentifier,
            expectedResponseLength: 256
        )
    }

    static func getResponse(length: Int) -> ISO7816Command {
        ISO7816Command(
            instructionClass: 0x00,
            instructionCode: 0xC0,
            p1: 0x00,
            p2: 0x00,
            expectedResponseLength: length
        )
    }

    static let getStoredValueBalance = ISO7816Command(
        instructionClass: 0x80,
        instructionCode: 0x5C,
        p1: 0x00,
        p2: 0x02,
        expectedResponseLength: 4
    )

    func replacingExpectedResponseLength(with length: Int) -> ISO7816Command {
        ISO7816Command(
            instructionClass: instructionClass,
            instructionCode: instructionCode,
            p1: p1,
            p2: p2,
            data: data,
            expectedResponseLength: length
        )
    }

    var encoded: Data {
        var result = Data([instructionClass, instructionCode, p1, p2])
        if !data.isEmpty {
            result.append(UInt8(data.count))
            result.append(data)
        }
        if expectedResponseLength >= 0 {
            result.append(expectedResponseLength == 256 ? 0 : UInt8(expectedResponseLength))
        }
        return result
    }
}

struct ISO7816Response: Equatable {
    let data: Data
    let statusWord1: UInt8
    let statusWord2: UInt8

    var statusWord: UInt16 {
        UInt16(statusWord1) << 8 | UInt16(statusWord2)
    }

    var isSuccess: Bool { statusWord == 0x9000 }
}

