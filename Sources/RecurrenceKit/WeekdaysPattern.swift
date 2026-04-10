import Foundation

/// A pattern representing recurrence on weekdays (Monday through Friday) every N weeks.
public struct WeekdaysPattern: Codable, Hashable, Sendable {
    /// The number of weeks between each occurrence group.
    public let stepSize: Int

    public init(stepSize: Int) {
        precondition(stepSize > 0, "Step size must be positive")
        self.stepSize = stepSize
    }

    /// The underlying weekly pattern (Mon–Fri).
    var weeklyPattern: WeeklyPattern {
        WeeklyPattern(
            stepSize: stepSize,
            weekDays: [.monday, .tuesday, .wednesday, .thursday, .friday]
        )
    }

    /// Extracts all dates matching this pattern between `start` and `end` (inclusive).
    public func extractDates(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        weeklyPattern.extractDates(start: start, end: end, calendar: calendar)
    }

    /// Extracts the first `count` dates matching this pattern starting from `start`.
    public func extractDates(
        start: Date,
        first count: Int,
        calendar: Calendar = .current
    ) -> [Date] {
        weeklyPattern.extractDates(start: start, first: count, calendar: calendar)
    }

    /// Attempts to predict a weekdays pattern from an array of dates.
    ///
    /// Returns a `WeekdaysPattern` if the dates match a weekly pattern whose
    /// weekdays are exactly Monday through Friday, or `nil` otherwise.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> WeekdaysPattern? {
        guard let weekly = WeeklyPattern.predict(from: dates, calendar: calendar),
              weekly.weekDays.isWeekdays else {
            return nil
        }
        return WeekdaysPattern(stepSize: weekly.stepSize)
    }
}
