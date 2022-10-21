import UIKit
import RyftCore
import RyftCard
import PassKit

public protocol RyftDropInPaymentDelegate: AnyObject {
    func onPaymentResult(result: RyftPaymentResult)
}

public final class RyftDropInPaymentViewController: UIViewController {

    public var theme: RyftUITheme = .defaultTheme

    private weak var delegate: RyftDropInPaymentDelegate?
    private let config: RyftDropInConfiguration
    private let apiClient: RyftApiClient
    private let requiredActionComponent: RyftRequiredActionComponent

    private let defaultHeight: CGFloat = 310

    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?

    private var cardDetails = RyftDropInCardDetails.incomplete
    private var transitionHandler: SlidingTransitioningHandler?
    private var applePayComponent: RyftApplePayComponent?

    private lazy var saveCard: Bool = {
        return config.display?.usage == .setupCard
    }()

    private lazy var estimatedHeight: CGFloat = {
        return defaultHeight + (showApplePay ? 40 : 0)
    }()

    private lazy var showApplePay: Bool = {
        RyftUI.supportsApplePay() && config.applePay != nil
    }()

    private lazy var dropInUsage: RyftUI.DropInUsage = {
        config.display?.usage ?? .payment
    }()

    private lazy var containerView: UIView = {
        return DropInViewFactory.createContainerView(theme: theme)
    }()

    private lazy var applePayButton: PKPaymentButton = {
        let button = DropInViewFactory.createApplePayButton()
        button.addTarget(self, action: #selector(applePayClicked), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        return DropInViewFactory.createTitleLabel(usage: dropInUsage)
    }()

    private lazy var titleSeparatorView: UIView = {
        let style = showApplePay
            ? RyftSeparatorView.SeperatorStyle.wordSeparated
            : RyftSeparatorView.SeperatorStyle.singleLine
        let view = RyftSeparatorView(style: style)
        view.theme = theme
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cardNumberInputField: RyftCardNumberInputField = {
        let field = RyftCardNumberInputField()
        field.delegate = self
        field.theme = theme
        return field
    }()

    private lazy var cardExpirationInputField: RyftCardExpirationInputField = {
        let field = RyftCardExpirationInputField()
        field.delegate = self
        field.theme = theme
        return field
    }()

    private lazy var cardCvcInputField: RyftCardCvcInputField = {
        let field = RyftCardCvcInputField()
        field.delegate = self
        field.theme = theme
        return field
    }()

    private lazy var cardExpirationCvcStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardExpirationInputField, cardCvcInputField])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()

    private lazy var saveCardConsentLabel: UILabel = {
        let label = DropInViewFactory.createSaveCardConsentLabel()
        return label
    }()

    private lazy var saveCardView: RyftSaveCardToggleView = {
        let view = DropInViewFactory.createSaveCardToggleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.theme = theme
        return view
    }()

    private lazy var payButton: RyftConfirmButton = {
        return DropInViewFactory.createPayButton(
            customTitle: config.display?.payButtonTitle,
            usage: dropInUsage,
            buttonTap: payClicked
        )
    }()

