import UIKit

final class NewTrackerViewController: UIViewController {

    // MARK: - Delegate

    weak var delegate: NewTrackerViewControllerDelegate?

    // MARK: - Edit/Create Mode

    enum Mode {
        case create
        case edit(trackerID: UUID, completedDays: Int)
    }

    private let mode: Mode

    // MARK: - Types

    private enum SectionType: Int, CaseIterable {
        case enterName
        case parameters
        case customization
    }

    private enum ParameterType: Int, CaseIterable {
        case category
        case schedule
    }

    // MARK: - Views

    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)

        tableView.register(EnterNameCell.self, forCellReuseIdentifier: EnterNameCell.reuseID)
        tableView.register(ParameterCell.self, forCellReuseIdentifier: ParameterCell.reuseID)
        tableView.register(CustomizationCell.self, forCellReuseIdentifier: CustomizationCell.reuseID)

        tableView.backgroundColor = .ypWhite
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.keyboardDismissMode = .onDrag

        return tableView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Отменить", for: .normal)

        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true

        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Создать", for: .normal)

        // ✅ текст должен быть всегда видимым
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true

        button.isEnabled = false
        // фон выставим через updateCreateButtonUI()
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - State

    private var state = NewTrackerState(
        title: "",
        categoryTitle: "",
        schedule: [],
        emoji: "",
        color: nil
    ) {
        didSet {
            updateCreateButtonUI()
        }
    }

    private let scheduleVC = ScheduleViewController()

    // MARK: - Init

    init(mode: Mode, initialState: NewTrackerState? = nil) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)

        if let initialState {
            self.state = initialState
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        view.backgroundColor = .ypWhite

        tableView.dataSource = self
        tableView.delegate = self
        scheduleVC.delegate = self

        switch mode {
        case .create:
            navigationItem.title = "Новая привычка"
            createButton.setTitle("Создать", for: .normal)
            daysLabel.isHidden = true

        case .edit(_, let completedDays):
            navigationItem.title = "Редактирование привычки"
            createButton.setTitle("Сохранить", for: .normal)
            daysLabel.isHidden = false
            daysLabel.text = "\(completedDays) \(pluralDays(completedDays))"
        }

        view.addSubview(daysLabel)
        view.addSubview(tableView)
        view.addSubview(buttonStackView)

        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            daysLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            daysLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daysLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),

            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        setupActions()
        setupBackgroundTap()

        updateCreateButtonUI()
    }

    private func updateCreateButtonUI() {
        createButton.isEnabled = state.isReady

        if state.isReady {
            createButton.backgroundColor = .black
        } else {
            createButton.backgroundColor = UIColor { trait in
                trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.26, alpha: 1)
                : UIColor(white: 0.80, alpha: 1)
            }
        }
    }

    private func setupBackgroundTap() {
        let backgroundView = UIView()

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        tap.cancelsTouchesInView = false

        backgroundView.addGestureRecognizer(tap)
        tableView.backgroundView = backgroundView
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapBackground() {
        view.endEditing(true)
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapCreate() {
        switch mode {
        case .create:
            delegate?.createTracker(from: state)
        case .edit(let trackerID, _):
            delegate?.updateTracker(id: trackerID, from: state)
        }
        dismiss(animated: true)
    }

    // MARK: - Private

    private func pluralDays(_ value: Int) -> String {
        let mod10 = value % 10
        let mod100 = value % 100
        switch (mod100, mod10) {
        case (11...14, _): return "дней"
        case (_, 1): return "день"
        case (_, 2...4): return "дня"
        default: return "дней"
        }
    }
}

// MARK: - UITableViewDataSource

extension NewTrackerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        SectionType.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SectionType(rawValue: section) else { return 0 }

        switch section {
        case .enterName:
            return 1
        case .parameters:
            return ParameterType.allCases.count
        case .customization:
            return 1
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = SectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {

        case .enterName:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EnterNameCell.reuseID,
                for: indexPath
            ) as? EnterNameCell else {
                return UITableViewCell()
            }

            cell.delegate = self
            cell.configure(text: state.title)
            return cell

        case .parameters:
            guard let type = ParameterType(rawValue: indexPath.row) else {
                return UITableViewCell()
            }

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ParameterCell.reuseID,
                for: indexPath
            ) as? ParameterCell else {
                return UITableViewCell()
            }

            let subtitle = (type == .category)
                ? state.categoryTitle
                : Weekday.formattedWeekdays(Array(state.schedule))

            cell.configure(
                parameter: NewTrackerParameter(
                    title: type == .category ? "Категория" : "Расписание",
                    subtitle: subtitle,
                    isFirst: type == .category,
                    isLast: type == .schedule
                )
            )
            return cell

        case .customization:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CustomizationCell.reuseID,
                for: indexPath
            ) as? CustomizationCell else {
                return UITableViewCell()
            }

            cell.delegate = self
            cell.configure(
                selectedEmoji: state.emoji,
                selectedColor: state.color
            )
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension NewTrackerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let section = SectionType(rawValue: indexPath.section) else { return false }
        return section == .parameters
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard SectionType(rawValue: indexPath.section) == .parameters else { return }
        guard let type = ParameterType(rawValue: indexPath.row) else { return }

        switch type {
        case .category:
            let vm = CategoryListViewModel(selectedTitle: state.categoryTitle)
            let vc = CategoryListViewController(viewModel: vm)

            vc.onCategoryPicked = { [weak self] category in
                guard let self else { return }
                self.state.categoryTitle = category.title

                let indexPath = IndexPath(
                    row: ParameterType.category.rawValue,
                    section: SectionType.parameters.rawValue
                )
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }

            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)

        case .schedule:
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

// MARK: - EnterNameCellDelegate

extension NewTrackerViewController: EnterNameCellDelegate {

    func enterNameCell(_ cell: EnterNameCell, didChangeText text: String) {
        state.title = text
    }

    func updateCellLayout() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewTrackerViewController: ScheduleViewControllerDelegate {

    func getConfiguredSchedule(_ schedule: Set<Weekday>) {
        state.schedule = schedule

        let indexPath = IndexPath(
            row: ParameterType.schedule.rawValue,
            section: SectionType.parameters.rawValue
        )

        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - CustomizationCellDelegate

extension NewTrackerViewController: CustomizationCellDelegate {

    func customizationCell(_ cell: CustomizationCell, didPickEmoji emoji: String) {
        state.emoji = emoji
    }

    func customizationCell(_ cell: CustomizationCell, didPickColor color: UIColor) {
        state.color = color
    }
}

