import UIKit
import RyftCard

protocol RyftCardholderNameInputProtocol: AnyObject {
    func onCardholderNameChanged(value: String, state: RyftInputValidationState)
    func onCardholderNameReturnKeyPressed()
}

final class RyftCardholderNameInputField: UIView, UITextFieldDelegate {

    weak var delegate: RyftCardholderNameInputProtocol?

    var theme: RyftUITheme = .defaultTheme

    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = RyftImages.cardholderNameIcon
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.accessibilityIdentifier = "RyftCardholderNameInputField-iconImage"
        return imageView
    }()

    private lazy var nameInput: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedStringUtility.cardholderNamePlaceholder
        textField.font = .systemFont(ofSize: 14)
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.rightView = iconImage
        textField.rightViewMode = .always
        textField.keyboardType = .namePhonePad
        textField.accessibilityIdentifier = "RyftCardholderNameInputField-textField"
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
        return nameInput.becomeFirstResponder()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *),
          traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyBorderStyle(nameInput)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        applyBorderStyle(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        applyBorderStyle(textField)
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        onTextChanged(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.onCardholderNameReturnKeyPressed()
        return false
    }

    private func applyBorderStyle(_ textField: UITextField) {
        let validationState = validationState(textField)
        updateDisplay(validationState.name.isEmpty, and: validationState.state)
    }

    private func onTextChanged(_ textField: UITextField) {
        let validationState = validationState(textField)
        updateDisplay(
            validationState.name.isEmpty,
            and: validationState.state
        )
        delegate?.onCardholderNameChanged(
            value: validationState.name,
            state: validationState.state
        )
    }

    private func validationState(
        _ textField: UITextField
    ) -> (state: RyftInputValidationState, name: String) {
        let name = RyftCardFormatter.sanitisedName(value: textField.text ?? "")
        return (
            RyftCardValidation.validate(cardholderName: name),
            name
        )
    }

    private func updateDisplay(
        _ isEmpty: Bool,
        and state: RyftInputValidationState
    ) {
        let hasFocus = nameInput.isFirstResponder
        layer.borderColor = state == .invalid
            ? theme.invalidColor.cgColor
            : hasFocus
                ? theme.selectedInputBorderColor.cgColor
                : theme.unselectedInputBorderColor.cgColor
        backgroundColor = isEmpty
            ? theme.emptyInputBackgroundColor
            : theme.nonEmptyInputBackgroundColor
    }

    private func setupViews() {
        layer.cornerRadius = 5
        clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = theme.emptyInputBackgroundColor
        layer.borderWidth = 1
        layer.borderColor = theme.unselectedInputBorderColor.cgColor
        addSubview(nameInput)
        nameInput.delegate = self
        accessibilityIdentifier = "RyftCardholderNameInputField"
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameInput.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 15
            ),
            nameInput.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -15
            ),
            nameInput.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 5
            ),
            nameInput.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -5
            )
        ])
    }
}
