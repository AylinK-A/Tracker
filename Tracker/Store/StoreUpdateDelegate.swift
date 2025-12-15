import Foundation

protocol StoreUpdateDelegate: AnyObject {
    func storeWillChangeContent()
    func storeDidChangeContent()
    func storeDidChange(at updates: [StoreUpdate])
}

