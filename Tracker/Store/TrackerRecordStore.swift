import CoreData

final class TrackerRecordStore: NSObject {

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
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
        try? fetchedResultsController.performFetch()
    }

    func fetchAll() -> [TrackerRecordCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    func addRecord(for tracker: TrackerCoreData, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.completionDate = date
        record.tracker = tracker
        try context.save()
    }

    func delete(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {}


