import UIKit

final class TrackersListViewController: UIViewController {

    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()

    // MARK: - State

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = [] {
        didSet { updateEmptyState() }
    }
    private var completedTrackers: Set<TrackerRecord> = []

    private var selectedDate: Date = Date().excludeTime()

    // MARK: - Views

    private lazy var addTrackerButton: UIButton = {
        let button = UIButton()
        let image = UIImage.addTracker.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .ypBlack
        return button
    }()

    private lazy var dateButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .datePickerGray
        config.baseForegroundColor = .datePickerBlack
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)

        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
        return button
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        return searchController
    }()

    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyState
        return imageView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var emptyStateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseID)
        collectionView.register(
            TrackerCategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeader.reuseID
        )
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        return collectionView
    }()

    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlue
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()

    // MARK: - Private Properties

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

    private let layoutParams = LayoutParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 10
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        configDependencies()
        setupUI()
        setupActions()

        loadFromCoreData()
        loadCompletedFromCoreData()

        applySelectedDate(selectedDate)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadFromCoreData()
        loadCompletedFromCoreData()

        applySelectedDate(selectedDate)
    }

    // MARK: - Configure Dependencies

    private func configDependencies() {
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews([
            emptyStateStackView,
            trackersCollectionView,
            filterButton
        ])

        filterButton.isHidden = true  // временно скрыла
        filterButton.isUserInteractionEnabled = false
        
        setupNavigationBar()
        setupConstraints()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navigationItem.title = "Трекеры"

        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateButton)
    }

    private func setupConstraints() {
        [
            emptyStateLabel,
            emptyStateImageView,
            emptyStateStackView,
            trackersCollectionView,
            filterButton
        ].disableAutoresizingMasks()

        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalTo: addTrackerButton.heightAnchor),

            dateButton.heightAnchor.constraint(equalToConstant: 34),

            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalTo: emptyStateImageView.heightAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }

    private func setupActions() {
        addTrackerButton.addTarget(self, action: #selector(addTrackerButtonDidTap), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(dateButtonDidTap), for: .touchUpInside)
    }

    // MARK: - Core Data

    private func loadFromCoreData() {
        let cdCategories = (try? categoryStore.fetchAll()) ?? []
        categories = cdCategories.map { cdCategory in
            let trackersSet = cdCategory.trackers as? Set<TrackerCoreData> ?? []
            let trackers = trackersSet.compactMap { $0.toTracker() }
            return TrackerCategory(title: cdCategory.title ?? "", trackers: trackers)
        }
    }

    private func loadCompletedFromCoreData() {
        let records = recordStore.fetchAll()
        completedTrackers = Set(records.compactMap { record in
            guard
                let trackerID = record.tracker?.trackerID,
                let date = record.completionDate
            else { return nil }
            return TrackerRecord(trackerID: trackerID, completionDate: date.excludeTime())
        })
    }

    // MARK: - Actions

    @objc private func addTrackerButtonDidTap() {
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.delegate = self
        let navigationVC = UINavigationController(rootViewController: newTrackerVC)
        navigationVC.modalPresentationStyle = .popover
        present(navigationVC, animated: true)
    }

    @objc private func dateButtonDidTap() {
        let vc = DatePickerPopoverViewController(
            selectedDate: selectedDate,
            onPick: { [weak self] date in
                self?.applySelectedDate(date)
            }
        )
        vc.modalPresentationStyle = .popover
        if let pop = vc.popoverPresentationController {
            pop.sourceView = dateButton
            pop.sourceRect = dateButton.bounds
            pop.permittedArrowDirections = .up
        }
        present(vc, animated: true)
    }

    // MARK: - Private Methods

    private func applySelectedDate(_ date: Date) {
        selectedDate = date.excludeTime()
        dateButton.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

        loadCompletedFromCoreData()
        filterTrackers(for: selectedDate)
    }

    private func configureCell(_ cell: TrackerCell, indexPath: IndexPath, updateDelegate: Bool) {
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        let isCompleted = isCompleted(id: tracker.id, for: selectedDate)
        let quanity = getCurrentQuanity(id: tracker.id)
        cell.configure(from: tracker, isCompleted: isCompleted, quanity: quanity)
        if updateDelegate { cell.delegate = self }
    }

    private func updateEmptyState() {
        emptyStateStackView.isHidden = !visibleCategories.isEmpty
    }

    private func filterTrackers(for date: Date) {
        let weekday = getWeekday(from: date)
        filterTrackers(for: weekday)
    }

    private func getWeekday(from date: Date) -> Weekday {
        let value = Calendar.current.component(.weekday, from: date)
        guard let weekday = Weekday(rawValue: value) else { return .monday }
        return weekday
    }

    private func filterTrackers(for weekday: Weekday) {
        let filteredCategories: [TrackerCategory] = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter {
                $0.schedule.isEmpty || $0.schedule.contains(weekday)
            }
            guard !filteredTrackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }

        visibleCategories = filteredCategories
        trackersCollectionView.reloadData()
    }

    private func isCompleted(id: UUID, for date: Date) -> Bool {
        let record = TrackerRecord(trackerID: id, completionDate: date.excludeTime())
        return completedTrackers.contains(record)
    }

    private func getCurrentQuanity(id: UUID) -> Int {
        completedTrackers.filter { $0.trackerID == id }.count
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersListViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseID,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        configureCell(cell, indexPath: indexPath, updateDelegate: true)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCategoryHeader.reuseID,
            for: indexPath
        ) as? TrackerCategoryHeader else { return UICollectionReusableView() }

        header.configure(category: visibleCategories[indexPath.section])
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.frame.width - layoutParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(layoutParams.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: layoutParams.leftInset, bottom: 16, right: layoutParams.rightInset)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat { .zero }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let headerView = TrackerCategoryHeader(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 0))
        headerView.configure(category: visibleCategories[section])

        let targetSize = headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height)
        )
        return CGSize(width: targetSize.width, height: targetSize.height)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersListViewController: TrackerCellDelegate {

    func completeButtonDidTap(in cell: TrackerCell) {
        let currentDate = selectedDate.excludeTime()
        guard !currentDate.isFutureDate() else {
            presentSimpleAlert(
                title: "Не получится",
                message: "Нельзя отметить привычку для будущей даты",
                actionTitle: "Хорошо"
            )
            return
        }

        guard let indexPath = trackersCollectionView.indexPath(for: cell) else { return }
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]

        guard let trackerCD = try? trackerStore.fetchTrackerCoreData(by: tracker.id) else {
            print("❌ Can't find TrackerCoreData for id:", tracker.id)
            return
        }

        let record = TrackerRecord(trackerID: tracker.id, completionDate: currentDate)

        do {
            if completedTrackers.contains(record) {
                try recordStore.deleteRecord(trackerID: tracker.id, date: currentDate)
                completedTrackers.remove(record)
            } else {
                try recordStore.addRecord(for: trackerCD, date: currentDate)
                completedTrackers.insert(record)
            }
        } catch {
            print("❌ record save/delete error:", error)
            return
        }

        configureCell(cell, indexPath: indexPath, updateDelegate: false)
    }
}

