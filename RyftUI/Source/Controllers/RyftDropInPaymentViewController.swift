import UIKit
import RyftCore
import RyftCard

public protocol RyftDropInPaymentDelegate: AnyObject {
    func onPaymentResult(result: RyftPaymentResult)
}

public final class RyftDropInPaymentViewController: UIViewController {

    public var theme: RyftUITheme = .defaultTheme

    private weak var delegate: RyftDropInPaymentDelegate?
    private let config: RyftDropInConfiguration
    private let apiClient: RyftApiClient

    private let defaultHeight: CGFloat = 310

    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?

    private var cardDetails = RyftDropInCardDetails.incomplete
    private var transitionHandler: SlidingTransitioningHandler?

    private lazy var containerView: UIView = {
        return DropInViewFactory.createContainerView(theme: theme)
    }()

    private lazy var titleLabel: UILabel = {
        return DropInViewFactory.createTitleLabel()
    }()

    private lazy var titleSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = theme.separatorLineColor
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

    private lazy var paySeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = theme.separatorLineColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var payButton: RyftConfirmButton = {
        return DropInViewFactory.createPayButton(
            customTitle: config.display?.payButtonTitle ?? NSLocalizedStringUtility.payNow,
            buttonTap: payClicked
        )
    }()

    private lazy var cancelButton: UIButton = {
        let button = DropInViewFactory.createCancelButton(theme: theme)
        button.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                payButton,
                cancelButton
            ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 14.0
        stackView.backgroundColor = theme.primaryBackgroundColor
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                cardNumberInputField,
                cardExpirationCvcStackView
            ]
        )
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
        super.init(nibName: nil, bundle: nil)
    }

    public init(
        config: RyftDropInConfiguration,
        apiClient: RyftApiClient,
        delegate: RyftDropInPaymentDelegate
    ) {
        self.config = config
        self.apiClient = apiClient
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.transitionHandler = SlidingTransitioningHandler(
            presentedViewController: self,
            height: defaultHeight
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

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    public func handleRequiredAction(
        returnUrl: String,
        _ action: PaymentSessionRequiredAction
    ) {
        let threeDsView = RyftThreeDSecureViewController(
            returnUrl: URL(string: returnUrl)!,
            authUrl: URL(string: action.url)!,
            delegate: self
        )
        present(threeDsView, animated: true, completion: nil)
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
                cvc: cardDetails.cvc
            ),
            accountId: config.accountId
        ) { result in
            DispatchQueue.main.async {
                self.handlePaymentResult(result)
            }
        }
    }

    private func handlePaymentResult(_ result: Result<PaymentSession, HttpError>) {
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
        if shouldDismiss {
            dismiss(animated: true, completion: nil)
        }
        delegate?.onPaymentResult(result: paymentResult)
    }

    private func updateButtonStates(state: RyftConfirmButton.ButtonState) {
        payButton.state = state
        cancelButton.isEnabled = state != .loading
        transitionHandler?.userInteractionEnabled = state != .loading
    }

    private func setupView() {
        view.backgroundColor = .clear
    }

    // swiftlint:disable function_body_length
    private func setupConstraints() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(titleSeparatorView)
        containerView.addSubview(containerStackView)
        containerView.addSubview(paySeparatorView)
        containerView.addSubview(buttonStackView)

        let leadingAnchorIndent: CGFloat = 20
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: leadingAnchorIndent
            ),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            titleSeparatorView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 12
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
            paySeparatorView.heightAnchor.constraint(equalToConstant: 1),
            paySeparatorView.topAnchor.constraint(
                equalTo: containerStackView.bottomAnchor,
                constant: 24
            ),
            paySeparatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            paySeparatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: paySeparatorView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 20
            ),
            buttonStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -20
            ),
            payButton.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 0.7)
        ])
        containerViewHeightConstraint = containerView.heightAnchor.constraint(
            equalToConstant: defaultHeight
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
}

extension RyftDropInPaymentViewController: RyftCardNumberInputProtocol,
    RyftCardExpirationInputProtocol,
    RyftCardCvcInputProtocol {

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

    private func updatePayButton(cardIsValid: Bool) {
        payButton.state = cardIsValid ? .enabled : .disabled
    }
}

extension RyftDropInPaymentViewController: RyftThreeDSecureWebDelegate {

    func onThreeDsCompleted(
        paymentSessionId: String,
        queryParams: [String: String]
    ) {
        updateButtonStates(state: .loading)
        apiClient.getPaymentSession(
            id: paymentSessionId,
            clientSecret: config.clientSecret,
            accountId: config.accountId
        ) { result in
            DispatchQueue.main.async {
                self.handlePaymentResult(result)
            }
        }
    }
}
