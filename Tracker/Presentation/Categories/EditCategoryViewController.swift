import UIKit

final class EditCategoryViewController: UIViewController {

    var initialTitle: String = ""
    var onDone: ((String) -> Void)?

    private let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Введите название категории"
        tf.layer.cornerRadius = 16
        tf.backgroundColor = .ypLightGray
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftViewMode = .always
        return tf
    }()

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Готово", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .ypGray
        b.layer.cornerRadius = 16
        b.isEnabled = false
        b.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        title = "Редактирование категории"

        textField.text = initialTitle
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        view.addSubview(textField)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        updateButtonState()
    }

    @objc private func textChanged() {
        updateButtonState()
    }

    private func updateButtonState() {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let enabled = !text.isEmpty

        doneButton.isEnabled = enabled
        doneButton.backgroundColor = enabled ? .ypBlack : .ypGray
    }

    @objc private func doneTapped() {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        onDone?(text)
        dismiss(animated: true)
    }
}

