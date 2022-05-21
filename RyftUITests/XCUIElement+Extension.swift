import XCTest

extension XCUIElement {

    func forceTap() {
        self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .tap()
    }
}
