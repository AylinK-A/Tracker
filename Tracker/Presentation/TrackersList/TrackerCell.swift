import UIKit

final class TrackerCell: UICollectionViewCell {

    // MARK: - Identifier

    static let reuseID = "TrackerCellReuseIdentifier"

    // MARK: - Delegate

    weak var delegate: TrackerCellDelegate?

    // MARK: - Private

    private let emojiBadgeColor: UIColor = UIColor.white.withAlphaComponent(0.30)

    // MARK: - Views

    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = fillColor
        return view
    }()

    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = .ypWhite
        imageView.isHidden = true
        return imageView
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 1

        label.backgroundColor = emojiBadgeColor
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12

        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private lazy var quanityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = getDayString(quanity)
        return label
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton()
        let image = UIImage.plusButton.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = fillColor
        return button
    }()

    private lazy var quanityStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [quanityLabel, UIView(), completeButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 16, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    // MARK: - Private Properties

    private var quanity: Int = 0 {
        didSet { quanityLabel.text = getDayString(quanity) }
    }

    private var fillColor: UIColor = .ypGray {
        didSet {
            cardView.backgroundColor = fillColor
            completeButton.tintColor = fillColor
        }
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        contentView.addSubviews([
            cardView,
            quanityStackView
        ])

        cardView.addSubviews([
            emojiLabel,
            titleLabel,
            pinImageView
        ])

        setupConstraints()
        setupActions()
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        [
            cardView,
            emojiLabel,
            titleLabel,
            pinImageView,
            quanityLabel,
            completeButton,
            quanityStackView
        ].disableAutoresizingMasks()

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            quanityStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            quanityStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            quanityStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            quanityStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),

            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalTo: emojiLabel.widthAnchor),
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),

            pinImageView.widthAnchor.constraint(equalToConstant: 12),
            pinImageView.heightAnchor.constraint(equalTo: pinImageView.widthAnchor),
            pinImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),
        ])
    }

    // MARK: - Setup Actions

    private func setupActions() {
        completeButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func plusButtonTapped() {
        delegate?.completeButtonDidTap(in: self)
    }

    // MARK: - Public Methods

    func configure(from tracker: Tracker, isCompleted: Bool, quanity: Int, isPinned: Bool) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        fillColor = tracker.color
        self.quanity = quanity

        emojiLabel.backgroundColor = emojiBadgeColor

        pinImageView.isHidden = !isPinned

        let plusImage = UIImage.plusButton.withRenderingMode(.alwaysTemplate)
        let doneImage = UIImage.doneButton.withRenderingMode(.alwaysTemplate)
        completeButton.setImage(isCompleted ? doneImage : plusImage, for: .normal)
    }

    // MARK: - Private Methods

    private func getDayString(_ value: Int) -> String {
        let lang = Locale.current.languageCode ?? "en"

        if lang != "ru" {
            let key = (value == 1) ? "days_one" : "days_many"
            return "\(value) " + NSLocalizedString(key, comment: "")
        }

        let mod10 = value % 10
        let mod100 = value % 100

        let key: String
        if (11...14).contains(mod100) {
            key = "days_many"
        } else if mod10 == 1 {
            key = "days_one"
        } else if (2...4).contains(mod10) {
            key = "days_few"
        } else {
            key = "days_many"
        }

        return "\(value) " + NSLocalizedString(key, comment: "")
    }

}

