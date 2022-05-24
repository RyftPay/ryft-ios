import XCTest

extension XCUIElement {

    func forceTap() {
        if isHittable {
            tap()
            return
        }
        self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
}
