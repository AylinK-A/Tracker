import CoreData

final class TrackerCategoryStore: NSObject {

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
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

    func fetchAll() -> [TrackerCategoryCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    func findOrCreateCategory(title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1

        if let category = try context.fetch(request).first {
            return category
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
        return category
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {}

