import UIKit

final class NewTrackerViewController: UIViewController {

    // MARK: - Delegate

    weak var delegate: NewTrackerViewControllerDelegate?

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
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
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
        category: "",
        schedule: [],
        emoji: "",
        color: nil
    ) {
        didSet {
            createButton.isEnabled = state.isReady
            createButton.backgroundColor = state.isReady ? .ypBlack : .ypGray
        }
    }

    private let scheduleVC = ScheduleViewController()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Новая привычка"

        tableView.dataSource = self
        tableView.delegate = self
        scheduleVC.delegate = self

        view.addSubview(tableView)
        view.addSubview(buttonStackView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    }

    // ❗️Gesture ТОЛЬКО на фоне tableView, не на всём view
    private func setupBackgroundTap() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear

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
        delegate?.createTracker(from: state)
        dismiss(animated: true)
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: EnterNameCell.reuseID,
                for: indexPath
            ) as! EnterNameCell
            cell.delegate = self
            return cell

        case .parameters:
            let type = ParameterType(rawValue: indexPath.row)!
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ParameterCell.reuseID,
                for: indexPath
            ) as! ParameterCell

            let subtitle = type == .category
                ? state.category
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CustomizationCell.reuseID,
                for: indexPath
            ) as! CustomizationCell
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

        if indexPath.row == ParameterType.schedule.rawValue {
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

