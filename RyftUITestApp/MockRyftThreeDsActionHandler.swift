import RyftCore
import RyftUI
import UIKit

final class MockRyftThreeDsActionHandler: RyftThreeDsActionHandler {

    var viewController: UIViewController?
    var error: Error?

    func handle(action: RequiredActionIdentifyApp, completion: @escaping (Error?) -> Void) {
        let threeDsView = UIAlertController(
            title: "3DS Challenge",
            message: "[TEST] challenge page",
            preferredStyle: .alert
        )
        threeDsView.addAction(UIAlertAction(title: "Fail", style: .cancel, handler: { _ in
            completion(self.error)
        }))
        threeDsView.addAction(UIAlertAction(title: "Pass", style: .default, handler: { _ in
            completion(self.error)
        }))
        viewController?.present(threeDsView, animated: true)
    }
}
