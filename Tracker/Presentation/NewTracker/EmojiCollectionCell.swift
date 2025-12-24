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

    override var isSelected: Bool {
        didSet { updateSelection() }
    }

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

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        updateSelection()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        updateSelection()
    }

    func configure(emoji: String) {
        label.text = emoji
        updateSelection()
    }

    private func updateSelection() {
        contentView.backgroundColor = isSelected ? UIColor.systemGray5 : .clear
    }
}

