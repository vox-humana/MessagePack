import XCTest
@testable import MessagePack

class MessagePackTests: XCTestCase {
    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is severely wrong here.")
    }
}

extension MessagePackTests {
    static var allTests: [(String, MessagePackTests -> () throws -> Void)] {
        return [
           ("testReality", testReality),
        ]
    }
}
