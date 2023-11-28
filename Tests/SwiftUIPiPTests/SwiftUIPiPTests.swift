import XCTest
@testable import SwiftUIPiP

final class SwiftUIPiPTests: XCTestCase {
    func testNumericLimits() {
        XCTAssertEqual(3.min(4), 4)
        XCTAssertEqual(3.min(3), 3)
        XCTAssertEqual(3.min(2), 3)
        
        XCTAssertEqual(3.max(4), 3)
        XCTAssertEqual(3.max(3), 3)
        XCTAssertEqual(3.max(2), 2)
        
        XCTAssertEqual(3.between(2...4), 3)
        XCTAssertEqual(3.between(4...6), 4)
        XCTAssertEqual(3.between(0...2), 2)
    }
    
    func testClosest() {
        XCTAssertEqual(3.closest(of: 2...10), 2)
        XCTAssertEqual(9.closest(of: 2...10), 10)
    }
}
