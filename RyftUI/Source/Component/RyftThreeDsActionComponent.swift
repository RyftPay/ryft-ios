import UIKit
import RyftCore
import Ravelin3DS

public enum ThreeDsChallengeResult {
    case completed(transactionStatus: String, threeDSServerTransactionId: String)
    case cancelled
    case failed(message: String)
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
        let configParams = ConfigParameters()
        do {
            try configParams.addParam(
                paramType: .publishableApiKey,
                paramValue: action.ravelinPublicKey
            )
        } catch {
            completion(.failure(error))
            return
        }
        let service = ThreeDS2SDK()
        do {
            try service.initialize(configParameters: configParams, uiCustomization: nil) { [weak self] success in
                guard success else {
                    completion(.failure(RavelinThreeDsError.initialisationFailed))
                    return
                }
                guard let self = self else { return }
                do {
                    let directoryServerId = try self.toDirectoryServerId(scheme: action.scheme)
                    let messageVersion = action.protocolVersion
                    service.createTransaction(
                        directoryServerID: directoryServerId,
                        messageVersion: messageVersion
                    ) { [weak self] result in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success(let tx):
                            self?.threeDsService = service
                            self?.transaction = tx
                            do {
                                let params = try tx.getAuthenticationRequestParameters()
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
                } catch {
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    public func doChallenge(
        action: ChallengeAction,
        presentingViewController: UIViewController,
        completion: @escaping (ThreeDsChallengeResult) -> Void
    ) {
        guard let tx = transaction else {
            completion(.failed(message: "No active 3DS transaction"))
            return
        }
        let challengeParams = ChallengeParameters()
        challengeParams.set3DSServerTransactionID(action.threeDSServerTransactionId)
        challengeParams.setAcsTransactionID(action.acsTransactionId)
        challengeParams.setAcsRefNumber(action.acsRefNumber)
        challengeParams.setAcsSignedContent(action.acsSignedContent)
        let receiver = ChallengeStatusReceiver(
            threeDSServerTransactionId: action.threeDSServerTransactionId,
            completion: completion
        )
        let challengeView = ViewControllerChallengeView(viewController: presentingViewController)
        self.challengeStatusReceiver = receiver
        self.challengeView = challengeView
        do {
            try tx.doChallenge(
                challengeParameters: challengeParams,
                challengeStatusReceiver: receiver,
                timeOut: 5,
                challengeView: challengeView
            )
        } catch {
            completion(.failed(message: error.localizedDescription))
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

    private func toDirectoryServerId(scheme: String) throws -> String {
        let prefix = environment == .production ? "A" : "M"
        switch scheme.lowercased() {
        case "visa": return "\(prefix)000000003"
        case "mastercard": return "\(prefix)000000004"
        case "amex": return "\(prefix)000000025"
        case "discover": return "\(prefix)000000152"
        case "jcb": return "\(prefix)000000065"
        case "unionpay": return "\(prefix)000000333"
        default: throw RavelinThreeDsError.unsupportedScheme(scheme)
        }
    }

}

private enum RavelinThreeDsError: Error {
    case initialisationFailed
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
        completion(.failed(message: "Challenge timed out"))
    }

    func protocolError(protocolErrorEvent: Ravelin3DS.ProtocolErrorEvent) {
        completion(.failed(
            message: "Protocol error: \(protocolErrorEvent.getErrorMessage().getErrorDescription())"
        ))
    }

    func runtimeError(runtimeErrorEvent: Ravelin3DS.RuntimeErrorEvent) {
        completion(.failed(message: "Runtime error: \(runtimeErrorEvent.getErrorMessage())"))
    }
}

private final class ViewControllerChallengeView: Ravelin3DS.ChallengeView {
    let viewController: UIViewController
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
