import UIKit
import CoreData

final class TrackersListViewController: UIViewController {

    // MARK: - Stores

    private let categoryStore = TrackerCategoryStore()
    private lazy var trackerStore = TrackerStore(categoryStore: categoryStore)
    private let recordStore = TrackerRecordStore()

    // MARK: - Pin (UserDefaults)

    private let pinnedKey = "pinned_trackers_ids"

    private var pinnedTrackerIDs: Set<UUID> {
        get {
            let strings = UserDefaults.standard.array(forKey: pinnedKey) as? [String] ?? []
            return Set(strings.compactMap { UUID(uuidString: $0) })
        }
        set {
            UserDefaults.standard.set(newValue.map { $0.uuidString }, forKey: pinnedKey)
        }
    }

    private func isPinned(_ id: UUID) -> Bool {
        pinnedTrackerIDs.contains(id)
    }

    private func togglePin(_ id: UUID) {
        var set = pinnedTrackerIDs
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
        pinnedTrackerIDs = set
    }

    // MARK: - State

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = [] {
        didSet { updateEmptyState() }
    }

    private var completedTrackers: Set<TrackerRecord> = []
    private var selectedDate: Date = Date().excludeTime()

    private var selectedFilter: TrackerFilter = .all

    // MARK: - Views

    private lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact

        dp.locale = Locale(identifier: "ru_RU")
        dp.calendar = Calendar(identifier: .gregorian)
        dp.timeZone = .current

        // ✅ адаптивный цвет из Assets
        dp.tintColor = UIColor(named: "datePickerGray")

