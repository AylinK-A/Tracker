import CoreData

final class TrackerCategoryStore: NSObject {

    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>

    // MARK: - Init

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context

        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

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
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(domain: "TrackerCategoryStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Empty title"])
        }

        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "title ==[c] %@", trimmed)
        if let existing = try context.fetch(request).first {
            if existing.title != trimmed {
                existing.title = trimmed
                try context.save()
                try fetchedResultsController.performFetch()
            }
            return existing
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = trimmed
        category.createdAt = Date()
        category.categoryID = UUID()

        try context.save()
        try fetchedResultsController.performFetch()

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
        try fetchedResultsController.performFetch()
    }

    func renameCategory(objectID: NSManagedObjectID, newTitle: String) throws {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "title ==[c] %@", trimmed)

        if let existing = try context.fetch(request).first,
           existing.objectID != objectID {
            return
        }

        guard let category = try context.existingObject(with: objectID) as? TrackerCategoryCoreData else { return }
        category.title = trimmed

        try context.save()
        try fetchedResultsController.performFetch()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {}

