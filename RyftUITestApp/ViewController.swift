import UIKit
import RyftUI

final class ViewController: UIViewController {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Checkout"
        label.font = .boldSystemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    lazy var checkoutWithApplePayButton: UIButton = {
        let button = UIButton()
        button.setTitle("ShowDropIn (ApplePay)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = view.tintColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.accessibilityIdentifier = "ShowDropInButtonWithApplePay"
        return button
    }()

    lazy var containerStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            checkoutButton,
            checkoutWithApplePayButton
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
        checkoutWithApplePayButton.addTarget(
            self,
            action: #selector(showDropInWithApplePay),
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
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            checkoutWithApplePayButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func showDropIn() {
        let myTheme = RyftUITheme.defaultTheme
        ryftDropIn = RyftDropInPaymentViewController(
            config: RyftDropInConfiguration(
                clientSecret: "ps_123",
                accountId: nil
            ),
            apiClient: MockRyftApiClient(),
            delegate: self
        )
        ryftDropIn?.theme = myTheme
        present(ryftDropIn!, animated: true, completion: nil)
    }

    @objc private func showDropInWithApplePay() {
        let myTheme = RyftUITheme.defaultTheme
        ryftDropIn = RyftDropInPaymentViewController(
            config: RyftDropInConfiguration(
                clientSecret: "ps_123",
                accountId: nil,
                applePay: RyftApplePayConfig(
                    merchantIdentifier: "Id",
                    merchantCountryCode: "GB",
                    merchantName: "Ryft"
                )
            ),
            apiClient: MockRyftApiClient(),
            delegate: self
        )
        ryftDropIn?.theme = myTheme
        present(ryftDropIn!, animated: true, completion: nil)
    }
}

extension ViewController: RyftDropInPaymentDelegate {

    func onPaymentResult(result: RyftPaymentResult) {
        var message = "failure"
        switch result {
        case .failed(let error):
            message = error.displayError
        default:
            break
        }
        let alert = UIAlertController(
            title: "Result",
            message: message,
            preferredStyle: .alert
        )
        present(alert, animated: true, completion: nil)
    }
}

