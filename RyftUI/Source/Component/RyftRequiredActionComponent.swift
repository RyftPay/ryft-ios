import UIKit
import RyftCore
import Foundation

public protocol RyftRequiredActionDelegate: AnyObject {

    func onRequiredActionInProgress()

    func onRequiredActionHandled(result: RyftRequiredActionResult)
}

public final class RyftRequiredActionComponent {

    public struct Configuration {

        public let clientSecret: String
        public let accountId: String?
        public let returnUrl: URL?

        public init(
            clientSecret: String,
            accountId: String? = nil,
            returnUrl: URL? = nil
        ) {
            self.clientSecret = clientSecret
            self.accountId = accountId
            self.returnUrl = returnUrl
        }
    }

    private let config: Configuration
    private let apiClient: RyftApiClient
    private let threeDsActionHandler: RyftThreeDsActionHandler

    public weak var delegate: RyftRequiredActionDelegate?

    public init(
        config: Configuration,
        apiClient: RyftApiClient
    ) {
        self.config = config
        self.apiClient = apiClient
        self.threeDsActionHandler = DefaultRyftThreeDsActionHandler(
            environment: apiClient.environment
        )
    }

    internal init(
        config: Configuration,
        apiClient: RyftApiClient,
        threeDsActionHandler: RyftThreeDsActionHandler
    ) {
        self.config = config
        self.apiClient = apiClient
        self.threeDsActionHandler = threeDsActionHandler
    }

    public func handle(
        action: PaymentSessionRequiredAction,
        presentingViewController: UIViewController
    ) {
        switch action.type {
        case .identify:
            handle(action: action.identify!, presentingViewController: presentingViewController)
        default:
            assertionFailure(
                "The requiredAction type '\(action.type)' is unsupported on iOS"
            )
        }
    }

    private func handle(
        action: RequiredActionIdentifyApp,
        presentingViewController: UIViewController
    ) {
        threeDsActionHandler.createTransaction(action: action) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.threeDsActionHandler.cleanup()
                self?.delegate?.onRequiredActionHandled(result: .failure(error))
            case .success(let params):
                self?.delegate?.onRequiredActionInProgress()

                self?.continueWithAppAuthentication(
                    params: params,
                    presentingViewController: presentingViewController
                )
            }
        }
    }

    private func continueWithAppAuthentication(
        params: ThreeDsTransactionParams,
        presentingViewController: UIViewController
    ) {
        let request = ContinuePaymentRequest.from(
            clientSecret: config.clientSecret,
            params: params
        )
        apiClient.continuePayment(
            request: request,
            accountId: config.accountId
        ) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.threeDsActionHandler.cleanup()
                self?.delegate?.onRequiredActionHandled(result: .failure(error))
            case .success(let session):
                if let challengeAction = session.requiredAction?.challenge {
                    self?.handleChallenge(
                        challengeAction: challengeAction,
                        presentingViewController: presentingViewController
                    )
                } else {
                    self?.threeDsActionHandler.cleanup()
                    self?.delegate?.onRequiredActionHandled(result: .success(session))
                }
            }
        }
    }

    private func handleChallenge(
        challengeAction: ChallengeAction,
        presentingViewController: UIViewController
    ) {
        threeDsActionHandler.doChallenge(
            action: challengeAction,
            presentingViewController: presentingViewController
        ) { [weak self] result in
            switch result {
            case let .completed(transactionStatus, threeDSServerTransactionId):
                self?.continueWithChallengeResult(
                    transactionStatus: transactionStatus,
                    threeDSServerTransactionId: threeDSServerTransactionId
                )
            case .cancelled:
                self?.threeDsActionHandler.cleanup()
                self?.delegate?.onRequiredActionHandled(result: .cancelled)
            case .failed(let error):
                self?.threeDsActionHandler.cleanup()
                self?.delegate?.onRequiredActionHandled(result: .failure(error))
            }
        }
    }

    private func continueWithChallengeResult(
        transactionStatus: String,
        threeDSServerTransactionId: String
    ) {
        let request = ContinuePaymentRequest.fromChallengeResult(
            clientSecret: config.clientSecret,
            transactionStatus: transactionStatus,
            threeDSServerTransactionId: threeDSServerTransactionId
        )
        apiClient.continuePayment(
            request: request,
            accountId: config.accountId
        ) { [weak self] result in
            self?.threeDsActionHandler.cleanup()
            switch result {
            case .success(let session):
                self?.delegate?.onRequiredActionHandled(result: .success(session))
            case .failure(let error):
                self?.delegate?.onRequiredActionHandled(result: .failure(error))
            }
        }
    }
}
