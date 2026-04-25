import Foundation

extension Array where Element == Date {
    /// Returns a sorted array of dates normalized to start-of-day with duplicates removed.
    func normalizedForPrediction(calendar: Calendar) -> [Date] {
        let normalized = compactMap { calendar.startOfDay(for: $0) }
        var seen = Set<Date>()
        return normalized.sorted().filter { seen.insert($0).inserted }
    }
}
