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
    
    // MARK: - Domain API (для ViewModel/экрана)

    func fetchCategories() -> [TrackerCategory] {
        let coreDataObjects = fetchAll()

        return coreDataObjects.compactMap { object in
            guard let title = object.title else { return nil }
            return TrackerCategory(title: title, trackers: [])
        }
    }
    
    func deleteCategory(objectID: NSManagedObjectID) throws {
        let object = try context.existingObject(with: objectID)
        context.delete(object)
        try context.save()
        try? fetchedResultsController.performFetch()
    }

    func renameCategory(objectID: NSManagedObjectID, newTitle: String) throws {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard let category = try context.existingObject(with: objectID) as? TrackerCategoryCoreData else { return }
        category.title = trimmed

        try context.save()
        try? fetchedResultsController.performFetch()
    }

    func createCategoryIfNeeded(title: String) throws -> TrackerCategory {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return TrackerCategory(title: title, trackers: [])
        }

        if let existing = fetchedResultsController.fetchedObjects?
            .first(where: { ($0.title ?? "").caseInsensitiveCompare(trimmed) == .orderedSame }) {

            return TrackerCategory(title: existing.title ?? trimmed, trackers: [])
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = trimmed
        category.createdAt = Date()
        category.categoryID = UUID()

        try context.save()
        try? fetchedResultsController.performFetch()

        return TrackerCategory(title: trimmed, trackers: [])
    }

}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {}

