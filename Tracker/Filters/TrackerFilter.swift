import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all = 0
    case today = 1
    case completed = 2
    case uncompleted = 3

    var title: String {
        switch self {
        case .all: return "Все трекеры"
        case .today: return "Трекеры на сегодня"
        case .completed: return "Завершенные"
        case .uncompleted: return "Не завершенные"
        }
    }
    
    var shouldShowCheckmark: Bool {
        switch self {
        case .completed, .uncompleted: return true
        case .all, .today: return false
        }
    }

    var isActiveFilter: Bool {
        switch self {
        case .completed, .uncompleted: return true
        case .all, .today: return false
        }
    }
}

