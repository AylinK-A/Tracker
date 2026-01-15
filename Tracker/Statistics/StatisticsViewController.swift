import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - Stores

    private let recordStore = TrackerRecordStore()
    private let categoryStore = TrackerCategoryStore()

    // MARK: - UI

    private lazy var bestPeriodCard = StatisticsCardView(title: "Лучший период")
    private lazy var perfectDaysCard = StatisticsCardView(title: "Идеальные дни")
    private lazy var completedCard = StatisticsCardView(title: "Трекеров завершено")
    private lazy var averageCard = StatisticsCardView(title: "Среднее значение")

    private lazy var cardsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            bestPeriodCard,
            perfectDaysCard,
            completedCard,
            averageCard
        ])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private lazy var emptyImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "notFound")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var emptyStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emptyImageView, emptyLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()

        navigationItem.title = NSLocalizedString("tab_statistics", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true

        // ✅ подписка на обновление записей трекеров
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerRecordChange),
            name: .trackerRecordDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification

    @objc private func handleTrackerRecordChange() {
        updateUI()
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .ypWhite
        navigationItem.title = NSLocalizedString("tab_statistics", comment: "")

        view.addSubview(cardsStack)
        view.addSubview(emptyStack)

        cardsStack.translatesAutoresizingMaskIntoConstraints = false
        emptyStack.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false

        [bestPeriodCard, perfectDaysCard, completedCard, averageCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 90)
            ])
        }

        NSLayoutConstraint.activate([
            cardsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            cardsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyImageView.widthAnchor.constraint(equalTo: emptyImageView.heightAnchor)
        ])
    }

    // MARK: - Update

    private func updateUI() {
        let stats = calculateStats()

        bestPeriodCard.setValue(stats.bestPeriod)
        perfectDaysCard.setValue(stats.perfectDays)
        completedCard.setValue(stats.completedCount)
        averageCard.setValue(stats.average)

        let isEmpty = stats.completedCount == 0
        emptyStack.isHidden = !isEmpty
        cardsStack.isHidden = isEmpty
    }

    // MARK: - Stats calculation

    private struct Stats {
        let bestPeriod: Int
        let perfectDays: Int
        let completedCount: Int
        let average: Int
    }

    private func calculateStats() -> Stats {
        let recordsCD = recordStore.fetchAll()

        guard !recordsCD.isEmpty else {
            return Stats(bestPeriod: 0, perfectDays: 0, completedCount: 0, average: 0)
        }

        let records: [(id: UUID, date: Date)] = recordsCD.compactMap { r in
            guard
                let id = r.tracker?.trackerID,
                let date = r.completionDate
            else { return nil }
            return (id: id, date: date.excludeTime())
        }

        // ✅ records может оказаться пустым после compactMap
        guard !records.isEmpty else {
            return Stats(bestPeriod: 0, perfectDays: 0, completedCount: 0, average: 0)
        }

        let completedCount = records.count

        var completedByDate: [Date: Set<UUID>] = [:]
        for item in records {
            completedByDate[item.date, default: []].insert(item.id)
        }

        let allTrackers = fetchAllTrackers()

        var perfectDays = 0
        for (date, completedIDs) in completedByDate {
            let weekday = weekdayFrom(date)
            let trackersForDay = allTrackers.filter {
                $0.schedule.isEmpty || $0.schedule.contains(weekday)
            }

            guard !trackersForDay.isEmpty else { continue }

            let allIDs = Set(trackersForDay.map { $0.id })
            if allIDs.isSubset(of: completedIDs) {
                perfectDays += 1
            }
        }

        let uniqueDates = completedByDate.keys.sorted()

        var bestPeriod = 0
        var currentStreak = 0

        if !uniqueDates.isEmpty {
            bestPeriod = 1
            currentStreak = 1
        }

        if uniqueDates.count >= 2 {
            for i in 1..<uniqueDates.count {
                let prev = uniqueDates[i - 1]
                let cur = uniqueDates[i]
                if isNextDay(prev, cur) {
                    currentStreak += 1
                    bestPeriod = max(bestPeriod, currentStreak)
                } else {
                    currentStreak = 1
                }
            }
        }

        let average = Int(
            round(Double(completedCount) / Double(max(uniqueDates.count, 1)))
        )

        return Stats(
            bestPeriod: bestPeriod,
            perfectDays: perfectDays,
            completedCount: completedCount,
            average: average
        )
    }

    // MARK: - Helpers

    private func fetchAllTrackers() -> [Tracker] {
        let cdCategories = (try? categoryStore.fetchAll()) ?? []
        var trackers: [Tracker] = []

        for cdCategory in cdCategories {
            let trackersSet = cdCategory.trackers as? Set<TrackerCoreData> ?? []
            trackers.append(contentsOf: trackersSet.compactMap { $0.toTracker() })
        }
        return trackers
    }

    private func weekdayFrom(_ date: Date) -> Weekday {
        let value = Calendar.current.component(.weekday, from: date)
        return Weekday(rawValue: value) ?? .monday
    }

    private func isNextDay(_ a: Date, _ b: Date) -> Bool {
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: a) else {
            return false
        }
        return next.excludeTime() == b.excludeTime()
    }
}