        dp.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        return dp
    }()

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = "Поиск"
        return sc
    }()

    private lazy var emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .emptyState
        return iv
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var emptyStateStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .ypBackground
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseID)
        cv.register(
            TrackerCategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeader.reuseID
        )
        cv.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 82, right: 0)
        cv.scrollIndicatorInsets = cv.contentInset
        return cv
    }()

    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()

    // MARK: - Layout

    private let layoutParams = LayoutParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 10
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: .open, screen: .main)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: .close, screen: .main)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAddButtonImage()
            updateDatePickerAppearance()
        }
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .ypWhite

        view.addSubview(trackersCollectionView)
        view.addSubview(emptyStateStackView)
        view.addSubview(filterButton)

        setupNavigationBar()
        setupConstraints()

        filterButton.isHidden = true
        filterButton.isUserInteractionEnabled = false
    }

    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("main_title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true

        let navTint: UIColor = .label

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = .ypBackground
        appearance.shadowColor = .clear

        appearance.largeTitleTextAttributes = [
            .foregroundColor: navTint,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: navTint
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationItem.searchController = searchController

        updateAddButtonImage()

        datePicker.date = selectedDate
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        updateDatePickerAppearance()
    }


    private func setupConstraints() {
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalToConstant: 34),

            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalTo: emptyStateImageView.heightAnchor),

            emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupActions() {
        filterButton.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
    }

    // MARK: - CoreData Load

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
    
    private func updateDatePickerAppearance() {
        // ✅ берём цвет из твоего Assets (Any/Dark)
        datePicker.tintColor = UIColor(named: "datePickerGray")

        // убираем подложку/капсулу
        datePicker.backgroundColor = .clear
        datePicker.layer.cornerRadius = 0
        datePicker.layer.masksToBounds = false
    }

    // MARK: - Actions

    @objc private func addTrackerButtonDidTap() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .addTrack)

        let vc = NewTrackerViewController(mode: .create)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc private func datePickerChanged() {
        applySelectedDate(datePicker.date.excludeTime())
    }

    @objc private func filterButtonDidTap() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .filter)

        let vc = FiltersViewController()
        vc.selectedFilter = selectedFilter
        vc.onSelect = { [weak self] filter in
            guard let self else { return }
            self.selectedFilter = filter

            if filter == .today {
                self.applySelectedDate(Date().excludeTime())
            } else {
                self.applySelectedDate(self.selectedDate)
            }
        }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - Filtering

    private func applySelectedDate(_ date: Date) {
        selectedDate = date.excludeTime()
        if datePicker.date.excludeTime() != selectedDate {
            datePicker.date = selectedDate
        }
        loadCompletedFromCoreData()
        filterTrackers(for: selectedDate)
    }

    private func filterTrackers(for date: Date) {
        let weekday = getWeekday(from: date)
        filterTrackers(for: weekday)
    }

    private func getWeekday(from date: Date) -> Weekday {
        let value = Calendar.current.component(.weekday, from: date)
        return Weekday(rawValue: value) ?? .monday
    }

    private func applyCompletionFilter(_ trackers: [Tracker]) -> [Tracker] {
        switch selectedFilter {
        case .all, .today:
            return trackers
        case .completed:
            return trackers.filter { isCompleted(id: $0.id, for: selectedDate) }
        case .uncompleted:
            return trackers.filter { !isCompleted(id: $0.id, for: selectedDate) }
        }
    }
    
    private func updateAddButtonImage() {
        let isDark = traitCollection.userInterfaceStyle == .dark

        let imageName = isDark ? "addTracker2" : "addTracker"
        let image = UIImage(named: imageName)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonDidTap)
        )

        navigationItem.leftBarButtonItem?.tintColor = nil
    }


    private func filterTrackers(for weekday: Weekday) {
        var pinned: [Tracker] = []
        var normalCategories: [TrackerCategory] = []

        for category in categories {
            let trackersForDayBySchedule = category.trackers.filter {
                $0.schedule.isEmpty || $0.schedule.contains(weekday)
            }

            let trackersForDay = applyCompletionFilter(trackersForDayBySchedule)

            guard !trackersForDay.isEmpty else { continue }

            let pinnedInCategory = trackersForDay.filter { isPinned($0.id) }
            let normalInCategory = trackersForDay.filter { !isPinned($0.id) }

            pinned.append(contentsOf: pinnedInCategory)

            if !normalInCategory.isEmpty {
                normalCategories.append(TrackerCategory(title: category.title, trackers: normalInCategory))
            }
        }

        var result: [TrackerCategory] = []
        if !pinned.isEmpty {
            result.append(TrackerCategory(title: "Закрепленные", trackers: pinned))
        }
        result.append(contentsOf: normalCategories)

        visibleCategories = result
        trackersCollectionView.reloadData()

        let hasAny = !result.isEmpty
        filterButton.isHidden = !hasAny
        filterButton.isUserInteractionEnabled = hasAny

        filterButton.setTitleColor(selectedFilter.isActiveFilter ? .ypRed : .white, for: .normal)
    }

    private func updateEmptyState() {
        emptyStateStackView.isHidden = !visibleCategories.isEmpty
    }

    // MARK: - Helpers

    private func isCompleted(id: UUID, for date: Date) -> Bool {
        let record = TrackerRecord(trackerID: id, completionDate: date.excludeTime())
        return completedTrackers.contains(record)
    }

    private func getCurrentQuanity(id: UUID) -> Int {
        completedTrackers.filter { $0.trackerID == id }.count
    }

    private func configureCell(_ cell: TrackerCell, indexPath: IndexPath, updateDelegate: Bool) {
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        let completed = isCompleted(id: tracker.id, for: selectedDate)
        let quantity = getCurrentQuanity(id: tracker.id)
        let pinned = isPinned(tracker.id)

        cell.configure(from: tracker, isCompleted: completed, quanity: quantity, isPinned: pinned)
        if updateDelegate { cell.delegate = self }
    }

    // MARK: - Context Menu Actions

    private func openEditScreen(for tracker: Tracker) {
        do {
            let trackerCD = try trackerStore.fetchTrackerCoreData(by: tracker.id)
            let categoryTitle = trackerCD.category?.title ?? ""
            let completedDays = getCurrentQuanity(id: tracker.id)

            let initialState = NewTrackerState(
                title: tracker.title,
                categoryTitle: categoryTitle,
                schedule: tracker.schedule,
                emoji: tracker.emoji,
                color: tracker.color
            )

            let vc = NewTrackerViewController(
                mode: .edit(trackerID: tracker.id, completedDays: completedDays),
                initialState: initialState
            )
            vc.delegate = self

            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
        } catch {
            print("❌ openEditScreen error:", error)
        }
    }

    private func confirmDeleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: "Удалить трекер?",
            message: "Вы уверены, что хотите удалить трекер?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        })

        present(alert, animated: true)
    }

    private func deleteTracker(_ tracker: Tracker) {
        do {
            let allRecords = recordStore.fetchAll()
            let recordsToDelete = allRecords.filter { $0.tracker?.trackerID == tracker.id }
            for record in recordsToDelete {
                try recordStore.delete(record)
            }
        } catch {
            print("❌ Failed to delete tracker records:", error)
        }

        do {
            let trackerCD = try trackerStore.fetchTrackerCoreData(by: tracker.id)
            guard let context = trackerCD.managedObjectContext else { return }
            context.delete(trackerCD)
            try context.save()
        } catch {
            print("❌ Failed to delete tracker:", error)
        }

        if isPinned(tracker.id) {
            togglePin(tracker.id)
        }

        loadFromCoreData()
        loadCompletedFromCoreData()
        applySelectedDate(selectedDate)
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

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseID,
            for: indexPath
        ) as? TrackerCell else { return UICollectionViewCell() }

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

