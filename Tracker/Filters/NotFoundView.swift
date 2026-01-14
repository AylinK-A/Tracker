import UIKit

final class NotFoundView: UIStackView {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .notFound 
        return iv
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        alignment = .center
        spacing = 8
        addArrangedSubview(imageView)
        addArrangedSubview(label)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

