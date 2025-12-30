import UIKit

final class OnboardingContentViewController: UIViewController {

    // MARK: - Public
    var onButtonTap: (() -> Void)?

    // MARK: - Private
    private let model: OnboardingPageModel

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = .ypBlack
        b.layer.cornerRadius = 16
        b.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Init
    init(model: OnboardingPageModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyModel()
    }

    private func applyModel() {
        backgroundImageView.image = UIImage(named: model.backgroundImageName)
        titleLabel.text = model.title
        actionButton.setTitle(model.buttonTitle, for: .normal)
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 69),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func buttonTapped() {
        onButtonTap?()
    }
}

