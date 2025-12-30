import UIKit

final class DeleteCategoryConfirmViewController: UIViewController {

    // MARK: - Public
    var onDelete: (() -> Void)?

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.text = "Эта категория точно не нужна?"
        return label
    }()

    private lazy var deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Удалить", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        b.setTitleColor(.ypRed, for: .normal)
        b.backgroundColor = .clear
        b.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return b
    }()

    private lazy var cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Отменить", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        b.setTitleColor(.ypBlue, for: .normal)
        b.backgroundColor = .clear
        b.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return b
    }()

    private let separatorTop: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .ypGray
        return v
    }()

    private let separatorMid: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .ypGray
        return v
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupUI()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(separatorTop)
        view.addSubview(deleteButton)
        view.addSubview(separatorMid)
        view.addSubview(cancelButton)

        let onePixel = 1 / UIScreen.main.scale

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            separatorTop.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            separatorTop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorTop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorTop.heightAnchor.constraint(equalToConstant: onePixel),

            deleteButton.topAnchor.constraint(equalTo: separatorTop.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 60),

            separatorMid.topAnchor.constraint(equalTo: deleteButton.bottomAnchor),
            separatorMid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorMid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorMid.heightAnchor.constraint(equalToConstant: onePixel),

            cancelButton.topAnchor.constraint(equalTo: separatorMid.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Actions
    @objc private func deleteTapped() {
        dismiss(animated: true)
        onDelete?()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

