@testable import MessagePack
import XCTest

class DescriptionTests: XCTestCase {
    func testNilDescription() {
        XCTAssertEqual(MessagePackValue.Nil.description, "nil")
    }

    func testBoolDescription() {
        XCTAssertEqual(MessagePackValue.Bool(true).description, "true")
        XCTAssertEqual(MessagePackValue.Bool(false).description, "false")
    }

    func testIntDescription() {
        XCTAssertEqual(MessagePackValue.Int(-1).description, "-1")
        XCTAssertEqual(MessagePackValue.Int(0).description, "0")
        XCTAssertEqual(MessagePackValue.Int(1).description, "1")
    }

    func testUIntDescription() {
        XCTAssertEqual(MessagePackValue.UInt(0).description, "0")
        XCTAssertEqual(MessagePackValue.UInt(1).description, "1")
        XCTAssertEqual(MessagePackValue.UInt(2).description, "2")
    }

    func testFloatDescription() {
        XCTAssertEqual(MessagePackValue.Float(0.0).description, "0.0")
        XCTAssertEqual(MessagePackValue.Float(1.618).description, "1.618")
        XCTAssertEqual(MessagePackValue.Float(3.14).description, "3.14")
    }

    func testDoubleDescription() {
        XCTAssertEqual(MessagePackValue.Double(0.0).description, "0.0")
        XCTAssertEqual(MessagePackValue.Double(1.618).description, "1.618")
        XCTAssertEqual(MessagePackValue.Double(3.14).description, "3.14")
    }

    func testStringDescription() {
        XCTAssertEqual(MessagePackValue.String("").description, "\"\"")
        XCTAssertEqual(MessagePackValue.String("MessagePack").description, "\"MessagePack\"")
    }

    func testBinaryDescription() {
        XCTAssertEqual(MessagePackValue.Binary([]).description, "[]")
        XCTAssertEqual(MessagePackValue.Binary([0x00, 0x01, 0x02, 0x03, 0x04]).description, "[0x00, 0x01, 0x02, 0x03, 0x04]")
    }

    func testArrayDescription() {
        let values: [MessagePackValue] = [1, true, ""]
        XCTAssertEqual(MessagePackValue.Array(values).description, "[1, true, \"\"]")
    }

    func testMapDescription() {
        let values: [MessagePackValue : MessagePackValue] = [
            "a": "apple",
            "b": "banana",
            "c": "cookie",
        ]

        let components = [
            "\"a\": \"apple\"",
            "\"b\": \"banana\"",
            "\"c\": \"cookie\"",
        ]

        let indexPermutations: [[Int]] = [
            [0, 1, 2],
            [0, 2, 1],
            [1, 0, 2],
            [1, 2, 0],
            [2, 0, 1],
            [2, 1, 0],
        ]

        let description = MessagePackValue.Map(values).description

        var isValid = false
        for indices in indexPermutations {
            let innerDescription = "\(components[indices[0]]), \(components[indices[1]]), \(components[indices[2]])"
            if description == "[\(innerDescription)]" {
                isValid = true
                break
            }
        }

        XCTAssertTrue(isValid)
    }

    func testExtendedDescription() {
        XCTAssertEqual(MessagePackValue.Extended(5, []).description, "Extended(5, [])")
        XCTAssertEqual(MessagePackValue.Extended(5, [0x00, 0x10, 0x20, 0x30, 0x40]).description, "Extended(5, [0x00, 0x10, 0x20, 0x30, 0x40])")
    }
}
