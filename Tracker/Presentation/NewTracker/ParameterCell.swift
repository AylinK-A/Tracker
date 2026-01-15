import UIKit

final class ParameterCell: UITableViewCell {

    // MARK: - Identifier

    static let reuseID = "ParametersReuseIdentifier"

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevron
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()

    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [vStackView, UIView(), iconImageView])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypCellBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        selectionStyle = .none

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubviews([hStackView, separatorView])

        setupConstraints()
    }

    private func setupConstraints() {
        [
            containerView, hStackView, vStackView,
            titleLabel, subtitleLabel, iconImageView, separatorView
        ].disableAutoresizingMasks()

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),

            containerView.heightAnchor.constraint(equalToConstant: 75),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            hStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            hStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            hStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    // MARK: - Public

    func configure(parameter: NewTrackerParameter) {
        titleLabel.text = parameter.title
        subtitleLabel.text = parameter.subtitle
        subtitleLabel.isHidden = parameter.subtitle.isEmpty

        if parameter.isFirst {
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        if parameter.isLast {
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        } else {
            separatorView.isHidden = false
        }
    }
}

