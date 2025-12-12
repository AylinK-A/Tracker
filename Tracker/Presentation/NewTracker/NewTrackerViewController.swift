import UIKit

final class NewTrackerViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    // MARK: - Types
    
    private enum SectionType: Int, CaseIterable {
        case enterName, parameters
    }
    
    private enum ParameterType: Int, CaseIterable {
        case category, schedule
    }
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.register(EnterNameCell.self, forCellReuseIdentifier: EnterNameCell.reuseID)
        tableView.register(ParameterCell.self, forCellReuseIdentifier: ParameterCell.reuseID)
        
        tableView.backgroundColor = .ypWhite
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 113
        tableView.keyboardDismissMode = .onDrag
        
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .ypRed).cgColor
        
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.isEnabled = false
        
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - State
    
    private var state = NewTrackerState(
        title: "",
        category: "Важное",
        schedule: [],
        emoji: "🤯",
        color: .colorSelection1
    ) {
        didSet {
            createButton.isEnabled = state.isReady
            createButton.backgroundColor = state.isReady ? .ypBlack : .ypGray
        }
    }
    
    // MARK: - Private Properties
    
    private var scheduleVC: ScheduleViewController? = ScheduleViewController()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        tableView.dataSource = self
        tableView.delegate = self
        
        scheduleVC?.delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews([
            tableView,
            buttonStackView
        ])
        
        setupNavigationBar()
        setupConstraints()
        setupActions()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        [
            tableView,
            buttonStackView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        view.addGestureRecognizer(singleTapRecognizer())
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didSingleTap() {
        view.endEditing(true)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        delegate?.createTracker(from: state)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func makeEnterNameCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterNameCell.reuseID, for: indexPath) as? EnterNameCell else {
            assertionFailure("❌[makeEnterNameCell]: can't dequeue reusable cell with id: \(EnterNameCell.reuseID) as \(String(describing: EnterNameCell.self))")
            return UITableViewCell()
        }
        cell.delegate = self
        return cell
    }
    
    private func makeParameterCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let parameterType = ParameterType(rawValue: indexPath.row) else {
            assertionFailure("❌[makeParameterCell] no such rawValue for \(String(describing: ParameterType.self))")
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ParameterCell.reuseID, for: indexPath) as? ParameterCell else {
            assertionFailure("❌[makeParameterCell]: can't dequeue reusable cell with id: \(ParameterCell.reuseID) as \(String(describing: ParameterCell.self))")
            return UITableViewCell()
        }
        
        let configuration = parameterConfig(type: parameterType)
        cell.configure(parameter: configuration)
        return cell
    }
    
    private func parameterConfig(type: ParameterType) -> NewTrackerParameter {
        switch type {
        case .category:
            return NewTrackerParameter(title: "Категория", subtitle: state.category, isFirst: true, isLast: false)
        case .schedule:
            let scheduleString = Weekday.formattedWeekdays(Array(state.schedule))
            return NewTrackerParameter(title: "Расписание", subtitle: scheduleString, isFirst: false, isLast: true)
        }
    }
    
    private func singleTapRecognizer() -> UITapGestureRecognizer {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.cancelsTouchesInView = false
        return singleTap
    }
    
    private func pushToScheduleVC() {
        guard let scheduleVC = scheduleVC else { return }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension NewTrackerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SectionType(rawValue: section) else {
            assertionFailure("❌[numberOfRowsInSection] no such rawValue for \(String(describing: SectionType.self))")
            return 0
        }
        switch sectionType {
        case .enterName: return 1
        case .parameters: return ParameterType.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            assertionFailure("❌[cellForRowAt] no such rawValue for \(String(describing: SectionType.self))")
            return UITableViewCell()
        }
        
        switch sectionType {
        case .enterName:
            return makeEnterNameCell(tableView, for: indexPath)
        case .parameters:
            return makeParameterCell(tableView, for: indexPath)
        }
    }
    
}

// MARK: - UITableViewDelegate

extension NewTrackerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            assertionFailure("❌[didSelectRowAt] no such rawValue for \(String(describing: SectionType.self))")
            return
        }
        guard let parameterType = ParameterType(rawValue: indexPath.row) else {
            assertionFailure("❌[didSelectRowAt] no such rawValue for \(String(describing: ParameterType.self))")
            return
        }
        
        switch sectionType {
        case .parameters:
            switch parameterType {
            case .category: return
            case .schedule: pushToScheduleVC()
            }
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
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
        let indexPath = IndexPath(row: ParameterType.schedule.rawValue, section: SectionType.parameters.rawValue)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}


