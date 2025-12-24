import Foundation

protocol TrackerStoreDelegate: AnyObject {
    func storeDidReloadFRC(_ store: TrackerStore)
    func store(_ store: TrackerStore, didUpdate update: StoreUpdate)
}

