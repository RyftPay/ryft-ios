import RyftCore
import RyftUI

final class RyftRequiredActionDelegateTester: RyftRequiredActionDelegate {

    var inProgress = false
    var result: RyftRequiredActionResult?
    var onHandled: (() -> Void)?

    func onRequiredActionInProgress() {
        inProgress = true
    }

    func onRequiredActionHandled(result: RyftRequiredActionResult) {
        self.result = result
        onHandled?()
    }
}
