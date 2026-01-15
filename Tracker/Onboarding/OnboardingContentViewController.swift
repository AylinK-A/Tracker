import UIKit

final class OnboardingContentViewController: UIViewController {

    // MARK: - Public
    var onButtonTap: (() -> Void)?

    // MARK: - Private
    private let model: OnboardingPageModel

    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(model.buttonTitle, for: .normal)

        button.backgroundColor = .ypBlackrealy
        button.setTitleColor(.ypRealyWhite, for: .normal)

        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true

        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Init
    init(model: OnboardingPageModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .ypBackground

        backgroundImageView.image = UIImage(named: model.backgroundImageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        titleLabel.text = model.title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .ypBlack

        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(actionButton)

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            actionButton.heightAnchor.constraint(equalToConstant: 60),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }

    // MARK: - Actions
    @objc private func didTapButton() {
        onButtonTap?()
    }
}

