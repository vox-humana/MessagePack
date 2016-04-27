#if os(Linux)

import XCTest
@testable import MessagePackTestSuite

XCTMain([
    testCase(MessagePackTests.allTests)
])

#endif
