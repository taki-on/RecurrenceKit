import Foundation

/// Represents a detected or specified recurrence pattern for dates.
public enum RecurrencePattern: Codable, Hashable, Sendable {
    case daily(DailyPattern)
    case weekdays(WeekdaysPattern)
    case weekends(WeekendsPattern)
    case weekly(WeeklyPattern)
    case monthly(MonthlyPattern)
    case yearly(YearlyPattern)
    case unknown([Date])

    /// Suggested number of dates to extract for a preview.
    public var recommendedExtractionCount: Int {
        switch self {
        case .daily: 10
        case .weekdays: 10
        case .weekends: 10
        case .weekly: 10
        case .monthly: 12
        case .yearly: 5
        case .unknown(let dates): dates.count
        }
    }

    /// Attempts to detect a recurrence pattern from an array of dates.
    ///
    /// Tries yearly and monthly first (most specific), then weekdays/weekends,
    /// weekly, and finally daily. Falls back to `.unknown` if no pattern is detected.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> RecurrencePattern {
        if let pattern = YearlyPattern.predict(from: dates, calendar: calendar) {
            return .yearly(pattern)
        } else if let pattern = MonthlyPattern.predict(from: dates, calendar: calendar) {
            return .monthly(pattern)
        } else if let pattern = WeekdaysPattern.predict(from: dates, calendar: calendar) {
            return .weekdays(pattern)
        } else if let pattern = WeekendsPattern.predict(from: dates, calendar: calendar) {
            return .weekends(pattern)
        } else if let pattern = WeeklyPattern.predict(from: dates, calendar: calendar) {
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
        case .weekdays(let pattern):
            pattern.extractDates(start: start, end: end, calendar: calendar)
        case .weekends(let pattern):
            pattern.extractDates(start: start, end: end, calendar: calendar)
        case .weekly(let pattern):
            pattern.extractDates(start: start, end: end, calendar: calendar)
        case .monthly(let pattern):
            pattern.extractDates(start: start, end: end, calendar: calendar)
        case .yearly(let pattern):
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
        case .weekdays(let pattern):
            pattern.extractDates(start: start, first: count, calendar: calendar)
        case .weekends(let pattern):
            pattern.extractDates(start: start, first: count, calendar: calendar)
        case .weekly(let pattern):
            pattern.extractDates(start: start, first: count, calendar: calendar)
        case .monthly(let pattern):
            pattern.extractDates(start: start, first: count, calendar: calendar)
        case .yearly(let pattern):
            pattern.extractDates(start: start, first: count, calendar: calendar)
        case .unknown(let dates):
            Array(dates.prefix(count))
        }
    }

    /// Extracts all dates matching this pattern between `cutoff` and `end` (inclusive),
    /// using `anchor` as the phase reference for patterns with `stepSize > 1`.
    ///
    /// Unlike `extractDates(start:end:)`, which uses `start` as both the phase anchor and
    /// the lower bound, this keeps the phase fixed when `cutoff` moves (for example, "today").
    /// `anchor` should be the earliest date the pattern was predicted from.
    public func extractDates(
        anchor: Date,
        after cutoff: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        extractDates(start: anchor, end: end, calendar: calendar).filter { $0 >= cutoff }
    }

    /// Extracts the first `count` dates at or after `cutoff`, using `anchor` as the phase
    /// reference for patterns with `stepSize > 1`.
    ///
    /// Equivalent to `extractDates(start: anchor, first: ...)` with the dates before `cutoff`
    /// skipped, so the result does not depend on when `cutoff` falls within a step.
    public func extractDates(
        anchor: Date,
        after cutoff: Date,
        first count: Int,
        calendar: Calendar = .current
    ) -> [Date] {
        guard count > 0 else { return [] }
        if case .unknown(let dates) = self {
            return Array(dates.filter { $0 >= cutoff }.prefix(count))
        }
        let skipped = extractDates(start: anchor, end: cutoff, calendar: calendar)
            .lazy.filter { $0 < cutoff }.count
        return Array(
            extractDates(start: anchor, first: skipped + count, calendar: calendar)
                .lazy.filter { $0 >= cutoff }.prefix(count)
        )
    }
}
