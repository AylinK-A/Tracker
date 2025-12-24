import UIKit

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard
            let id = trackerID,
            let title = title,
            let emoji = emoji
        else { return nil }

        let uiColor = (color as? UIColor) ?? .lightGray

        let weekdaysSet = schedule as? Set<WeekdayCoreData> ?? []
        let weekdays = weekdaysSet.compactMap { Weekday(rawValue: Int($0.rawValue)) }

        return Tracker(
            id: id,
            title: title,
            color: uiColor,
            emoji: emoji,
            schedule: Set(weekdays)
        )
    }
}

