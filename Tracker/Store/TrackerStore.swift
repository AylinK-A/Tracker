import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decoding
}

final class TrackerStore: NSObject {

    weak var delegate: TrackerStoreDelegate?

    private let context: NSManagedObjectContext
    private var currentWeekday: Weekday? = .monday

    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    private var inserted: Set<IndexPath>?
    private var deleted: Set<IndexPath>?
    private var updated: Set<IndexPath>?
    private var moved: Set<StoreUpdate.Move>?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        updateFetchResultsController()
    }()

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
        _ = fetchedResultsController
    }

    // MARK: - Public

    func setCurrentWeekday(_ weekday: Weekday?) {
        currentWeekday = weekday
        fetchedResultsController = updateFetchResultsController()
        delegate?.storeDidReloadFRC(self)
    }

    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func titleForSection(_ section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }

    func numberOfItems(in section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tracker(at indexPath: IndexPath) -> Tracker {
        let object = fetchedResultsController.object(at: indexPath)
        return makeTracker(from: object)
    }

    // MARK: - Decode CoreData -> Tracker

    private func makeTracker(from cd: TrackerCoreData) -> Tracker {
        let id = cd.trackerID ?? UUID()
        let title = cd.title ?? ""
        let emoji = cd.emoji ?? ""
        let color = (cd.color as? UIColor) ?? .colorSelection1
        let schedule = getSchedule(from: cd)

        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }

    private func getSchedule(from tracker: TrackerCoreData) -> Set<Weekday> {
        guard let scheduleSet = tracker.schedule as? Set<WeekdayCoreData> else { return [] }
        return Set(scheduleSet.compactMap { Weekday(rawValue: Int($0.rawValue)) })
    }

    // MARK: - FRC

    private func makeFetchRequest() -> NSFetchRequest<TrackerCoreData> {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)
        ]

        if let weekday = currentWeekday {
            request.predicate = NSPredicate(format: "ANY schedule.rawValue == %d", weekday.rawValue)
        } else {
            request.predicate = nil
        }

        return request
    }

    private func updateFetchResultsController() -> NSFetchedResultsController<TrackerCoreData> {
        let request = makeFetchRequest()
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil
        )
        controller.delegate = self

        do { try controller.performFetch() }
        catch { assertionFailure("❌ performFetch failed: \(error)") }

        return controller
    }

    private func resetTracking() {
        insertedSections = nil
        deletedSections = nil
        inserted = nil
        deleted = nil
        updated = nil
        moved = nil
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedSections = []
        deletedSections = []
        inserted = []
        deleted = []
        updated = []
        moved = Set<StoreUpdate.Move>()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard
            let insertedSections,
            let deletedSections,
            let inserted,
            let deleted,
            let updated,
            let moved
        else { return }

        delegate?.store(
            self,
            didUpdate: StoreUpdate(
                insertedSections: insertedSections,
                deletedSections: deletedSections,
                insertedIndexPaths: inserted,
                deletedIndexPaths: deleted,
                updatedIndexPaths: updated,
                movedIndexPaths: moved
            )
        )

        resetTracking()
    }

    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>,
                    didChange sectionInfo: any NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        case .delete:
            deletedSections?.insert(sectionIndex)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            if let newIndexPath { inserted?.insert(newIndexPath) }
        case .delete:
            if let indexPath { deleted?.insert(indexPath) }
        case .update:
            if let indexPath { updated?.insert(indexPath) }
        case .move:
            if let old = indexPath, let new = newIndexPath {
                moved?.insert(.init(oldIndexPath: old, newIndexPath: new))
            }
        @unknown default:
            break
        }
    }
}

