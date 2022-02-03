import UIKit
import RyftCard

protocol RyftCardExpirationInputProtocol: AnyObject {
    func onCardExpirationChanged(
        expirationMonth: String,
        expirationYear: String,
        state: RyftInputValidationState
    )
}

final class RyftCardExpirationInputField: UIView, UITextFieldDelegate {

    weak var delegate: RyftCardExpirationInputProtocol?

    var theme: RyftUITheme = .defaultTheme

    private lazy var expirationInput: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedStringUtility.expirationPlaceholder
        textField.font = .systemFont(ofSize: 14)
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numbersAndPunctuation
        textField.accessibilityIdentifier = "RyftExpirationInputField-TextField"
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *),
           traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyBorderStyle(expirationInput)
        }
    }

    override func becomeFirstResponder() -> Bool {
        return expirationInput.becomeFirstResponder()
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
            validationState.month.isEmpty && validationState.year.isEmpty,
            and: validationState.state
        )
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        let validationState = validationState(textField)
        updateDisplay(
            validationState.month.isEmpty && validationState.year.isEmpty,
            and: validationState.state
        )
        delegate?.onCardExpirationChanged(
            expirationMonth: validationState.month,
            expirationYear: validationState.year,
            state: validationState.state
        )
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let oldText = textField.text, let range = Range(range, in: oldText) else {
            return true
        }
        let updatedText = oldText.replacingCharacters(in: range, with: string)
        if string.isEmpty && updatedText.count == 2 {
            textField.text = "\(updatedText.prefix(1))"
            return false
        }
        if updatedText.count == 2 {
            if updatedText.contains("/") {
                textField.text = "0\(updatedText)"
            } else {
                textField.text = "\(updatedText)/"
            }
            return false
        }
        if updatedText.count > 5 {
            return false
        }
        return true
    }

    private func setupViews() {
        layer.cornerRadius = 5
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = theme.emptyInputBackgroundColor
        layer.borderWidth = 1
        layer.borderColor = theme.unselectedInputBorderColor.cgColor
        addSubview(expirationInput)
        expirationInput.delegate = self
        setupConstraints()
        accessibilityIdentifier = "RyftExpirationInputField"
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            expirationInput.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 15
            ),
            expirationInput.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -15
            ),
            expirationInput.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 5
            ),
            expirationInput.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -5
            ),
            expirationInput.centerYAnchor.constraint(
                equalTo: centerYAnchor
            )
        ])
    }

    private func validationState(
        _ textField: UITextField
    ) -> (state: RyftInputValidationState, month: String, year: String) {
        let (expirationMonth, expirationYear) = RyftCardFormatter.sanitisedExpiration(
            expiration: textField.text ?? ""
        )
        return (
            RyftCardValidation.validate(
                expirationMonth: expirationMonth,
                expirationYear: expirationYear
            ),
            expirationMonth,
            expirationYear
        )
    }

    private func updateDisplay(
        _ isEmpty: Bool,
        and state: RyftInputValidationState
    ) {
        let hasFocus = expirationInput.isFirstResponder
        layer.borderColor = state == .invalid
            ? theme.invalidColor.cgColor
            : hasFocus
                ? theme.selectedInputBorderColor.cgColor
                : theme.unselectedInputBorderColor.cgColor
        backgroundColor = isEmpty
            ? theme.emptyInputBackgroundColor
            : theme.nonEmptyInputBackgroundColor
    }
}
