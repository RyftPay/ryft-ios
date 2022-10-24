import RyftCore
import RyftUI

final class MockRyftThreeDsActionHandler: RyftThreeDsActionHandler {

    var action: RequiredActionIdentifyApp?
    var handleInvoked = false
    var error: Error?

    func handle(action: RequiredActionIdentifyApp, completion: @escaping (Error?) -> Void) {
        self.action = action
        handleInvoked = true
        completion(error)
    }
}
