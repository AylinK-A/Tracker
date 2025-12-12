import UIKit

struct NewTrackerState {
    var title: String
    var category: String
    var schedule: Set<Weekday>
    var emoji: String
    var color: UIColor?
    
    var isReady: Bool {
        !title.isEmpty &&
        !schedule.isEmpty
    }
}
