import Foundation

extension Array where Element == Date {
    /// Returns a sorted array of dates normalized to start-of-day with duplicates removed.
    func normalizedForPrediction(calendar: Calendar) -> [Date] {
        let normalized = compactMap { calendar.startOfDay(for: $0) }
        let unique = NSOrderedSet(array: normalized).array as! [Date]
        return unique.sorted()
    }
}