    private lazy var cancelButton: UIButton = {
        let button = DropInViewFactory.createCancelButton(theme: theme)
        button.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [payButton, cancelButton])
        stackView.axis = .horizontal
        stackView.spacing = 14.0
        stackView.backgroundColor = theme.primaryBackgroundColor
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardNumberInputField, cardExpirationCvcStackView])
        stackView.axis = .vertical
        stackView.spacing = 16.0
        stackView.backgroundColor = theme.primaryBackgroundColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(
        config: RyftDropInConfiguration,
        publicApiKey: String,
        delegate: RyftDropInPaymentDelegate
    ) {
        self.config = config
        self.delegate = delegate
        self.apiClient = DefaultRyftApiClient(publicApiKey: publicApiKey)
        self.requiredActionComponent = RyftRequiredActionComponent(
            config: RyftRequiredActionComponent.Configuration(
                clientSecret: config.clientSecret,
                accountId: config.accountId
            ),
            apiClient: apiClient
        )
        super.init(nibName: nil, bundle: nil)
        self.transitionHandler = SlidingTransitioningHandler(
            presentedViewController: self,
            height: estimatedHeight
        )
        transitioningDelegate = self.transitionHandler
        modalPresentationStyle = .custom
    }

    public init(
        config: RyftDropInConfiguration,
        apiClient: RyftApiClient,
        delegate: RyftDropInPaymentDelegate
    ) {
        self.config = config
        self.apiClient = apiClient
        self.delegate = delegate
        self.requiredActionComponent = RyftRequiredActionComponent(
            config: RyftRequiredActionComponent.Configuration(
                clientSecret: config.clientSecret,
                accountId: config.accountId
            ),
            apiClient: apiClient
        )
        super.init(nibName: nil, bundle: nil)
        self.transitionHandler = SlidingTransitioningHandler(
            presentedViewController: self,
            height: estimatedHeight
        )
        transitioningDelegate = self.transitionHandler
        modalPresentationStyle = .custom
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *),
           traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            cancelButton.layer.borderColor = theme.cancelButtonBorderColor.cgColor
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupKeyboardEvents()
        view.accessibilityIdentifier = "RyftDropIn"
    }

    public func handleRequiredAction(
        returnUrl: String,
        _ action: PaymentSessionRequiredAction
    ) {
        requiredActionComponent.delegate = self
        requiredActionComponent.handle(
            returnUrl: returnUrl,
            action: action
        )
    }

    @objc
    private func cancelClicked() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    @objc
    private func payClicked() {
        view.endEditing(true)
        updateButtonStates(state: .loading)
        apiClient.attemptPayment(
            request: AttemptPaymentRequest.fromCard(
                clientSecret: config.clientSecret,
                number: cardDetails.cardNumber,
                expiryMonth: cardDetails.expirationMonth,
                expiryYear: cardDetails.expirationYear,
                cvc: cardDetails.cvc,
                store: saveCard
            ),
            accountId: config.accountId
        ) { result in
            DispatchQueue.main.async {
                self.handlePaymentResult(result.flatMapError { httpError in
                    .failure(httpError)
                })
            }
        }
    }

    private func handlePaymentResult(_ result: Result<PaymentSession, Error>) {
        var paymentResult = RyftPaymentResult.failed(
            error: RyftPaymentError(paymentSessionError: .unknown)
        )
        var shouldDismiss = true
        switch result {
        case .success(let paymentSession):
            if paymentSession.status == .approved || paymentSession.status == .captured {
                paymentResult = .success(paymentSession: paymentSession)
            }
            if let requiredAction = paymentSession.requiredAction {
                shouldDismiss = false
                paymentResult = .pendingAction(
                    paymentSession: paymentSession,
                    requiredAction: requiredAction
                )
            }
            if let lastError = paymentSession.lastError {
                paymentResult = .failed(
                    error: RyftPaymentError(
                        paymentSessionError: lastError)
                )
            }
        case .failure:
            paymentResult = .failed(
                error: RyftPaymentError(paymentSessionError: .unknown)
            )
        }
        updateButtonStates(state: .enabled)
        invokeDelegate(with: paymentResult, shouldDismiss: shouldDismiss)
    }

    private func invokeDelegate(with result: RyftPaymentResult, shouldDismiss: Bool) {
        if shouldDismiss {
            dismiss(animated: true, completion: nil)
        }
        delegate?.onPaymentResult(result: result)
    }

    private func updateButtonStates(state: RyftConfirmButton.ButtonState) {
        payButton.state = state
        cancelButton.isEnabled = state != .loading
        applePayButton.isEnabled = state != .loading
        transitionHandler?.userInteractionEnabled = state != .loading
    }

    private func updateButtonStatesForApplePay(state: RyftConfirmButton.ButtonState) {
        payButton.state = cardDetails.isValid() ? .enabled : payButton.state
        cancelButton.isEnabled = state == .enabled
        transitionHandler?.userInteractionEnabled = state == .enabled
    }

    private func setupView() {
        view.backgroundColor = .clear
    }

    // swiftlint:disable function_body_length
    private func setupConstraints() {
        view.addSubview(containerView)
        let saveCardView = dropInUsage == .setupCard
            ? saveCardConsentLabel
            : saveCardView
        [titleSeparatorView, containerStackView, saveCardView, buttonStackView].forEach {
            containerView.addSubview($0)
        }

        let leadingAnchorIndent: CGFloat = 20
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        if showApplePay {
            containerView.addSubview(applePayButton)
            NSLayoutConstraint.activate([
                applePayButton.heightAnchor.constraint(equalToConstant: 44),
                applePayButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
                applePayButton.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: leadingAnchorIndent
                ),
                applePayButton.trailingAnchor.constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -leadingAnchorIndent
                )
            ])
        } else {
            containerView.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
                titleLabel.heightAnchor.constraint(equalToConstant: 30),
                titleLabel.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: leadingAnchorIndent
                ),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        }

        let separatorTopAnchorOffset: CGFloat = showApplePay ? 25 : 12
        let separatorTopAnchor = showApplePay ? applePayButton.bottomAnchor : titleLabel.bottomAnchor
        NSLayoutConstraint.activate([
            titleSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            titleSeparatorView.topAnchor.constraint(
                equalTo: separatorTopAnchor,
                constant: separatorTopAnchorOffset
            ),
            titleSeparatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleSeparatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 45),
            containerStackView.topAnchor.constraint(
                equalTo: titleSeparatorView.bottomAnchor,
                constant: 24
            ),
            containerStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -24
            ),
            containerStackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: leadingAnchorIndent
            ),
            containerStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -20
            ),
            saveCardView.topAnchor.constraint(
                equalTo: containerStackView.bottomAnchor,
                constant: 24
            ),
            saveCardView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -20
            ),
            saveCardView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 20
            ),
            buttonStackView.topAnchor.constraint(equalTo: saveCardView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),
            payButton.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 0.7)
        ])
        containerViewHeightConstraint = containerView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: defaultHeight
        )
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: 0
        )
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            cardNumberInputField.heightAnchor.constraint(equalToConstant: 45),
            cardExpirationCvcStackView.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    // swiftlint:enable function_body_length

    private func setupKeyboardEvents() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onShowingKeyboard(_:)),
            name: UIWindow.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onHidingKeyboard(_:)),
            name: UIWindow.keyboardWillHideNotification, object: nil
        )
    }

    @objc
    private func onShowingKeyboard(_ notification: NSNotification) {
        constrainContainerToKeyboard(notification, keyboardWillShow: true)
    }

    @objc
    private func onHidingKeyboard(_ notification: NSNotification) {
        constrainContainerToKeyboard(notification, keyboardWillShow: false)
    }

    private func constrainContainerToKeyboard(
        _ notification: NSNotification,
        keyboardWillShow: Bool
    ) {
        let keyboardSize = (notification.userInfo?[UIWindow.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height ?? 300
        let updatedHeightPresentationHeight = keyboardWillShow ? defaultHeight + keyboardHeight : defaultHeight
        containerViewBottomConstraint?.constant = keyboardWillShow ? -keyboardHeight : 0
        transitionHandler?.height = updatedHeightPresentationHeight
        UIView.animate(withDuration: 0.1) {
          self.view.layoutIfNeeded()
        }
    }

    @objc
    func applePayClicked() {
        guard let applePayConfig = config.applePay else {
            return
        }
        self.applePayComponent = RyftApplePayComponent(
            clientSecret: config.clientSecret,
            accountId: config.accountId,
            config: .auto(config: applePayConfig),
            delegate: self,
            apiClient: apiClient
        )
        applePayButton.isEnabled = false
        updateButtonStatesForApplePay(state: .disabled)
        applePayComponent?.present { presented in
            if !presented {
                self.present(DropInViewFactory.createAlert(
                    message: NSLocalizedStringUtility.applePayPresentError,
                    defaultActionHandler: { _ in
                        self.applePayClicked()
                    }),
                    animated: true
                )
                self.applePayButton.isEnabled = true
                self.updateButtonStatesForApplePay(state: .enabled)
            }
        }
    }
}

extension RyftDropInPaymentViewController: RyftApplePayComponentDelegate {

    public func applePayPayment(
        finishedWith status: RyftApplePayComponent.RyftApplePayPaymentStatus
    ) {
        applePayButton.isEnabled = true
        updateButtonStatesForApplePay(state: .enabled)
        switch status {
        case .cancelled:
            break
        case .success(let paymentSession):
            invokeDelegate(
                with: .success(paymentSession: paymentSession),
                shouldDismiss: true
            )
        case .error(_, let paymentError):
            let ryftError = paymentError ?? .init(paymentSessionError: .unknown)
            invokeDelegate(
                with: .failed(error: ryftError),
                shouldDismiss: true
            )
        }
    }
}

extension RyftDropInPaymentViewController: RyftCardNumberInputProtocol,
    RyftCardExpirationInputProtocol,
    RyftCardCvcInputProtocol,
    SaveCardToggleProtocol {

    func onCardNumberChanged(
        cardNumber: String,
        cardType: RyftCardType,
        state: RyftInputValidationState
    ) {
        cardCvcInputField.cardType = cardType
        cardDetails = cardDetails.with(cardNumber: cardNumber, and: state)
        updatePayButton(cardIsValid: cardDetails.isValid())
        if state == .valid && cardDetails.expirationState != .valid {
            _ = cardExpirationInputField.becomeFirstResponder()
        }
    }

    func onCardExpirationChanged(
        expirationMonth: String,
        expirationYear: String,
        state: RyftInputValidationState
    ) {
        cardDetails = cardDetails.with(
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            and: state
        )
        updatePayButton(cardIsValid: cardDetails.isValid())
        if state == .valid && cardDetails.cvcState != .valid {
            _ = cardCvcInputField.becomeFirstResponder()
        }
    }

    func onCvcChanged(
        cvc: String,
        state: RyftInputValidationState
    ) {
        cardDetails = cardDetails.with(cvc: cvc, and: state)
        updatePayButton(cardIsValid: cardDetails.isValid())
    }

    func onSaveCardToggleClicked(isSelected: Bool) {
        self.saveCard = isSelected
    }

    private func updatePayButton(cardIsValid: Bool) {
        payButton.state = cardIsValid ? .enabled : .disabled
    }
}

extension RyftDropInPaymentViewController: RyftRequiredActionDelegate {

    public func onRequiredActionInProgress() {
        updateButtonStates(state: .loading)
    }
    
    public func onRequiredActionHandled(result: Result<PaymentSession, Error>) {
        DispatchQueue.main.async {
            self.handlePaymentResult(result)
        }
    }
}
