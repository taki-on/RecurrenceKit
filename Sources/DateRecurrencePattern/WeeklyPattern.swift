import Foundation

/// A pattern representing recurrence every N weeks on specific days.
public struct WeeklyPattern: Codable, Hashable, Sendable {
    /// The number of weeks between each occurrence group.
    public let stepSize: Int

    /// The days of the week on which this pattern occurs.
    public let weekDays: [WeekDay]

    public init(stepSize: Int, weekDays: [WeekDay]) {
        precondition(stepSize > 0, "Step size must be positive")
        precondition(!weekDays.isEmpty, "Must have at least one weekday")
        self.stepSize = stepSize
        self.weekDays = weekDays
    }

    /// Extracts all dates matching this pattern between `start` and `end` (inclusive).
    public func extractDates(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        var dates: [Date] = []
        var weekStart = startOfWeek(containing: start, calendar: calendar)

        while weekStart <= end {
            for weekDay in weekDays.sorted(by: { $0.rawValue < $1.rawValue }) {
                guard let date = dateForWeekday(weekDay, inWeekOf: weekStart, calendar: calendar) else {
                    continue
                }
                if date >= start && date <= end {
                    dates.append(date)
                }
            }
            guard let next = calendar.date(byAdding: .weekOfYear, value: stepSize, to: weekStart) else {
                break
            }
            weekStart = next
        }
        return dates
    }

    /// Extracts the first `count` dates matching this pattern starting from `start`.
    public func extractDates(
        start: Date,
        first count: Int,
        calendar: Calendar = .current
    ) -> [Date] {
        var dates: [Date] = []
        var weekStart = startOfWeek(containing: start, calendar: calendar)

        while dates.count < count {
            for weekDay in weekDays.sorted(by: { $0.rawValue < $1.rawValue }) {
                guard let date = dateForWeekday(weekDay, inWeekOf: weekStart, calendar: calendar) else {
                    continue
                }
                if date >= start {
                    dates.append(date)
                    if dates.count >= count { return dates }
                }
            }
            guard let next = calendar.date(byAdding: .weekOfYear, value: stepSize, to: weekStart) else {
                break
            }
            weekStart = next
        }
        return dates
    }

    /// Attempts to predict a weekly pattern from an array of dates.
    ///
    /// Returns a `WeeklyPattern` if the dates fall on consistent weekdays with
    /// a uniform week-step between groups, or `nil` if no weekly pattern is found.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> WeeklyPattern? {
        let sorted = dates.sorted()
        guard sorted.count >= 2 else { return nil }

        // Group dates by their weekday
        var datesByWeekday: [Int: [Date]] = [:]
        for date in sorted {
            let weekday = calendar.component(.weekday, from: date)
            datesByWeekday[weekday, default: []].append(date)
        }

        // All weekdays must have the same number of dates
        let counts = Set(datesByWeekday.values.map(\.count))
        guard counts.count == 1 else { return nil }

        // Determine step size from week-of-year gaps
        var stepSize: Int?
        for weekdayDates in datesByWeekday.values {
            guard weekdayDates.count >= 2 else { continue }
            for i in 1..<weekdayDates.count {
                let weeks = calendar.dateComponents(
                    [.weekOfYear],
                    from: weekdayDates[i - 1],
                    to: weekdayDates[i]
                ).weekOfYear
                guard let weeks, weeks > 0 else { return nil }

                if let existing = stepSize {
                    guard existing == weeks else { return nil }
                } else {
                    stepSize = weeks
                }
            }
        }

        // If every weekday has only one date, we can't determine step size from gaps.
        // Require at least one weekday with 2+ dates so we can derive the step.
        guard let stepSize else { return nil }

        let weekDays = datesByWeekday.keys
            .sorted()
            .compactMap { WeekDay(rawValue: $0) }
        guard !weekDays.isEmpty else { return nil }

        return WeeklyPattern(stepSize: stepSize, weekDays: weekDays)
    }

    // MARK: - Private Helpers

    private func startOfWeek(containing date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: date
        )
        return calendar.date(from: components) ?? date
    }

    private func dateForWeekday(
        _ weekDay: WeekDay,
        inWeekOf weekStart: Date,
        calendar: Calendar
    ) -> Date? {
        var components = calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: weekStart
        )
        components.weekday = weekDay.rawValue
        return calendar.date(from: components)
    }
}
