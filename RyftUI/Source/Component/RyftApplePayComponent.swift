import UIKit
import PassKit
import RyftCore

public protocol RyftApplePayComponentDelegate: AnyObject {

    func applePayPayment(
        finishedWith status: RyftApplePayComponent.RyftApplePayPaymentStatus
    )
}

public final class RyftApplePayComponent: NSObject, PKPaymentAuthorizationControllerDelegate {

    public weak var delegate: RyftApplePayComponentDelegate?

    private var paymentState: RyftPaymentState = .notStarted
    private let clientSecret: String
    private let accountId: String?
    private let apiClient: RyftApiClient
    private let config: RyftApplePayComponentConfig
    private var paymentAuthController: PKPaymentAuthorizationController?

    public enum RyftApplePayComponentConfig {
        case auto(config: RyftApplePayConfig)
        case manual(paymentRequest: PKPaymentRequest)
    }

    public enum RyftApplePayPaymentStatus {
        case cancelled
        case error(error: Error?, paymentError: RyftPaymentError?)
        case success(paymentSession: PaymentSession)
    }

    public required init?(
        clientSecret: String,
        accountId: String?,
        config: RyftApplePayComponentConfig,
        delegate: RyftApplePayComponentDelegate,
        apiClient: RyftApiClient
    ) {
        guard RyftUI.supportsApplePay() else {
            return nil
        }
        self.clientSecret = clientSecret
        self.accountId = accountId
        self.config = config
        self.delegate = delegate
        self.apiClient = apiClient
        super.init()
    }

    public required init?(
        publicApiKey: String,
        clientSecret: String,
        accountId: String?,
        config: RyftApplePayComponentConfig,
        delegate: RyftApplePayComponentDelegate
    ) {
        guard RyftUI.supportsApplePay() else {
            return nil
        }
        self.clientSecret = clientSecret
        self.accountId = accountId
        self.config = config
        self.apiClient = DefaultRyftApiClient(publicApiKey: publicApiKey)
        self.delegate = delegate
        super.init()
    }

    public func present(completion: ((Bool) -> Void)?) {
        switch config {
        case .auto(let config):
            populatePayment(with: config, completion: completion)
        case .manual(let paymentRequest):
            presentApplePaySheet(with: paymentRequest, completion: completion)
        }
    }

    private func populatePayment(
        with config: RyftApplePayConfig,
        completion: ((Bool) -> Void)?
    ) {
        apiClient.getPaymentSession(
            id: String(clientSecret.components(separatedBy: "_secret_")[0]),
            clientSecret: clientSecret,
            accountId: accountId
        ) { result in
            DispatchQueue.main.async {
                self.handleGetPaymentSession(
                    config,
                    result,
                    applePayPresentCompletion: completion
                )
            }
        }
    }

    public func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }

    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        switch paymentState {
        case .notStarted:
            controller.dismiss()
            delegate?.applePayPayment(finishedWith: .cancelled)
        case .processing:
            break
        case let .failed(error, ryftError):
            controller.dismiss()
            delegate?.applePayPayment(finishedWith: .error(
                error: error,
                paymentError: ryftError
            ))
        case .complete(let paymentSession):
            controller.dismiss()
            delegate?.applePayPayment(finishedWith: .success(paymentSession: paymentSession))
        }
    }

    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        let applePayToken = payment.token.paymentData.base64EncodedString()
        paymentState = .processing
        apiClient.attemptPayment(
            request: AttemptPaymentRequest.fromApplePay(
                clientSecret: clientSecret,
                applePayToken: applePayToken,
                billingAddress: BillingAddress(pkContact: payment.billingContact),
                customerDetails: PaymentRequestCustomerDetails(pkContact: payment.shippingContact)
            ),
            accountId: accountId
        ) { result in
            DispatchQueue.main.async {
                self.handlePaymentResult(result) { status, error in
                    completion(PKPaymentAuthorizationResult(
                        status: status,
                        errors: RyftUI.pkPaymentErrors(error)
                    ))
                }
            }
        }
    }

    private func handleGetPaymentSession(
        _ config: RyftApplePayConfig,
        _ result: Result<PaymentSession, HttpError>,
        applePayPresentCompletion: ((Bool) -> Void)?
    ) {
        switch result {
        case .success(let paymentSession):
            presentApplePaySheet(
                with: paymentSession,
                and: config,
                completion: applePayPresentCompletion
            )
        case .failure:
            applePayPresentCompletion?(false)
        }
    }

    private func handlePaymentResult(
        _ result: Result<PaymentSession, HttpError>,
        completion: @escaping (PKPaymentAuthorizationStatus, Error?) -> Void
    ) {
        switch result {
        case .success(let paymentSession):
            if paymentSession.status == .approved || paymentSession.status == .captured {
                paymentState = .complete(paymentSession)
                completion(.success, nil)
            }
            if let lastError = paymentSession.lastError {
                let ryftError = RyftPaymentError(paymentSessionError: lastError)
                paymentState = .failed(error: nil, ryftError)
                completion(.failure, nil)
            }
        case .failure(let error):
            paymentState = .failed(error: error, nil)
            completion(.failure, error)
        }
    }

    private func presentApplePaySheet(
        with payment: PaymentSession,
        and config: RyftApplePayConfig,
        completion: ((Bool) -> Void)?
    ) {
        presentApplePaySheet(
            with: payment.toPKPayment(
                merchantIdentifier: config.merchantIdentifier,
                merchantCountry: config.merchantCountryCode,
                merchantName: config.merchantName
            ),
            completion: completion
        )
    }

    private func presentApplePaySheet(
        with paymentRequest: PKPaymentRequest,
        completion: ((Bool) -> Void)?
    ) {
        self.paymentAuthController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentAuthController?.delegate = self
        paymentAuthController?.present(completion: completion)
    }
}
