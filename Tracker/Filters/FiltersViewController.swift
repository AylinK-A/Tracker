import UIKit

final class FiltersViewController: UIViewController {

    // MARK: - Public

    var selectedFilter: TrackerFilter = .all
    var onSelect: ((TrackerFilter) -> Void)?

    // MARK: - Views

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tv.dataSource = self
        tv.delegate = self

        tv.rowHeight = 75
        tv.separatorStyle = .singleLine
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        tv.backgroundColor = .ypBackground
        tv.layer.cornerRadius = 16
        tv.layer.masksToBounds = true

        tv.isScrollEnabled = false

        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite
        navigationItem.title = "Фильтры"

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let filter = TrackerFilter(rawValue: indexPath.row) else { return cell }

        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none

        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlack

        if filter.shouldShowCheckmark && filter == selectedFilter {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let filter = TrackerFilter(rawValue: indexPath.row) else { return }

        selectedFilter = filter
        onSelect?(filter)

        dismiss(animated: true)
    }
}

