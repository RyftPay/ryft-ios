import UIKit

protocol SaveCardToggleProtocol: AnyObject {
    func onSaveCardToggleClicked(isSelected: Bool)
}

final class RyftSaveCardToggleView: UIView {

    var theme: RyftUITheme = .defaultTheme

    weak var delegate: SaveCardToggleProtocol?

    private var isSelected: Bool = false

    private lazy var checkbox: UIImageView = {
        let imageView = UIImageView()
        imageView.image = RyftImages.checkboxUnselected
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var optInLabel: UILabel = {
        return DropInViewFactory.createSaveCardLabel()
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [checkbox, optInLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        setupConstraints()
        addCheckboxTap()
        accessibilityIdentifier = "RyftSaveCardToggleView"
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            checkbox.topAnchor.constraint(equalTo: topAnchor),
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkbox.bottomAnchor.constraint(equalTo: bottomAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 16),
            checkbox.heightAnchor.constraint(equalToConstant: 16),
            optInLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 10)
        ])
    }

    private func addCheckboxTap() {
        let tapGuesture = UITapGestureRecognizer(
            target: self,
            action: #selector(checkboxClicked(_:))
        )
        checkbox.addGestureRecognizer(tapGuesture)
    }

    private func updateCheckboxImage() {
        let image = isSelected ? RyftImages.checkboxSelected : RyftImages.checkboxUnselected
        checkbox.image = image
    }

    @objc private func checkboxClicked(_ tap: UIGestureRecognizer) {
        isSelected = !isSelected
        updateCheckboxImage()
        delegate?.onSaveCardToggleClicked(isSelected: isSelected)
    }
}
