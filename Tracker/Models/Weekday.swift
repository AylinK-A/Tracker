enum Weekday: Int, CaseIterable {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var shortString: String {
        switch self {
        case .sunday: return "Вс"
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        }
    }
    
    var longString: String {
        switch self {
        case .sunday: return "Воскресенье"
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        }
    }
    
    static let ordered: [Weekday] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday
    ]
    
    static func formattedWeekdays(_ days: [Weekday]) -> String {
        guard !days.isEmpty else { return "" }
        guard !(days.count == allCases.count) else { return "Каждый день" }
        
        let orderedDays = ordered.filter { days.contains($0) }
        let orderedDaysString = orderedDays.map { $0.shortString }.joined(separator: ", ")
        return orderedDaysString
    }
    
}