// MARK: - NewTrackerViewControllerDelegate

extension TrackersListViewController: NewTrackerViewControllerDelegate {

    func createTracker(from config: NewTrackerState) {
        let tracker = Tracker(
            id: UUID(),
            title: config.title,
            color: config.color ?? .ypLightGray,
            emoji: config.emoji,
            schedule: config.schedule
        )

        let categoryTitle = config.categoryTitle.isEmpty ? "Важное" : config.categoryTitle

        do {
            try trackerStore.addTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            print("save error:", error)
        }

        loadFromCoreData()
        loadCompletedFromCoreData()
        filterTrackers(for: selectedDate)
    }
}

//
// MARK: - Date Picker Popover (Inline Calendar)
//

private final class DatePickerPopoverViewController: UIViewController {

    private let onPick: (Date) -> Void
    private var currentDate: Date

    private lazy var picker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .inline
        dp.locale = Locale(identifier: "ru_RU")
        dp.calendar = Calendar(identifier: .gregorian)
        dp.timeZone = .current
        dp.overrideUserInterfaceStyle = .light
        dp.date = currentDate
        dp.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return dp
    }()

    init(selectedDate: Date, onPick: @escaping (Date) -> Void) {
        self.currentDate = selectedDate
        self.onPick = onPick
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        preferredContentSize = CGSize(width: 320, height: 360)
    }

    @objc private func valueChanged() {
        let d = picker.date.excludeTime()
        onPick(d)
    }
}

