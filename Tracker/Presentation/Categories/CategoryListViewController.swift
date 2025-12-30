import UIKit

final class CategoryListViewController: UIViewController {

    // MARK: - Public
    var onCategoryPicked: ((TrackerCategory) -> Void)?

    // MARK: - Private
    private let viewModel: CategoryListViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let emptyImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "emptyStateImage")
        return iv
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Привычки и события можно\nобъединить по смыслу"
        return label
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapAddCategory), for: .touchUpInside)
        return button
    }()

    // MARK: - Init
    init(viewModel: CategoryListViewModel = CategoryListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = CategoryListViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Категория"
        view.backgroundColor = .ypWhite

        setupEmptyUI()
        setupTable()
        setupBindings()

        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    // MARK: - NavBar
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.ypBlack
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Setup
    private func setupEmptyUI() {
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        view.addSubview(addCategoryButton)

        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()

        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16)
        ])
    }

    private func setupBindings() {
        viewModel.onChange = { [weak self] in
            guard let self else { return }

            let isEmpty = self.viewModel.numberOfRows() == 0

            self.tableView.isHidden = isEmpty
            self.emptyImageView.isHidden = !isEmpty
            self.emptyLabel.isHidden = !isEmpty

            self.addCategoryButton.isHidden = false
            self.tableView.reloadData()
        }

        viewModel.onSelectCategory = { [weak self] category in
            self?.onCategoryPicked?(category)
            self?.dismiss(animated: true)
        }

        viewModel.onError = { error in
            print("CategoryListViewModel error:", error)
        }
    }

    // MARK: - Actions
    @objc private func didTapAddCategory() {
        let vc = NewCategoryViewController()

        vc.onCategoryCreated = { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - Menu actions
    private func openEditCategory(index: Int) {
        let vc = EditCategoryViewController()
        vc.initialTitle = viewModel.categoryTitleForEdit(at: index)

        vc.onDone = { [weak self] newTitle in
            self?.viewModel.rename(at: index, to: newTitle)
        }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func presentDeleteConfirm(index: Int) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )

        let delete = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.delete(at: index)
        }

        let cancel = UIAlertAction(title: "Отменить", style: .cancel)

        alert.addAction(delete)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        let total = viewModel.numberOfRows()
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == total - 1

        cell.configure(
            title: viewModel.title(at: indexPath.row),
            isSelected: viewModel.isSelected(at: indexPath.row),
            isFirst: isFirst,
            isLast: isLast
        )

        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {

        UIContextMenuConfiguration(identifier: indexPath as NSIndexPath,
                                   previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }

            let edit = UIAction(title: "Редактировать", image: nil) { [weak self] _ in
                self?.openEditCategory(index: indexPath.row)
            }

            let delete = UIAction(title: "Удалить",
                                  image: nil,
                                  attributes: .destructive) { [weak self] _ in
                self?.presentDeleteConfirm(index: indexPath.row)
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

