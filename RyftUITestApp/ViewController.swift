import UIKit
import RyftUI
import RyftCore

@testable import RyftUI

final class ViewController: UIViewController {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Checkout"
        label.font = .boldSystemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var applyPayToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.setOn(false, animated: false)
        toggle.accessibilityIdentifier = "ApplePayToggle"
        return toggle
    }()

    lazy var applePayToggleStackView: UIStackView = {
        let label = UILabel()
        label.text = "Enable Apple Pay"
        let stackView = UIStackView(arrangedSubviews: [
            label,
            applyPayToggle,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        return stackView
    }()

    lazy var collectCardholderNameToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.setOn(false, animated: false)
        toggle.accessibilityIdentifier = "CollectCardholderNameToggle"
        return toggle
    }()

    lazy var collectCardholderNameToggleStackView: UIStackView = {
        let label = UILabel()
        label.text = "Collect Cardholder Name"
        let stackView = UIStackView(arrangedSubviews: [
            label,
            collectCardholderNameToggle,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        return stackView
    }()

    lazy var getPaymentSessionErrorToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.setOn(false, animated: true)
        toggle.accessibilityIdentifier = "GetPaymentSessionErrorToggle"
        return toggle
    }()

    lazy var getPaymentSessionErrorToggleStackView: UIStackView = {
        let label = UILabel()
        label.text = "Get PaymentSession error"
        let stackView = UIStackView(arrangedSubviews: [
            label,
            getPaymentSessionErrorToggle,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        return stackView
    }()

    lazy var attemptPayment3dsToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.setOn(false, animated: true)
        toggle.accessibilityIdentifier = "AttemptPayment3DSToggle"
        return toggle
    }()

    lazy var attemptPayment3dsToggleStackView: UIStackView = {
        let label = UILabel()
        label.text = "Attempt Payment 3DS required"
        let stackView = UIStackView(arrangedSubviews: [
            label,
            attemptPayment3dsToggle,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        return stackView
    }()

    lazy var failPaymentControl: UISegmentedControl = {
        let toggle = UISegmentedControl(items: ["General", "BillingAddress", "CustomerEmail"])
        toggle.accessibilityIdentifier = "FailPaymentControl"
        return toggle
    }()

    lazy var failPaymentControlStackView: UIStackView = {
        let label = UILabel()
        label.text = "Fail payment?"
        let stackView = UIStackView(arrangedSubviews: [
            label,
            failPaymentControl,
        ])
        stackView.axis = .vertical
        stackView.spacing = 5.0
        return stackView
    }()

    lazy var dropInUsageControl: UISegmentedControl = {
        let toggle = UISegmentedControl(items: ["Payment", "SetupCard"])
        toggle.accessibilityIdentifier = "DropInUsageControl"
        return toggle
    }()

    lazy var dropInUsageControlStackView: UIStackView = {
        let label = UILabel()
        label.text = "Drop In Usage"
        let stackView = UIStackView(arrangedSubviews: [
            label,
            dropInUsageControl,
        ])
        stackView.axis = .vertical
        stackView.spacing = 5.0
        return stackView
    }()

    lazy var checkoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("ShowDropIn", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = view.tintColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.accessibilityIdentifier = "ShowDropInButton"
        return button
    }()

    lazy var containerStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            applePayToggleStackView,
            collectCardholderNameToggleStackView,
            getPaymentSessionErrorToggleStackView,
            attemptPayment3dsToggleStackView,
            failPaymentControlStackView,
            dropInUsageControlStackView,
            checkoutButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16.0
        return stackView
    }()

    private var apiClient: MockRyftApiClient?
    private var ryftDropIn: RyftDropInPaymentViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        checkoutButton.addTarget(
            self,
            action: #selector(showDropIn),
            for: .touchUpInside
        )
    }

    private func setupConstraints() {
        view.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            containerStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24),
            containerStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            containerStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func showDropIn() {
        apiClient = MockRyftApiClient()
        if getPaymentSessionErrorToggle.isOn {
            apiClient?.getPaymentSessionResult = .failure(.general(message: "boom!"))
        }
        if failPaymentControl.selectedSegmentIndex == 0 {
            apiClient?.attemptPaymentResult = .failure(.general(message: "uh oh"))
        }
        if failPaymentControl.selectedSegmentIndex == 1 {
            apiClient?.attemptPaymentResult = .failure(.badResponse(detail: HttpError.HttpErrorDetail(
                statusCode: 400,
                body: RyftApiError(
                    requestId: UUID().uuidString.lowercased(),
                    code: "some_code",
                    errors: [
                        RyftApiError.RyftApiErrorElement(
                            code: "400",
                            message: "billingAddress.city is invalid"
                        )
                    ]
                )
            )))
        }
        if failPaymentControl.selectedSegmentIndex == 2 {
            let paymentSessionRequiringEmail = PaymentSession(
                id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
                amount: 350,
                currency: "GBP",
                status: .pendingPayment,
                customerEmail: nil,
                lastError: nil,
                requiredAction: nil,
                returnUrl: "https://ryftpay.com",
                createdTimestamp: 123
            )
            apiClient?.getPaymentSessionResult = .success(paymentSessionRequiringEmail)
            apiClient?.attemptPaymentResult = .failure(.badResponse(detail: HttpError.HttpErrorDetail(
                statusCode: 400,
                body: RyftApiError(
                    requestId: UUID().uuidString.lowercased(),
                    code: "some_code",
                    errors: [
                        RyftApiError.RyftApiErrorElement(
                            code: "400",
                            message: "customerDetails.email is invalid"
                        )
                    ]
                )
            )))
        }
        if attemptPayment3dsToggle.isOn {
            let paymentSessionRequiringThreeDs = PaymentSession(
                id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
                amount: 350,
                currency: "GBP",
                status: .pendingAction,
                customerEmail: nil,
                lastError: nil,
                requiredAction: PaymentSessionRequiredAction(
                    type: .identify,
                    identify: RequiredActionIdentifyApp(
                        sessionId: "session_123",
                        sessionSecret: "secret",
                        scheme: "mastercard",
                        paymentMethodId: "pmt_01FCTS1XMKH9FF43CAFA4CXT3P"
                    )
                ),
                returnUrl: "https://ryftpay.com",
                createdTimestamp: 123
            )
            apiClient?.attemptPaymentResult = .success(paymentSessionRequiringThreeDs)
        }
        let myTheme = RyftUITheme.defaultTheme
        ryftDropIn = RyftDropInPaymentViewController(
            config: RyftDropInConfiguration(
                clientSecret: "ps_123",
                accountId: nil,
                display: RyftDropInConfiguration.RyftDropInDisplayConfig(
                    payButtonTitle: nil,
                    usage: dropInUsageControl.selectedSegmentIndex > 0 ? .setupCard : .payment
                ),
                applePay: applyPayToggle.isOn
                    ? RyftApplePayConfig(
                        merchantIdentifier: "Id",
                        merchantCountryCode: "GB",
                        merchantName: "Ryft"
                    ) : nil,
                fieldCollection: RyftDropInConfiguration.RyftDropInFieldCollectionConfig(
                    nameOnCard: collectCardholderNameToggle.isOn
                )
            ),
            apiClient: apiClient!,
            delegate: self
        )
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.viewController = ryftDropIn
        let requiredActionComponent = RyftRequiredActionComponent(
            config: RyftRequiredActionComponent.Configuration(clientSecret: "secret"),
            apiClient: apiClient!,
            threeDsActionHandler: threeDsHandler
        )
        requiredActionComponent.delegate = ryftDropIn
        ryftDropIn?.requiredActionComponent = requiredActionComponent
        ryftDropIn?.theme = myTheme
        present(ryftDropIn!, animated: true, completion: nil)
    }
}

extension ViewController: RyftDropInPaymentDelegate {

    func onPaymentResult(result: RyftPaymentResult) {
        var title = "Payment Failed"
        var message = "failure"
        switch result {
        case .cancelled:
            title = "Payment Cancelled"
        case .failed(let error):
            message = error.displayError
        case .success(let paymentSession):
            title = "Payment Success"
            message = paymentSession.id
        case .pendingAction(_, let requiredAction):
            apiClient?.attemptPaymentResult = .success(PaymentSession(
                id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
                amount: 350,
                currency: "GBP",
                status: .approved,
                customerEmail: "support@ryftpay.com",
                lastError: nil,
                requiredAction: nil,
                returnUrl: "https://ryftpay.com",
                createdTimestamp: 123
            ))
            ryftDropIn?.handleRequiredAction(returnUrl: nil, requiredAction)
            return
        }
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
}

