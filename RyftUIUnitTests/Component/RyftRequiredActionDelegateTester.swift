import RyftCore
import RyftUI

final class RyftRequiredActionDelegateTester: RyftRequiredActionDelegate {

    var inProgress = false
    var result: Result<PaymentSession, Error>?

    func onRequiredActionInProgress() {
        inProgress = true
    }

    func onRequiredActionHandled(result: Result<PaymentSession, Error>) {
        self.result = result
    }
}
