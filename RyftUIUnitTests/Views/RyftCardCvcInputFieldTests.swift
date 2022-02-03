import XCTest

@testable import RyftUI

final class RyftCardCvcInputFieldTests: XCTestCase {

    func test_cardType_shouldBeInitialisedtoUnknown() {
        let field = RyftCardCvcInputField()
        XCTAssertEqual(field.cardType, .unknown)
    }
}
