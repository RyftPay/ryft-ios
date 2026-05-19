import UIKit
import RyftCore
import RyftUI

final class MockRyftThreeDsActionHandler: RyftThreeDsActionHandler {

    var error: Error?

    func createTransaction(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Result<ThreeDsTransactionParams, Error>) -> Void
    ) {
        if let error = error {
            completion(.failure(error))
            return
        }
        completion(.success(ThreeDsTransactionParams(
            sdkTransactionId: "mock_txn",
            sdkApplicationId: "mock_app",
            sdkEncryptedData: "mock_enc",
            sdkEphemeralPublicKey: "mock_epk",
            sdkReferenceNumber: "mock_ref"
        )))
    }

    func doChallenge(
        action: ChallengeAction,
        presentingViewController: UIViewController,
        completion: @escaping (ThreeDsChallengeResult) -> Void
    ) {
        let alertVC = UIAlertController(
            title: "3DS Challenge",
            message: "[TEST] challenge page",
            preferredStyle: .alert
        )
        alertVC.addAction(UIAlertAction(title: "Fail", style: .cancel) { _ in
            completion(.failed(message: "User failed challenge"))
        })
        alertVC.addAction(UIAlertAction(title: "Pass", style: .default) { _ in
            completion(.completed(
                transactionStatus: "Y",
                threeDSServerTransactionId: action.threeDSServerTransactionId
            ))
        })
        presentingViewController.present(alertVC, animated: true)
    }

    func cleanup() {}
}
