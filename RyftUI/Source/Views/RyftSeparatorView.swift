import UIKit

final class RyftSeparatorView: UIView {

    var theme: RyftUITheme = .defaultTheme

    private lazy var viewLeft: UIView = {
        let view = UIView()
        view.backgroundColor = theme.separatorLineColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var middleLabel: UILabel = {
        let label = DropInViewFactory.createOrLabel()
        label.textColor = theme.separatorMiddleLabelColor
        return label
    }()

    private lazy var viewRight: UIView = {
        let view = UIView()
        view.backgroundColor = theme.separatorLineColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(viewLeft)
        addSubview(middleLabel)
        addSubview(viewRight)
        setupConstraints()
        accessibilityIdentifier = "RyftSeparatorView"
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            viewLeft.heightAnchor.constraint(equalToConstant: 1),
            viewRight.heightAnchor.constraint(equalToConstant: 1),
            viewLeft.leadingAnchor.constraint(equalTo: leadingAnchor),
            viewRight.trailingAnchor.constraint(equalTo: trailingAnchor),
            middleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            middleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            middleLabel.leadingAnchor.constraint(equalTo: viewLeft.trailingAnchor, constant: 12),
            middleLabel.trailingAnchor.constraint(equalTo: viewRight.leadingAnchor, constant: -12)
        ])
    }
}
