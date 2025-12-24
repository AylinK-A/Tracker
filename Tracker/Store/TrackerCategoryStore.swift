import CoreData

final class TrackerCategoryStore: NSObject {

    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>

    // MARK: - Init

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context

        let request = NSFetchRequest<TrackerCategoryCoreData>(
            entityName: "TrackerCategoryCoreData"
        )

        request.entity = NSEntityDescription.entity(
            forEntityName: "TrackerCategoryCoreData",
            in: context
        )

        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }


    // MARK: - Public

    func fetchAll() -> [TrackerCategoryCoreData] {
        try? fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects ?? []
    }

    func findOrCreateCategory(title: String) throws -> TrackerCategoryCoreData {
        if let existing = fetchedResultsController.fetchedObjects?
            .first(where: { $0.title == title }) {
            return existing
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        category.createdAt = Date()
        category.categoryID = UUID()

        try context.save()
        return category
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {}

