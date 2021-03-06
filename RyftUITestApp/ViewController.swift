import UIKit
import RyftUI
import RyftCore

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
            getPaymentSessionErrorToggleStackView,
            failPaymentControlStackView,
            checkoutButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16.0
        return stackView
    }()

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
        let apiClient = MockRyftApiClient()
        if getPaymentSessionErrorToggle.isOn {
            apiClient.getPaymentSessionResult = .failure(.general(message: "boom!"))
        }
        if failPaymentControl.selectedSegmentIndex == 0 {
            apiClient.attemptPaymentResult = .failure(.general(message: "uh oh"))
        }
        if failPaymentControl.selectedSegmentIndex == 1 {
            apiClient.attemptPaymentResult = .failure(.badResponse(detail: HttpError.HttpErrorDetail(
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
            apiClient.getPaymentSessionResult = .success(paymentSessionRequiringEmail)
            apiClient.attemptPaymentResult = .failure(.badResponse(detail: HttpError.HttpErrorDetail(
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
        let myTheme = RyftUITheme.defaultTheme
        ryftDropIn = RyftDropInPaymentViewController(
            config: RyftDropInConfiguration(
                clientSecret: "ps_123",
                accountId: nil,
                applePay: applyPayToggle.isOn
                    ? RyftApplePayConfig(
                        merchantIdentifier: "Id",
                        merchantCountryCode: "GB",
                        merchantName: "Ryft"
                    ) : nil
            ),
            apiClient: apiClient,
            delegate: self
        )
        ryftDropIn?.theme = myTheme
        present(ryftDropIn!, animated: true, completion: nil)
    }
}

extension ViewController: RyftDropInPaymentDelegate {

    func onPaymentResult(result: RyftPaymentResult) {
        var title = "Payment Failed"
        var message = "failure"
        switch result {
        case .failed(let error):
            message = error.displayError
        case .success(let paymentSession):
            title = "Payment Success"
            message = paymentSession.id
        default:
            break
        }
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        present(alert, animated: true, completion: nil)
    }
}

