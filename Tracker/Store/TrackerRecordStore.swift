import UIKit
import CoreData

final class TrackerRecordStore: NSObject {

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "completionDate", ascending: false)
        ]

        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        return frc
    }()

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ TrackerRecordStore performFetch error:", error)
        }
    }

    // MARK: - Public

    func fetchAll() -> [TrackerRecordCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    func record(trackerID: UUID, date: Date) -> TrackerRecordCoreData? {
        let normalized = date.excludeTime()
        return fetchedResultsController.fetchedObjects?.first(where: { record in
            record.tracker?.trackerID == trackerID &&
            record.completionDate?.excludeTime() == normalized
        })
    }

    func addRecord(for tracker: TrackerCoreData, date: Date) throws {
        let normalized = date.excludeTime()

        if let trackerID = tracker.trackerID,
           record(trackerID: trackerID, date: normalized) != nil {
            return
        }

        let record = TrackerRecordCoreData(context: context)
        record.completionDate = normalized
        record.tracker = tracker

        try context.save()
        try fetchedResultsController.performFetch()
    }

    func deleteRecord(trackerID: UUID, date: Date) throws {
        guard let record = record(trackerID: trackerID, date: date) else { return }
        context.delete(record)
        try context.save()
        try fetchedResultsController.performFetch()
    }

    func delete(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
        try fetchedResultsController.performFetch()
    }

    func refresh() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ TrackerRecordStore refresh error:", error)
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {}

