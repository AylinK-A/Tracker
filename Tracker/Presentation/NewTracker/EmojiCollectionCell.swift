import UIKit

final class EmojiCollectionCell: UICollectionViewCell {

    static let reuseID = "EmojiCollectionCell"

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32)
        l.textAlignment = .center
        l.isUserInteractionEnabled = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // базовый вид
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .clear

        // ВАЖНО: выделение через selectedBackgroundView — самый надежный способ
        let selected = UIView(frame: bounds)
        selected.layer.cornerRadius = 16
        selected.layer.masksToBounds = true
        selected.backgroundColor = UIColor.systemGray5
        selectedBackgroundView = selected
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.frame = bounds
    }

    func configure(emoji: String) {
        label.text = emoji
    }
}

