import Foundation
import CoreData

final class CategoryListViewModel {

    // MARK: - Outputs (bindings)
    var onChange: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onSelectCategory: ((TrackerCategory) -> Void)?

    // MARK: - Dependencies
    private let store: TrackerCategoryStore

    // MARK: - State
    private var items: [TrackerCategoryCoreData] = []
    private(set) var selectedTitle: String?

    // MARK: - Init
    init(store: TrackerCategoryStore = TrackerCategoryStore(),
         selectedTitle: String? = nil) {
        self.store = store
        self.selectedTitle = selectedTitle
    }

    // MARK: - Public API for ViewController

    func load() {
        items = store.fetchAll()
        onChange?()
    }

    func numberOfRows() -> Int {
        items.count
    }

    func title(at index: Int) -> String {
        items[index].title ?? ""
    }

    func isSelected(at index: Int) -> Bool {
        title(at: index) == selectedTitle
    }

    func didSelectRow(at index: Int) {
        let title = self.title(at: index)
        selectedTitle = title
        onSelectCategory?(TrackerCategory(title: title, trackers: []))
        onChange?()
    }

    func addCategory(title: String) {
        do {
            let createdOrExisting = try store.createCategoryIfNeeded(title: title)
            selectedTitle = createdOrExisting.title
            load()
            onSelectCategory?(createdOrExisting)
        } catch {
            onError?(error)
        }
    }

    // MARK: - Edit / Delete (для лонгтапа)

    func rename(at index: Int, to newTitle: String) {
        do {
            let objectID = items[index].objectID
            try store.renameCategory(objectID: objectID, newTitle: newTitle)

            if selectedTitle == title(at: index) {
                selectedTitle = newTitle
            }
            load()
        } catch {
            onError?(error)
        }
    }

    func delete(at index: Int) {
        do {
            let objectID = items[index].objectID
            let deletedTitle = title(at: index)

            try store.deleteCategory(objectID: objectID)

            if selectedTitle == deletedTitle {
                selectedTitle = nil
            }
            load()
        } catch {
            onError?(error)
        }
    }

    func categoryTitleForEdit(at index: Int) -> String {
        title(at: index)
    }
}

