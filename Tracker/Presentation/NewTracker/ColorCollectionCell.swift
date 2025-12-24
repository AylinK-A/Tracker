import UIKit

final class ColorCollectionCell: UICollectionViewCell {
    static let reuseID = "ColorCollectionCell"

    private let colorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor)
        ])

        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true

        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color

        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}

