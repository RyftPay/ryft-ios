import UIKit
import RyftCard

protocol RyftCardNumberInputProtocol: AnyObject {
    func onCardNumberChanged(
        cardNumber: String,
        cardType: RyftCardType,
        state: RyftInputValidationState
    )
}

final class RyftCardNumberInputField: UIView, UITextFieldDelegate {

    weak var delegate: RyftCardNumberInputProtocol?

    var theme: RyftUITheme = .defaultTheme

    private lazy var cardNumberInput: UITextField = {
        let textField = UITextField()
        textField.textContentType = .creditCardNumber
        textField.placeholder = NSLocalizedStringUtility.cardNumberPlaceholder
        textField.font = .systemFont(ofSize: 14)
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.rightView = cardIconImage
        textField.rightViewMode = .always
        textField.addTarget(self, action: #selector(cardTextDidChange(_:)), for: .editingChanged)
        textField.accessibilityIdentifier = "RyftCardNumberInputField-textField"
        return textField
    }()

    private lazy var cardIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = RyftImages.unknownCardIcon
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.accessibilityIdentifier = "RyftCardNumberInputField-iconImage"
        return imageView
    }()

    private var previousTextCount = 0

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
            applyBorderStyle(cardNumberInput)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        applyBorderStyle(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        applyBorderStyle(textField)
    }

    private func applyBorderStyle(_ textField: UITextField) {
        let state = cardValidationState(textField)
        updateDisplay(
            state.cardNumber.isEmpty,
            with: state.cardType,
            and: state.validationState
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
        let fullText = "\(text)\(string)"
        let cardNumber = RyftCardFormatter.sanitisedOnlyDigits(value: fullText)
        let cardType = RyftCardValidation.determineCardType(cardNumber: cardNumber)
        guard cardNumber.count <= cardType.cardLengths.last! else {
            return false
        }
        return true
    }

    @objc
    func cardTextDidChange(_ textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        let state = cardValidationState(textField)
        updateDisplay(
            state.cardNumber.isEmpty,
            with: state.cardType,
            and: state.validationState
        )
        delegate?.onCardNumberChanged(
            cardNumber: state.cardNumber,
            cardType: state.cardType,
            state: state.validationState
        )
        let formattedCardNumber = RyftCardFormatter.format(
            cardNumber: state.cardNumber,
            with: state.cardType
        )
        textField.text = formattedCardNumber

        if var targetPosition = textField.position(
            from: textField.beginningOfDocument,
            offset: targetCursorPosition
        ) {
            if targetCursorPosition != 0 {
                let index = formattedCardNumber.index(
                    formattedCardNumber.startIndex,
                    offsetBy: targetCursorPosition - 1
                )
                let lastChar = formattedCardNumber[index]
                if lastChar == " " && previousTextCount < formattedCardNumber.count {
                    targetPosition = textField.position(
                        from: textField.beginningOfDocument,
                        offset: targetCursorPosition + 1
                    )!
                }
            }
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
        previousTextCount = formattedCardNumber.count
    }

    private func cardValidationState(
        _ textField: UITextField
    ) -> (cardType: RyftCardType, validationState: RyftInputValidationState, cardNumber: String) {
        let cardNumber = RyftCardFormatter.sanitisedOnlyDigits(value: textField.text ?? "")
        let cardType = RyftCardValidation.determineCardType(cardNumber: cardNumber)
        return (
            cardType,
                RyftCardValidation.validate(
                cardNumber: cardNumber,
                with: cardType
            ),
            cardNumber
        )
    }

    private func updateDisplay(
        _ isEmpty: Bool,
        with cardType: RyftCardType,
        and state: RyftInputValidationState
    ) {
        let hasFocus = cardNumberInput.isFirstResponder
        cardIconImage.image = RyftImages.imageFor(cardScheme: cardType.scheme)
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
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = theme.emptyInputBackgroundColor
        layer.borderWidth = 1
        layer.borderColor = theme.unselectedInputBorderColor.cgColor
        addSubview(cardNumberInput)
        cardNumberInput.delegate = self
        setupConstraints()
        accessibilityIdentifier = "RyftCardNumberInputField"
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardIconImage.heightAnchor.constraint(equalToConstant: 17),
            cardIconImage.widthAnchor.constraint(equalToConstant: 25),
            cardNumberInput.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 15
            ),
            cardNumberInput.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -15
            ),
            cardNumberInput.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 5
            ),
            cardNumberInput.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -5
            ),
            cardNumberInput.centerYAnchor.constraint(
                equalTo: centerYAnchor
            )
        ])
    }
}
