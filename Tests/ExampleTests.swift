@testable import MessagePack
import XCTest
import Data

class ExampleTests: XCTestCase {
    let example: MessagePackValue = ["compact": true, "schema": 0]

    // Two possible "correct" values because dictionaries are unordered
    let correctA: Data = [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00]
    let correctB: Data = [0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3]

    func testPack() {
        let packed = pack(example)
        XCTAssertTrue(packed == correctA || packed == correctB)
    }

    func testUnpack() {
        let unpacked1 = try? unpack(correctA)
        XCTAssertEqual(unpacked1, example)

        let unpacked2 = try? unpack(correctB)
        XCTAssertEqual(unpacked2, example)
    }

    func testUnpackInvalidData() {
        do {
            try unpack([0xc1])
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .InvalidData)
        }
    }

    func testUnpackInsufficientData() {
        do {
            try unpack([0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61])
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .InsufficientData)
        }
    }

    func testUnpackNSData() {
        let data = correctA.withUnsafeBufferPointer { buffer in
            return Data(pointer: buffer.baseAddress, length: buffer.count)
        }

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, example)
    }

    func testUnpackInsufficientNSData() {
        let bytes: Data = [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d]
        let data = bytes.withUnsafeBufferPointer { buffer in
            return Data(pointer: buffer.baseAddress, length: buffer.count)
        }

        do {
            try unpack(data)
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .InsufficientData)
        }
    }
}
