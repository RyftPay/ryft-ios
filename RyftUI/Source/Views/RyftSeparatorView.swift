import UIKit

final class RyftSeparatorView: UIView {

    enum SeperatorStyle {
        case singleLine
        case wordSeparated
    }

    var theme: RyftUITheme = .defaultTheme
    var style: SeperatorStyle = .singleLine

    private lazy var viewLeft: UIView = {
        let view = UIView()
        view.backgroundColor = theme.separatorLineColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var middleLabel: UILabel = {
        let label = DropInViewFactory.createOrLabel()
        label.textColor = theme.separatorMiddleLabelColor
        label.accessibilityIdentifier = "RyftSeparatorMiddleLabel"
        return label
    }()

    private lazy var viewRight: UIView = {
        let view = UIView()
        view.backgroundColor = theme.separatorLineColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(style: SeperatorStyle) {
        super.init(frame: .zero)
        setupViews(style)
        setupConstraints(style)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews(_ style: SeperatorStyle) {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(viewLeft)
        if style == .wordSeparated {
            addSubview(middleLabel)
            addSubview(viewRight)
        }
        setupConstraints(style)
        accessibilityIdentifier = "RyftSeparatorView"
    }

    private func setupConstraints(_ style: SeperatorStyle) {
        var constraints: [NSLayoutConstraint] = []
        switch style {
        case .singleLine:
            constraints = [
                viewLeft.heightAnchor.constraint(equalToConstant: 1),
                viewLeft.leadingAnchor.constraint(equalTo: leadingAnchor),
                viewLeft.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
        case .wordSeparated:
            constraints = [
                viewLeft.heightAnchor.constraint(equalToConstant: 1),
                viewRight.heightAnchor.constraint(equalToConstant: 1),
                viewLeft.leadingAnchor.constraint(equalTo: leadingAnchor),
                viewRight.trailingAnchor.constraint(equalTo: trailingAnchor),
                middleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                middleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                middleLabel.leadingAnchor.constraint(equalTo: viewLeft.trailingAnchor, constant: 12),
                middleLabel.trailingAnchor.constraint(equalTo: viewRight.leadingAnchor, constant: -12)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
}
