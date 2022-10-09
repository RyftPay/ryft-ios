import UIKit
import PassKit

final class DropInViewFactory {

    static func createApplePayButton() -> PKPaymentButton {
        let button = PKPaymentButton(
            paymentButtonType: .plain,
            paymentButtonStyle: .backwardsCompatible
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "RyftApplePayButton"
        return button
    }

    static func createContainerView(theme: RyftUITheme) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = theme.primaryBackgroundColor
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = NSLocalizedStringUtility.cardDropInTitle
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "RyftTitleLabel"
        return label
    }

    static func createOrLabel() -> UILabel {
        let label = UILabel()
        label.text = NSLocalizedStringUtility.orWord
        label.textAlignment = .center
        label.font = .italicSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    static func createSaveCardLabel() -> UILabel {
        let label = UILabel()
        label.text = NSLocalizedStringUtility.saveCardOptInMessage
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .saveCardOptInTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    static func createSaveCardToggleView() -> RyftSaveCardToggleView {
        let view = RyftSaveCardToggleView()
        view.accessibilityIdentifier = "RyftSaveCardToggleView"
        return view
    }

    static func createPayButton(
        customTitle: String?,
        buttonTap: @escaping () -> Void
    ) -> RyftConfirmButton {
        let button = RyftConfirmButton(
            title: customTitle ?? NSLocalizedStringUtility.payNow,
            buttonTap: buttonTap
        )
        button.accessibilityIdentifier = "RyftConfirmButton-Pay"
        return button
    }

    static func createCancelButton(theme: RyftUITheme) -> UIButton {
        let button = UIButton()
        button.setTitle(
            NSLocalizedStringUtility.cancelTitle,
            for: .normal
        )
        button.setTitleColor(theme.cancelButtonTitleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = theme.cancelButtonBackgroundColor
        button.layer.borderWidth = 1
        button.layer.borderColor = theme.cancelButtonBorderColor.cgColor
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.accessibilityIdentifier = "RyftButton-Cancel"
        return button
    }

    static func createAlert(
        message: String,
        defaultActionHandler: (((UIAlertAction) -> Void)?)
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedStringUtility.oopsWord,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedStringUtility.cancelTitle,
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: NSLocalizedStringUtility.retryWord,
            style: .default,
            handler: defaultActionHandler
        ))
        return alert
    }
}
