import UIKit
import RyftCore
import RyftUI

final class MockRyftThreeDsActionHandler: RyftThreeDsActionHandler {

    var action: RequiredActionIdentifyApp?
    var createTransactionInvoked = false
    var transactionResult: Result<ThreeDsTransactionParams, Error> = .failure(
        MockThreeDsError.notConfigured
    )

    var doChallengeInvoked = false
    var challengeResult: ThreeDsChallengeResult = .cancelled

    var cleanupInvoked = false

    func createTransaction(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Result<ThreeDsTransactionParams, Error>) -> Void
    ) {
        self.action = action
        createTransactionInvoked = true
        completion(transactionResult)
    }

    func doChallenge(
        action: ChallengeAction,
        presentingViewController: UIViewController,
        completion: @escaping (ThreeDsChallengeResult) -> Void
    ) {
        doChallengeInvoked = true
        completion(challengeResult)
    }

    func cleanup() {
        cleanupInvoked = true
    }
}

private enum MockThreeDsError: Error {
    case notConfigured
}
