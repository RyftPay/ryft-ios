import UIKit

final class RyftConfirmButton: UIView {

    enum ButtonState {
        case enabled
        case disabled
        case loading
    }

    private lazy var buttonLoadingSpinner: RyftLoadingSpinnerView = {
        let spinner = RyftLoadingSpinnerView()
        spinner.alpha = 0
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.accessibilityIdentifier = "RyftConfirmButton-LoadingSpinner"
        return spinner
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedStringUtility.payNow, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = tintColor
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(netHex: 0x1E6CC0).cgColor
        button.clipsToBounds = true
        button.isEnabled = false
        button.titleLabel?.alpha = 0.7
        button.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
        button.addSubview(buttonLoadingSpinner)
        button.accessibilityIdentifier = "RyftConfirmButton-UIButton"
        return button
    }()

    var state = ButtonState.disabled {
        didSet {
            update(state: state)
        }
    }

    private let buttonTap: () -> Void

    init(title: String, buttonTap: @escaping () -> Void) {
        self.buttonTap = buttonTap
        super.init(frame: .zero)
        button.setTitle(title, for: .normal)

        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3

        let views = ["button": button]
        views.values.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonLoadingSpinner.heightAnchor.constraint(equalToConstant: 20),
            buttonLoadingSpinner.widthAnchor.constraint(equalToConstant: 20),
            buttonLoadingSpinner.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            buttonLoadingSpinner.centerXAnchor.constraint(equalTo: button.centerXAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update(state: ButtonState) {
        button.isEnabled = state == .enabled
        buttonLoadingSpinner.alpha = state == .loading ? 1 : 0

        switch state {
        case .enabled:
            button.titleLabel?.alpha = 1
        case .disabled:
            button.titleLabel?.alpha = 0.7
        case .loading:
            button.titleLabel?.alpha = 0
            buttonLoadingSpinner.startAnimating()
        }
    }

    @objc
    private func onButtonTap() {
        if case .enabled = state {
            buttonTap()
        }
    }
}
