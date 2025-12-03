import UIKit

final class EnterNameCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "EnterNameReuseIdentifier"
    
    // MARK: - Delegate
    
    weak var delegate: EnterNameCellDelegate?
    
    // MARK: - Views
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .ypBlack
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .go
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.text = "Ограничение 38 символов"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [containerView, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private let maxCharacters = 38
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        configDependencies()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        nameTextField.delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(stackView)
        containerView.addSubview(nameTextField)
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        [
            nameTextField,
            containerView,
            errorLabel,
            stackView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            containerView.heightAnchor.constraint(equalToConstant: 75),
            containerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            errorLabel.heightAnchor.constraint(equalToConstant: 38),
            
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            nameTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChanged), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc private func nameTextFieldEditingChanged() {
        let text = nameTextField.text ?? ""
        errorLabel.isHidden = !isTooLong(string: text)
        performTableViewUpdates()
        delegate?.enterNameCell(self, didChangeText: text)
    }
    
    // MARK: - Private Methods
    
    private func performTableViewUpdates() {
        delegate?.updateCellLayout()
    }
    
    private func isTooLong(string: String) -> Bool {
        return string.count > maxCharacters
    }
}

// MARK: - UITextFieldDelegate

extension EnterNameCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let isLong = isTooLong(string: updatedText)
        if isLong {
            errorLabel.isHidden = !isLong
            performTableViewUpdates()
        }
        return !isLong
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

