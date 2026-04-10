import Foundation

/// A pattern representing recurrence on weekends (Saturday and Sunday) every N weeks.
public struct WeekendsPattern: Codable, Hashable, Sendable {
    /// The number of weeks between each occurrence group.
    public let stepSize: Int

    public init(stepSize: Int) {
        precondition(stepSize > 0, "Step size must be positive")
        self.stepSize = stepSize
    }

    /// The underlying weekly pattern (Sat–Sun).
    var weeklyPattern: WeeklyPattern {
        WeeklyPattern(
            stepSize: stepSize,
            weekDays: [.saturday, .sunday]
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

    /// Attempts to predict a weekends pattern from an array of dates.
    ///
    /// Returns a `WeekendsPattern` if the dates match a weekly pattern whose
    /// weekdays are exactly Saturday and Sunday, or `nil` otherwise.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> WeekendsPattern? {
        guard let weekly = WeeklyPattern.predict(from: dates, calendar: calendar),
              weekly.weekDays.isWeekend else {
            return nil
        }
        return WeekendsPattern(stepSize: weekly.stepSize)
    }
}
