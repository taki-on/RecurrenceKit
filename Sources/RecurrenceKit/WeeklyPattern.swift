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
    ///
    /// Dates are normalized to start-of-day and deduplicated before analysis.
    /// An incomplete trailing week (fewer dates than previous weeks) is allowed.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> WeeklyPattern? {
        let sorted = dates.normalizedForPrediction(calendar: calendar)
        guard sorted.count >= 2 else { return nil }

        // Group dates by their weekday
        var datesByWeekday: [Int: [Date]] = [:]
        for date in sorted {
            let weekday = calendar.component(.weekday, from: date)
            datesByWeekday[weekday, default: []].append(date)
        }

        // All weekday groups must have the same count, or some may have
        // exactly one fewer date (an incomplete trailing week).
        let counts = datesByWeekday.values.map(\.count)
        guard let maxCount = counts.max() else { return nil }
        let allValid = counts.allSatisfy { $0 == maxCount || $0 == maxCount - 1 }
        guard allValid, maxCount >= 2 else {
            // Need at least one weekday with 2+ dates for step derivation.
            // When all have count 1 we can't determine step size.
            return nil
        }

        // If there's a trailing incomplete week, verify the "short" weekdays
        // correspond to later-in-week days (they are the ones missing from the
        // final week). We do this by checking that every short-count weekday's
        // last date is earlier than every full-count weekday's last date.
        if counts.contains(maxCount - 1) {
            let fullWeekdayLastDates = datesByWeekday
                .filter { $0.value.count == maxCount }
                .values.map { $0.last! }
            let shortWeekdayLastDates = datesByWeekday
                .filter { $0.value.count == maxCount - 1 }
                .values.map { $0.last! }

            guard let latestShort = shortWeekdayLastDates.max(),
                  let earliestFull = fullWeekdayLastDates.min() else { return nil }
            guard latestShort < earliestFull else { return nil }
        }

        // Determine step size using day-based calculation (robust across year boundaries).
        var stepSize: Int?
        for weekdayDates in datesByWeekday.values {
            guard weekdayDates.count >= 2 else { continue }
            for i in 1..<weekdayDates.count {
                let dayDiff = calendar.dateComponents(
                    [.day],
                    from: weekdayDates[i - 1],
                    to: weekdayDates[i]
                ).day
                guard let dayDiff, dayDiff > 0, dayDiff.isMultiple(of: 7) else { return nil }
                let weeks = dayDiff / 7

                if let existing = stepSize {
                    guard existing == weeks else { return nil }
                } else {
                    stepSize = weeks
                }
            }
        }

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
