import UIKit

protocol CustomizationCellDelegate: AnyObject {
    func customizationCell(_ cell: CustomizationCell, didPickEmoji emoji: String)
    func customizationCell(_ cell: CustomizationCell, didPickColor color: UIColor)
}

final class CustomizationCell: UITableViewCell {

    static let reuseID = "CustomizationCell"

    weak var delegate: CustomizationCellDelegate?

    private enum Section: Int, CaseIterable {
        case emoji
        case color
    }

    private let emojis: [String] = ["🙂","😻","🌺","🐶","❤️","😱",
                                    "😇","😡","🥶","🤔","🙌","🍔",
                                    "🥦","🏓","🥇","🎸","🏝","😪"]

    private let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]

    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?

    private var collectionHeightConstraint: NSLayoutConstraint?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = false

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false

        cv.allowsSelection = true
        cv.allowsMultipleSelection = true

        cv.dataSource = self
        cv.delegate = self

        cv.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: EmojiCollectionCell.reuseID)
        cv.register(ColorCollectionCell.self, forCellWithReuseIdentifier: ColorCollectionCell.reuseID)
        cv.register(CustomizationHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: CustomizationHeaderView.reuseID)
        return cv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        let h = collectionView.heightAnchor.constraint(equalToConstant: 1)
        h.isActive = true
        collectionHeightConstraint = h
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        collectionHeightConstraint?.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        layoutIfNeeded()
        let height = contentView.systemLayoutSizeFitting(
            CGSize(width: targetSize.width, height: UIView.layoutFittingCompressedSize.height)
        ).height
        return CGSize(width: targetSize.width, height: height)
    }

    func configure(selectedEmoji: String, selectedColor: UIColor?) {
        selectedEmojiIndex = emojis.firstIndex(of: selectedEmoji)

        if let selectedColor {
            selectedColorIndex = colors.firstIndex(where: { $0.isEqual(selectedColor) })
        } else {
            selectedColorIndex = nil
        }

        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        if let selectedEmojiIndex {
            let ip = IndexPath(item: selectedEmojiIndex, section: Section.emoji.rawValue)
            collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
        }

        if let selectedColorIndex {
            let ip = IndexPath(item: selectedColorIndex, section: Section.color.rawValue)
            collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
        }

        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource / Delegate / FlowLayout

extension CustomizationCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .emoji: return emojis.count
        case .color: return colors.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }

        switch section {
        case .emoji:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionCell.reuseID,
                for: indexPath
            ) as? EmojiCollectionCell else {
                return UICollectionViewCell()
            }

            cell.configure(emoji: emojis[indexPath.item])
            return cell

        case .color:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionCell.reuseID,
                for: indexPath
            ) as? ColorCollectionCell else {
                return UICollectionViewCell()
            }

            cell.configure(
                color: colors[indexPath.item],
                isSelected: indexPath.item == selectedColorIndex
            )
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .emoji:
            if let prev = selectedEmojiIndex, prev != indexPath.item {
                collectionView.deselectItem(
                    at: IndexPath(item: prev, section: Section.emoji.rawValue),
                    animated: false
                )
            }
            selectedEmojiIndex = indexPath.item
            delegate?.customizationCell(self, didPickEmoji: emojis[indexPath.item])

        case .color:
            if let prev = selectedColorIndex, prev != indexPath.item {
                collectionView.deselectItem(
                    at: IndexPath(item: prev, section: Section.color.rawValue),
                    animated: false
                )
            }
            selectedColorIndex = indexPath.item

            collectionView.reloadSections(IndexSet(integer: Section.color.rawValue))
            delegate?.customizationCell(self, didPickColor: colors[indexPath.item])
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .emoji:
            if selectedEmojiIndex == indexPath.item {
                let ip = IndexPath(item: indexPath.item, section: Section.emoji.rawValue)
                collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
            }
        case .color:
            if selectedColorIndex == indexPath.item {
                let ip = IndexPath(item: indexPath.item, section: Section.color.rawValue)
                collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
            }
        }
    }

    // Header
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CustomizationHeaderView.reuseID,
            for: indexPath
        ) as? CustomizationHeaderView else {
            return UICollectionReusableView()
        }

        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }

        header.configure(title: section == .emoji ? "Emoji" : "Цвет")
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 6
        let width = floor(collectionView.bounds.width / columns)
        return CGSize(width: width, height: 52)
    }
}

