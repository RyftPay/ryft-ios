import UIKit
import RyftCore
import Ravelin3DS

public enum ThreeDsChallengeResult {
    case completed(transactionStatus: String, threeDSServerTransactionId: String)
    case cancelled
    case failed(error: Error)
}

public protocol RyftThreeDsActionHandler {

    func createTransaction(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Result<ThreeDsTransactionParams, Error>) -> Void
    )

    func doChallenge(
        action: ChallengeAction,
        presentingViewController: UIViewController,
        completion: @escaping (ThreeDsChallengeResult) -> Void
    )

    func cleanup()
}

public final class DefaultRyftThreeDsActionHandler: RyftThreeDsActionHandler {

    private let environment: RyftEnvironment
    private static let challengeTimeoutInMinutes = 10

    private var threeDsService: ThreeDS2SDK?
    private var transaction: (any Transaction)?
    private var challengeStatusReceiver: ChallengeStatusReceiver?
    private var challengeView: ViewControllerChallengeView?

    public init(environment: RyftEnvironment) {
        self.environment = environment
    }

    public func createTransaction(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Result<ThreeDsTransactionParams, Error>) -> Void
    ) {
        guard threeDsService == nil else {
            return
        }
        let mainThreadCompletion: (Result<ThreeDsTransactionParams, Error>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }
        let configParams = ConfigParameters()
        do {
            try configParams.addParam(
                paramType: .publishableApiKey,
                paramValue: action.ravelinPublicKey
            )
        } catch {
            mainThreadCompletion(.failure(error))
            return
        }
        let service = ThreeDS2SDK()
        do {
            try service.initialize(configParameters: configParams, uiCustomization: nil) { [weak self] success in
                guard success else {
                    mainThreadCompletion(.failure(RavelinThreeDsError.initialisationFailed))
                    return
                }
                guard let self = self else {
                    mainThreadCompletion(.failure(RavelinThreeDsError.initialisationFailed))
                    return
                }
                self.handleInitialised(service: service, action: action, completion: mainThreadCompletion)
            }
        } catch {
            mainThreadCompletion(.failure(error))
        }
    }

    private func handleInitialised(
        service: ThreeDS2SDK,
        action: RequiredActionIdentifyApp,
        completion: @escaping (Result<ThreeDsTransactionParams, Error>) -> Void
    ) {
        do {
            let directoryServerId = try toDirectoryServerId(scheme: action.scheme)
            service.createTransaction(
                directoryServerID: directoryServerId,
                messageVersion: action.protocolVersion
            ) { [weak self] result in
                self?.handleTransactionCreated(
                    service: service,
                    result: result.mapError { $0 as Error },
                    completion: completion
                )
            }
        } catch {
            completion(.failure(error))
        }
    }

    private func handleTransactionCreated(
        service: ThreeDS2SDK,
        result: Result<any Transaction, Error>,
        completion: @escaping (Result<ThreeDsTransactionParams, Error>) -> Void
    ) {
        switch result {
        case .failure(let error):
            completion(.failure(error))
        case .success(let transaction):
            threeDsService = service
            self.transaction = transaction
            do {
                let params = try transaction.getAuthenticationRequestParameters()
                completion(.success(ThreeDsTransactionParams(
                    sdkTransactionId: params.getSDKTransactionID(),
                    sdkApplicationId: params.getSDKAppID(),
                    sdkEncryptedData: params.getDeviceData(),
                    sdkEphemeralPublicKey: params.getSDKEphemeralPublicKey(),
                    sdkReferenceNumber: params.getSDKReferenceNumber()
                )))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func doChallenge(
        action: ChallengeAction,
        presentingViewController: UIViewController,
        completion: @escaping (ThreeDsChallengeResult) -> Void
    ) {
        let mainThreadCompletion: (ThreeDsChallengeResult) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }
        guard let transaction = transaction else {
            mainThreadCompletion(.failed(error: RavelinThreeDsError.missingTransaction))
            return
        }
        let challengeParams = ChallengeParameters()
        challengeParams.set3DSServerTransactionID(action.threeDSServerTransactionId)
        challengeParams.setAcsTransactionID(action.acsTransactionId)
        challengeParams.setAcsRefNumber(action.acsRefNumber)
        challengeParams.setAcsSignedContent(action.acsSignedContent)
        let receiver = ChallengeStatusReceiver(
            threeDSServerTransactionId: action.threeDSServerTransactionId,
            completion: mainThreadCompletion
        )
        let challengeView = ViewControllerChallengeView(viewController: presentingViewController)
        self.challengeStatusReceiver = receiver
        self.challengeView = challengeView
        do {
            try transaction.doChallenge(
                challengeParameters: challengeParams,
                challengeStatusReceiver: receiver,
                timeOut: DefaultRyftThreeDsActionHandler.challengeTimeoutInMinutes,
                challengeView: challengeView
            )
        } catch {
            mainThreadCompletion(.failed(error: error))
        }
    }

    public func cleanup() {
        try? transaction?.close()
        try? threeDsService?.cleanup()
        transaction = nil
        threeDsService = nil
        challengeStatusReceiver = nil
        challengeView = nil
    }

    internal func toDirectoryServerId(scheme: String) throws -> String {
        // In sandbox all Luhn-valid test cards are wired to mock-directory-server-a (M000000003)
        guard environment == .production else {
            return "M000000003"
        }
        switch scheme.lowercased() {
        case "visa": return "A000000003"
        case "mastercard": return "A000000004"
        case "amex": return "A000000025"
        case "discover": return "A000000152"
        case "jcb": return "A000000065"
        case "unionpay": return "A000000333"
        default: throw RavelinThreeDsError.unsupportedScheme(scheme)
        }
    }
}

internal enum RavelinThreeDsError: Error {
    case initialisationFailed
    case missingTransaction
    case challengeTimedOut
    case challengeFailed(message: String)
    case unsupportedScheme(String)
}

private final class ChallengeStatusReceiver: Ravelin3DS.ChallengeStatusReceiver {

    private let threeDSServerTransactionId: String
    private let completion: (ThreeDsChallengeResult) -> Void

    init(
        threeDSServerTransactionId: String,
        completion: @escaping (ThreeDsChallengeResult) -> Void
    ) {
        self.threeDSServerTransactionId = threeDSServerTransactionId
        self.completion = completion
    }

    func completed(completionEvent: Ravelin3DS.CompletionEvent) {
        completion(.completed(
            transactionStatus: completionEvent.getTransactionStatus(),
            threeDSServerTransactionId: threeDSServerTransactionId
        ))
    }

    func cancelled() {
        completion(.cancelled)
    }

    func timedout() {
        completion(.failed(error: RavelinThreeDsError.challengeTimedOut))
    }

    func protocolError(protocolErrorEvent: Ravelin3DS.ProtocolErrorEvent) {
        completion(.failed(
            error: RavelinThreeDsError.challengeFailed(
                message: protocolErrorEvent.getErrorMessage().getErrorDescription()
            )
        ))
    }

    func runtimeError(runtimeErrorEvent: Ravelin3DS.RuntimeErrorEvent) {
        completion(.failed(
            error: RavelinThreeDsError.challengeFailed(
                message: runtimeErrorEvent.getErrorMessage()
            )
        ))
    }
}

private final class ViewControllerChallengeView: Ravelin3DS.ChallengeView {
    let viewController: UIViewController
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
