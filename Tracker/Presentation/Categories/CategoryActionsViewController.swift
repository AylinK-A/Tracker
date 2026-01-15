import UIKit

final class CategoryActionsViewController: UIViewController {

    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let separator = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        editButton.setTitle("Редактировать", for: .normal)
        editButton.setTitleColor(.ypBlack, for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 17)
        editButton.contentHorizontalAlignment = .left
        editButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.setTitleColor(.ypRed, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 17)
        deleteButton.contentHorizontalAlignment = .left
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        separator.backgroundColor = .ypGray

        [editButton, separator, deleteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: view.topAnchor),
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 60),

            separator.topAnchor.constraint(equalTo: editButton.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            deleteButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 60),
            deleteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func editTapped() {
        dismiss(animated: true)
        onEdit?()
    }

    @objc private func deleteTapped() {
        dismiss(animated: true)
        onDelete?()
    }
}

