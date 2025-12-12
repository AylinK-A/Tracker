import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    // MARK: - Views
    
    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .ypWhite
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseID)
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    // MARK: - Private Properties
    
    private var weekdays: [Weekday] = Weekday.ordered
    private var chosenWeekdays: Set<Weekday> = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews([
            scheduleTableView,
            readyButton
        ])
        setupNavigationBar()
        setupConstraints()
        setupActions()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationItem.hidesBackButton = true
    }
    
    // MARK: Setup Constraints
    
    private func setupConstraints() {
        [
            scheduleTableView,
            readyButton
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            scheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scheduleTableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -16),
            
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        readyButton.addTarget(self, action: #selector(readyButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func readyButtonDidTap() {
        saveWeekdaysToParameters()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func saveWeekdaysToParameters() {
        delegate?.getConfiguredSchedule(chosenWeekdays)
    }
    
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = scheduleTableView.dequeueReusableCell(withIdentifier: ScheduleCell.reuseID, for: indexPath) as? ScheduleCell else {
            assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(ScheduleCell.reuseID) as \(String(describing: ScheduleCell.self))")
            return UITableViewCell()
        }
        let weekday = weekdays[indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == weekdays.count - 1
        cell.configure(weekday: weekday, isFirst: isFirst, isLast: isLast)
        cell.delegate = self
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    
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

// MARK: - ScheduleCellDelegate

extension ScheduleViewController: ScheduleCellDelegate {
    
    func weekdayInCell(day: Weekday, isIncluded: Bool) {
        if isIncluded {
            chosenWeekdays.insert(day)
        } else {
            chosenWeekdays.remove(day)
        }
    }
    
}
