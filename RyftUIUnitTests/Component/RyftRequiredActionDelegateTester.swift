import RyftCore
import RyftUI

final class RyftRequiredActionDelegateTester: RyftRequiredActionDelegate {

    var inProgress = false
    var result: RyftRequiredActionResult?
    var challengeError: RyftThreeDsError?
    var onHandled: (() -> Void)?

    func onRequiredActionInProgress() {
        inProgress = true
    }

    func onRequiredActionHandled(result: RyftRequiredActionResult) {
        self.result = result
        onHandled?()
    }

    func onRequiredActionChallengeFailed(error: RyftThreeDsError) {
        challengeError = error
    }
}
