import UIKit

final class CustomizationHeaderView: UICollectionReusableView {
    static let reuseID = "CustomizationHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) {
        titleLabel.text = title
    }
}

