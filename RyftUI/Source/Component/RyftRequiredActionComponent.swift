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

        @available(*, deprecated, message: "returnUrl is ignored, no return URL is needed for native 3DS")
        public let returnUrl: URL? = nil

        public init(
            clientSecret: String,
            accountId: String? = nil
        ) {
            self.clientSecret = clientSecret
            self.accountId = accountId
        }

        @available(
            *, deprecated,
            message: "returnUrl is ignored for native 3DS. Use init(clientSecret:accountId:) instead"
        )
        public init(
            clientSecret: String,
            accountId: String? = nil,
            returnUrl: URL?
        ) {
            self.init(clientSecret: clientSecret, accountId: accountId)
        }
    }

    private struct SessionCheck {
        let paymentSessionId: String
        let threeDSServerTransactionId: String
        let fallback: RyftRequiredActionResult
        var attemptsLeft: Int
    }

    internal static let defaultSessionCheckInterval: TimeInterval = 2
    private static let sessionCheckAttempts = 15
    private static let unknownTransactionStatus = "U"

    private let config: Configuration
    private let apiClient: RyftApiClient
    private let threeDsActionHandler: RyftThreeDsActionHandler
    private let sessionCheckInterval: TimeInterval

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
        self.sessionCheckInterval = RyftRequiredActionComponent.defaultSessionCheckInterval
    }

    internal init(
        config: Configuration,
        apiClient: RyftApiClient,
        threeDsActionHandler: RyftThreeDsActionHandler,
        sessionCheckInterval: TimeInterval = RyftRequiredActionComponent.defaultSessionCheckInterval
    ) {
        self.config = config
        self.apiClient = apiClient
        self.threeDsActionHandler = threeDsActionHandler
        self.sessionCheckInterval = sessionCheckInterval
    }

    public func handle(
        action: PaymentSessionRequiredAction,
        presentingViewController: UIViewController
    ) {
        switch action.type {
        case .identify:
            guard let identifyAction = action.identify else {
                notifyFailureAsync(RyftRequiredActionError.missingIdentifyDetails)
                return
            }
            handle(action: identifyAction, presentingViewController: presentingViewController)
        default:
            notifyFailureAsync(RyftRequiredActionError.unsupportedRequiredAction(action.type))
        }
    }

    private func notifyFailureAsync(_ error: RyftRequiredActionError) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onRequiredActionHandled(result: .failure(error))
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
                        paymentSessionId: session.id,
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
        paymentSessionId: String,
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
                    threeDSServerTransactionId: threeDSServerTransactionId,
                    paymentSessionId: paymentSessionId
                )
            case .cancelled:
                self?.threeDsActionHandler.cleanup()
                self?.delegate?.onRequiredActionHandled(result: .cancelled)
            case .failed(let error):
                self?.continueWithChallengeResult(
                    transactionStatus: RyftRequiredActionComponent.unknownTransactionStatus,
                    threeDSServerTransactionId: challengeAction.threeDSServerTransactionId,
                    paymentSessionId: paymentSessionId,
                    challengeError: error
                )
            }
        }
    }

    private func continueWithChallengeResult(
        transactionStatus: String,
        threeDSServerTransactionId: String,
        paymentSessionId: String,
        challengeError: Error? = nil
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
                self?.handleChallengeResultSession(
                    session,
                    threeDSServerTransactionId: threeDSServerTransactionId
                )
            case .failure(let error):
                self?.checkSession(SessionCheck(
                    paymentSessionId: paymentSessionId,
                    threeDSServerTransactionId: threeDSServerTransactionId,
                    fallback: .failure(challengeError ?? error),
                    attemptsLeft: RyftRequiredActionComponent.sessionCheckAttempts
                ))
            }
        }
    }

    private func handleChallengeResultSession(
        _ session: PaymentSession,
        threeDSServerTransactionId: String
    ) {
        guard session.isAwaitingOutcome else {
            delegate?.onRequiredActionHandled(result: .success(session))
            return
        }
        checkSessionLater(SessionCheck(
            paymentSessionId: session.id,
            threeDSServerTransactionId: threeDSServerTransactionId,
            fallback: .success(session),
            attemptsLeft: RyftRequiredActionComponent.sessionCheckAttempts
        ))
    }

    private func checkSessionLater(_ check: SessionCheck) {
        DispatchQueue.main.asyncAfter(deadline: .now() + sessionCheckInterval) { [weak self] in
            self?.checkSession(check)
        }
    }

    private func checkSession(_ check: SessionCheck) {
        apiClient.getPaymentSession(
            id: check.paymentSessionId,
            clientSecret: config.clientSecret,
            accountId: config.accountId
        ) { [weak self] result in
            guard case .success(let session) = result else {
                self?.delegate?.onRequiredActionHandled(result: check.fallback)
                return
            }
            let isPending = session.isAwaitingOutcome
                || session.hasPendingChallenge(threeDSServerTransactionId: check.threeDSServerTransactionId)
            if isPending && check.attemptsLeft > 1 {
                var nextCheck = check
                nextCheck.attemptsLeft -= 1
                self?.checkSessionLater(nextCheck)
                return
            }
            if case .failure = check.fallback, !session.hasSucceeded {
                self?.delegate?.onRequiredActionHandled(result: check.fallback)
                return
            }
            self?.delegate?.onRequiredActionHandled(result: .success(session))
        }
    }
}

public enum RyftRequiredActionError: Error, Equatable {
    case unsupportedRequiredAction(PaymentSessionActionType)
    case missingIdentifyDetails
}