// MARK: - UICollectionViewDelegate + Layout + Context Menu

extension TrackersListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }

            let pinned = self.isPinned(tracker.id)
            let pinTitle = pinned ? "Открепить" : "Закрепить"

            let pinAction = UIAction(title: pinTitle, image: UIImage(systemName: "pin")) { [weak self] _ in
                guard let self else { return }
                self.togglePin(tracker.id)
                self.applySelectedDate(self.selectedDate)
            }

            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
                AnalyticsService.shared.report(event: .click, screen: .main, item: .edit)
                self?.openEditScreen(for: tracker)
            }

            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                AnalyticsService.shared.report(event: .click, screen: .main, item: .delete)
                self?.confirmDeleteTracker(tracker)
            }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
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
        AnalyticsService.shared.report(event: .click, screen: .main, item: .track)

        guard let indexPath = trackersCollectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

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

        // перефильтровать (чтобы completed/uncompleted обновлялись)
        applySelectedDate(selectedDate)
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
        do { try trackerStore.addTracker(tracker, categoryTitle: categoryTitle) }
        catch { print("save error:", error) }

        loadFromCoreData()
        applySelectedDate(selectedDate)
    }

    func updateTracker(id: UUID, from config: NewTrackerState) {
        do {
            let trackerCD = try trackerStore.fetchTrackerCoreData(by: id)
            guard let context = trackerCD.managedObjectContext else { return }

            trackerCD.title = config.title
            trackerCD.emoji = config.emoji
            trackerCD.color = config.color ?? .ypLightGray

            let categoryTitle = config.categoryTitle.isEmpty ? "Важное" : config.categoryTitle
            let categoryCD = try categoryStore.findOrCreateCategory(title: categoryTitle)
            trackerCD.category = categoryCD

            if let old = trackerCD.schedule as? Set<WeekdayCoreData> {
                old.forEach { context.delete($0) }
            }

            let weekdayObjects = config.schedule.map { day -> WeekdayCoreData in
                let w = WeekdayCoreData(context: context)
                w.rawValue = Int16(day.rawValue)
                return w
            }
            trackerCD.schedule = NSSet(array: weekdayObjects)

            try context.save()
        } catch {
            print("❌ update tracker error:", error)
        }

        loadFromCoreData()
        applySelectedDate(selectedDate)
    }
}

