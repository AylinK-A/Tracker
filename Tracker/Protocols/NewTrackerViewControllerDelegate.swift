import Foundation

protocol NewTrackerViewControllerDelegate: AnyObject {
    func createTracker(from state: NewTrackerState)
    func updateTracker(id: UUID, from state: NewTrackerState)
}

