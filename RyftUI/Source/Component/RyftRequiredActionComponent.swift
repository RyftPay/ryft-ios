import RyftCore
import Checkout3DS

public protocol RyftRequiredActionDelegate: AnyObject {

    func onRequiredActionInProgress()

    func onRequiredActionHandled(result: Result<PaymentSession, Error>)
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

    public var delegate: RyftRequiredActionDelegate?

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

    init(
        config: Configuration,
        apiClient: RyftApiClient,
        threeDsActionHandler: RyftThreeDsActionHandler
    ) {
        self.config = config
        self.apiClient = apiClient
        self.threeDsActionHandler = threeDsActionHandler
    }

    public func handle(action: PaymentSessionRequiredAction) {
        switch action.type {
        case .identify:
            handle(action: action.identify!)
        default:
            assertionFailure(
                "The requiredAction type '\(action.type)' is unsupported on iOS"
            )
        }
    }

    private func handle(action: RequiredActionIdentifyApp) {
        threeDsActionHandler.handle(action: action, completion: { _ in
            self.delegate?.onRequiredActionInProgress()
            self.apiClient.attemptPayment(
                request: AttemptPaymentRequest.fromPaymentMethod(
                    clientSecret: self.config.clientSecret,
                    paymentMethodId: action.paymentMethodId
                ),
                accountId: self.config.accountId,
                completion: { result in
                    self.delegate?.onRequiredActionHandled(
                        result: result.flatMapError { httpError in
                            .failure(httpError)
                        }
                    )
                }
            )
        })
    }
}
