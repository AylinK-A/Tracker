import Foundation

extension Date {
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func isFutureDate() -> Bool {
        return Calendar.current.compare(self, to: Date(), toGranularity: .day) == .orderedDescending
    }
    
    func excludeTime() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
