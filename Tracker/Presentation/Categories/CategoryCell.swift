import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"

    var anchorView: UIView { containerView }

    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .ypCellBackground
        v.layer.masksToBounds = true
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17, weight: .regular)
        l.textColor = .ypBlack
        return l
    }()

    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "checkmark")
        iv.tintColor = .ypBlue
        iv.isHidden = true
        return iv
    }()

    private let separatorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .ypGray
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(separatorView)

        let onePixel = 1 / UIScreen.main.scale

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 75),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),

            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: onePixel)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.layer.cornerRadius = 0
        containerView.layer.maskedCorners = []
        separatorView.isHidden = false
        checkmarkImageView.isHidden = true
    }

    func configure(title: String, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        applyRoundedCorners(isFirst: isFirst, isLast: isLast)
    }

    private func applyRoundedCorners(isFirst: Bool, isLast: Bool) {
        switch (isFirst, isLast) {
        case (true, true):
            containerView.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            separatorView.isHidden = true
        case (true, false):
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            separatorView.isHidden = false
        case (false, true):
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        case (false, false):
            containerView.layer.maskedCorners = []
            separatorView.isHidden = false
        }
        containerView.layer.cornerRadius = (isFirst || isLast) ? 16 : 0
    }
}

