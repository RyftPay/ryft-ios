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
        return DropInViewFactory.createOrLabel()
    }()

    private lazy var viewRight: UIView = {
        let view = UIView()
        view.backgroundColor = theme.separatorLineColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func setupConstraints() {
        NSLayoutConstraint.activate([
//            cardIconImage.heightAnchor.constraint(equalToConstant: 17),
//            cardIconImage.widthAnchor.constraint(equalToConstant: 25),
//            cardNumberInput.leadingAnchor.constraint(
//                equalTo: leadingAnchor,
//                constant: 15
//            ),
//            cardNumberInput.trailingAnchor.constraint(
//                equalTo: trailingAnchor,
//                constant: -15
//            ),
//            cardNumberInput.topAnchor.constraint(
//                equalTo: topAnchor,
//                constant: 5
//            ),
//            cardNumberInput.bottomAnchor.constraint(
//                equalTo: bottomAnchor,
//                constant: -5
//            ),
//            cardNumberInput.centerYAnchor.constraint(
//                equalTo: centerYAnchor
//            )
        ])
    }
}
