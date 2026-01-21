import UIKit

final class StatisticsCardView: UIView {

    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    private let borderLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()

    init(title: String) {
        super.init(frame: .zero)
        setupUI(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
        maskLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        ).cgPath
    }

    func setValue(_ value: Int) {
        valueLabel.text = "\(value)"
    }

    private func setupUI(title: String) {
        layer.cornerRadius = 16
        layer.masksToBounds = true

        borderLayer.colors = [
            UIColor(red: 0.98, green: 0.38, blue: 0.33, alpha: 1).cgColor,
            UIColor(red: 0.40, green: 0.30, blue: 0.99, alpha: 1).cgColor,
            UIColor(red: 0.33, green: 0.87, blue: 0.99, alpha: 1).cgColor
        ]
        borderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        borderLayer.endPoint = CGPoint(x: 1, y: 0.5)

        maskLayer.lineWidth = 1
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        borderLayer.mask = maskLayer

        layer.addSublayer(borderLayer)
        let contentView = UIView()
        contentView.backgroundColor = .ypBackground
        contentView.layer.cornerRadius = 16
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1)
        ])

        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .ypBlack
        valueLabel.text = "0"
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .ypBlack
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(valueLabel)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}

