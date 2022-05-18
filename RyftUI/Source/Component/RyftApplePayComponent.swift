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
    private let config: RyftApplePayConfig
    private let apiClient: RyftApiClient
    private var paymentAuthController: PKPaymentAuthorizationController?

    public enum RyftApplePayPaymentStatus {
        case cancelled
        case error(error: Error?)
        case success(paymentSession: PaymentSession)
    }

    public required init?(
        clientSecret: String,
        accountId: String?,
        config: RyftApplePayConfig,
        apiClient: RyftApiClient,
        delegate: RyftApplePayComponentDelegate
    ) {
        guard PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: [.visa, .masterCard]
        ) else {
            return nil
        }
        self.clientSecret = clientSecret
        self.accountId = accountId
        self.config = config
        self.apiClient = apiClient
        self.delegate = delegate
        super.init()
    }

    public func present() {
        apiClient.getPaymentSession(
            id: String(clientSecret.components(separatedBy: "_secret_")[0]),
            clientSecret: clientSecret,
            accountId: accountId
        ) { result in
            DispatchQueue.main.async {
                self.handleGetPaymentSession(result)
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
        case .failed(let ryftError):
            controller.dismiss()
            delegate?.applePayPayment(finishedWith: .error(error: nil))
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
//        print("billingAddress = \(payment.billingContact?.postalAddress), billingName = \(payment.billingContact?.name)")
        let applePayToken = payment.token.paymentData.base64EncodedString()
        paymentState = .processing
        apiClient.attemptPayment(
            request: AttemptPaymentRequest.fromApplePay(
                clientSecret: clientSecret,
                applePayToken: applePayToken
            ),
            accountId: accountId
        ) { result in
            DispatchQueue.main.async {
                self.handlePaymentResult(result) { status, _ in
                    let errors: [Error] = []
                    completion(PKPaymentAuthorizationResult(status: status, errors: errors))
                }
            }
        }
    }

    private func handleGetPaymentSession(_ result: Result<PaymentSession, HttpError>) {
        switch result {
        case .success(let paymentSession):
            presentApplePaySheet(with: paymentSession)
        case .failure:
            print("error loading payment")
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
                print("lastError = \(ryftError)")
                paymentState = .failed(error: nil, ryftError)
                completion(.failure, nil)
            }
        case .failure(let e):
            print("error = \(e)")
            paymentState = .failed(error: e, nil)
            completion(.failure, nil)
        }
    }

    private func presentApplePaySheet(with payment: PaymentSession) {
        self.paymentAuthController = PKPaymentAuthorizationController(
            paymentRequest: payment.toPKPayment(
                merchantIdentifier: config.merchantIdentifier,
                merchantCountry: config.merchantCountryCode,
                merchantName: config.merchantName
            )
        )
        paymentAuthController?.delegate = self
        paymentAuthController?.present()
    }
}
