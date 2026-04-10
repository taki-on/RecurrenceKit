import Foundation

/// Represents a detected or specified recurrence pattern for dates.
public enum RecurrencePattern: Codable, Hashable, Sendable {
    case daily(DailyPattern)
    case weekly(WeeklyPattern)
    // TODO: case monthly(MonthlyPattern)
    case unknown([Date])

    /// Suggested number of dates to extract for a preview.
    public var recommendedExtractionCount: Int {
        switch self {
        case .daily: 10
        case .weekly: 10
        case .unknown(let dates): dates.count
        }
    }

    /// Attempts to detect a recurrence pattern from an array of dates.
    ///
    /// Tries weekly first (more specific), then daily. Falls back to `.unknown`
    /// if no pattern is detected.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> RecurrencePattern {
        if let pattern = WeeklyPattern.predict(from: dates, calendar: calendar) {
            return .weekly(pattern)
        } else if let pattern = DailyPattern.predict(from: dates, calendar: calendar) {
            return .daily(pattern)
        }
        return .unknown(dates)
    }

    /// Extracts all dates matching this pattern between `start` and `end` (inclusive).
    public func extractDates(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        switch self {
        case .daily(let pattern):
            pattern.extractDates(start: start, end: end, calendar: calendar)
        case .weekly(let pattern):
            pattern.extractDates(start: start, end: end, calendar: calendar)
        case .unknown(let dates):
            dates.filter { $0 >= start && $0 <= end }
        }
    }

    /// Extracts the first `count` dates matching this pattern starting from `start`.
    public func extractDates(
        start: Date,
        first count: Int,
        calendar: Calendar = .current
    ) -> [Date] {
        switch self {
        case .daily(let pattern):
            pattern.extractDates(start: start, first: count, calendar: calendar)
        case .weekly(let pattern):
            pattern.extractDates(start: start, first: count, calendar: calendar)
        case .unknown(let dates):
            Array(dates.prefix(count))
        }
    }
}
