import UIKit
import RyftCard

protocol RyftCardCvcInputProtocol: AnyObject {
    func onCvcChanged(cvc: String, state: RyftInputValidationState)
}

final class RyftCardCvcInputField: UIView, UITextFieldDelegate {

    weak var delegate: RyftCardCvcInputProtocol?

    var cardType = RyftCardType.unknown {
        didSet {
            truncateCurrentCvc()
        }
    }

    var theme: RyftUITheme = .defaultTheme

    private lazy var cvcIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = RyftImages.cvcIcon
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.accessibilityIdentifier = "RyftCvcInputField-iconImage"
        return imageView
    }()

    private lazy var cvcInput: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedStringUtility.cvcPlaceholder
        textField.font = .systemFont(ofSize: 14)
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.rightView = cvcIconImage
        textField.rightViewMode = .always
        textField.keyboardType = .numberPad
        textField.accessibilityIdentifier = "RyftCvcInputField-textField"
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func becomeFirstResponder() -> Bool {
        return cvcInput.becomeFirstResponder()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *),
           traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyBorderStyle(cvcInput)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        applyBorderStyle(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        applyBorderStyle(textField)
    }

    private func applyBorderStyle(_ textField: UITextField) {
        let validationState = validationState(textField)
        updateDisplay(
            validationState.cvc.isEmpty,
            with: cardType,
            and: validationState.state
        )
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        onTextChanged(textField)
    }

    private func onTextChanged(_ textField: UITextField) {
        let validationState = validationState(textField)
        updateDisplay(
            validationState.cvc.isEmpty,
            with: cardType,
            and: validationState.state
        )
        delegate?.onCvcChanged(
            cvc: validationState.cvc,
            state: validationState.state
        )
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let cvc = "\(text)\(string)"
        return cvc.count <= cardType.cvcLength
    }

    private func truncateCurrentCvc() {
        guard let cvc = cvcInput.text else {
            return
        }
        cvcInput.text = String(cvc.prefix(cardType.cvcLength))
        onTextChanged(cvcInput)
    }

    private func setupViews() {
        layer.cornerRadius = 5
        clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = theme.emptyInputBackgroundColor
        layer.borderWidth = 1
        layer.borderColor = theme.unselectedInputBorderColor.cgColor
        addSubview(cvcInput)
        cvcInput.delegate = self
        accessibilityIdentifier = "RyftCvcInputField"
        setupConstraints()
    }

    private func validationState(
        _ textField: UITextField
    ) -> (state: RyftInputValidationState, cvc: String) {
        let cvc = RyftCardFormatter.sanitisedOnlyDigits(value: textField.text ?? "")
        return (
            RyftCardValidation.validate(cvc: cvc, with: cardType),
            cvc
        )
    }

    private func updateDisplay(
        _ isEmpty: Bool,
        with cardType: RyftCardType,
        and state: RyftInputValidationState
    ) {
        let hasFocus = cvcInput.isFirstResponder
        layer.borderColor = state == .invalid
            ? theme.invalidColor.cgColor
            : hasFocus
                ? theme.selectedInputBorderColor.cgColor
                : theme.unselectedInputBorderColor.cgColor
        backgroundColor = isEmpty
            ? theme.emptyInputBackgroundColor
            : theme.nonEmptyInputBackgroundColor
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cvcInput.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 15
            ),
            cvcInput.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -15
            ),
            cvcInput.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 5
            ),
            cvcInput.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -5
            )
        ])
    }
}
