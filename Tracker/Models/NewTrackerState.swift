import UIKit

struct NewTrackerState {
    var title: String = ""
    var categoryTitle: String = ""
    var schedule: Set<Weekday> = []
    var emoji: String = ""
    var color: UIColor? = nil       
    var isReady: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !emoji.isEmpty &&
        color != nil
    }
}
