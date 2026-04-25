import Foundation

/// A pattern representing recurrence every N years in a specific month.
public struct YearlyPattern: Codable, Hashable, Sendable {

    /// Describes how a yearly occurrence is anchored within its target month.
    public enum Anchor: Codable, Hashable, Sendable {
        /// A fixed day of the month (e.g., March 15th).
        /// Clamped to the last valid day for shorter months.
        case dayOfMonth(Int)

        /// The Nth occurrence of a weekday (e.g., 3rd Monday of January).
        /// `ordinal` is 1-based.
        case weekdayOrdinal(ordinal: Int, weekDay: WeekDay)

        /// The last day of the month.
        case lastDay

        /// The last occurrence of a specific weekday in the month.
        case lastWeekday(WeekDay)
    }

    /// The number of years between each occurrence.
    public let stepSize: Int

    /// The month in which the pattern occurs (1–12).
    public let month: Int

    /// The anchor strategy within the target month.
    public let anchor: Anchor

    public init(stepSize: Int, month: Int, anchor: Anchor) {
        precondition(stepSize > 0, "Step size must be positive")
        precondition((1...12).contains(month), "Month must be 1–12")
        self.stepSize = stepSize
        self.month = month
        self.anchor = anchor
    }

    // MARK: - Extraction by range

    /// Extracts all dates matching this pattern between `start` and `end` (inclusive).
    public func extractDates(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        var dates: [Date] = []
        let startComps = calendar.dateComponents([.year], from: start)
        guard var year = startComps.year else { return dates }

        while true {
            if let date = anchoredDate(year: year, calendar: calendar) {
                if date > end { break }
                if date >= start {
                    dates.append(date)
                }
            }
            year += stepSize
        }
        return dates
    }

    // MARK: - Extraction by count

    /// Extracts the first `count` dates matching this pattern starting from `start`.
    public func extractDates(
        start: Date,
        first count: Int,
        calendar: Calendar = .current
    ) -> [Date] {
        guard count > 0 else { return [] }
        var dates: [Date] = []
        let startComps = calendar.dateComponents([.year], from: start)
        guard var year = startComps.year else { return dates }

        while dates.count < count {
            if let date = anchoredDate(year: year, calendar: calendar) {
                if date >= start {
                    dates.append(date)
                }
            }
            year += stepSize
        }
        return dates
    }

    // MARK: - Prediction

    /// Attempts to predict a yearly pattern from an array of dates.
    ///
    /// Returns a `YearlyPattern` if the dates share the same month, a consistent
    /// yearly anchor, and uniform year-step, or `nil` if no yearly pattern is found.
    ///
    /// Dates are normalized to start-of-day and deduplicated before analysis.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> YearlyPattern? {
        let sorted = dates.normalizedForPrediction(calendar: calendar)
        guard sorted.count >= 2 else { return nil }

        // All dates must be in the same month.
        let months = Set(sorted.map { calendar.component(.month, from: $0) })
        guard months.count == 1, let month = months.first else { return nil }

        // One date per year.
        let years = sorted.map { calendar.component(.year, from: $0) }
        let uniqueYears = Set(years)
        guard uniqueYears.count == sorted.count else { return nil }

        // Compute uniform year-step.
        guard let stepSize = uniformYearStep(years) else { return nil }

        // Try each anchor in order of specificity.
        if detectLastDay(sorted, calendar: calendar) {
            return YearlyPattern(stepSize: stepSize, month: month, anchor: .lastDay)
        }
        if let day = detectDayOfMonth(sorted, calendar: calendar) {
            return YearlyPattern(stepSize: stepSize, month: month, anchor: .dayOfMonth(day))
        }
        if let (weekDay, _) = detectLastWeekday(sorted, calendar: calendar) {
            return YearlyPattern(stepSize: stepSize, month: month, anchor: .lastWeekday(weekDay))
        }
        if let (ordinal, weekDay) = detectWeekdayOrdinal(sorted, calendar: calendar) {
            return YearlyPattern(
                stepSize: stepSize, month: month,
                anchor: .weekdayOrdinal(ordinal: ordinal, weekDay: weekDay)
            )
        }

        return nil
    }

    // MARK: - Private Helpers

    private func anchoredDate(year: Int, calendar: Calendar) -> Date? {
        switch anchor {
        case .dayOfMonth(let day):
            return dateForDayOfMonth(day, year: year, calendar: calendar)
        case .weekdayOrdinal(let ordinal, let weekDay):
            return dateForWeekdayOrdinal(
                ordinal: ordinal, weekDay: weekDay, year: year, calendar: calendar
            )
        case .lastDay:
            return dateForLastDay(year: year, calendar: calendar)
        case .lastWeekday(let weekDay):
            return dateForLastWeekday(weekDay, year: year, calendar: calendar)
        }
    }

    private func dateForDayOfMonth(
        _ day: Int, year: Int, calendar: Calendar
    ) -> Date? {
        guard let monthDate = calendar.date(
            from: DateComponents(year: year, month: month)
        ), let range = calendar.range(of: .day, in: .month, for: monthDate) else {
            return nil
        }
        let clampedDay = min(day, range.upperBound - 1)
        return calendar.date(from: DateComponents(year: year, month: month, day: clampedDay))
    }

    private func dateForWeekdayOrdinal(
        ordinal: Int, weekDay: WeekDay, year: Int, calendar: Calendar
    ) -> Date? {
        var comps = DateComponents(year: year, month: month)
        comps.weekday = weekDay.rawValue
        comps.weekdayOrdinal = ordinal
        return calendar.date(from: comps)
    }

    private func dateForLastDay(year: Int, calendar: Calendar) -> Date? {
        guard let monthDate = calendar.date(
            from: DateComponents(year: year, month: month)
        ), let range = calendar.range(of: .day, in: .month, for: monthDate) else {
            return nil
        }
        let lastDay = range.upperBound - 1
        return calendar.date(from: DateComponents(year: year, month: month, day: lastDay))
    }

    private func dateForLastWeekday(
        _ weekDay: WeekDay, year: Int, calendar: Calendar
    ) -> Date? {
        var comps = DateComponents(year: year, month: month)
        comps.weekday = weekDay.rawValue
        comps.weekdayOrdinal = -1
        return calendar.date(from: comps)
    }

    // MARK: - Prediction Helpers

    private static func uniformYearStep(_ years: [Int]) -> Int? {
        guard years.count >= 2 else { return nil }
        var step: Int?
        for i in 1..<years.count {
            let diff = years[i] - years[i - 1]
            guard diff > 0 else { return nil }
            if let existing = step {
                guard existing == diff else { return nil }
            } else {
                step = diff
            }
        }
        return step
    }

    private static func detectDayOfMonth(
        _ dates: [Date], calendar: Calendar
    ) -> Int? {
        let days = dates.map { calendar.component(.day, from: $0) }
        guard let first = days.first, days.allSatisfy({ $0 == first }) else {
            return nil
        }
        return first
    }

    private static func detectLastDay(
        _ dates: [Date], calendar: Calendar
    ) -> Bool {
        dates.allSatisfy { date in
            guard let range = calendar.range(of: .day, in: .month, for: date) else {
                return false
            }
            return calendar.component(.day, from: date) == range.upperBound - 1
        }
    }

    private static func detectWeekdayOrdinal(
        _ dates: [Date], calendar: Calendar
    ) -> (Int, WeekDay)? {
        var expectedWeekday: Int?
        var expectedOrdinal: Int?

        for date in dates {
            let weekday = calendar.component(.weekday, from: date)
            let ordinal = calendar.component(.weekdayOrdinal, from: date)

            if let ew = expectedWeekday, let eo = expectedOrdinal {
                guard weekday == ew, ordinal == eo else { return nil }
            } else {
                expectedWeekday = weekday
                expectedOrdinal = ordinal
            }
        }

        guard let weekday = expectedWeekday,
              let ordinal = expectedOrdinal,
              let wd = WeekDay(rawValue: weekday) else {
            return nil
        }
        return (ordinal, wd)
    }

    private static func detectLastWeekday(
        _ dates: [Date], calendar: Calendar
    ) -> (WeekDay, Bool)? {
        var expectedWeekday: Int?

        for date in dates {
            let weekday = calendar.component(.weekday, from: date)

            if let ew = expectedWeekday {
                guard weekday == ew else { return nil }
            } else {
                expectedWeekday = weekday
            }

            guard let range = calendar.range(of: .day, in: .month, for: date) else {
                return nil
            }
            let day = calendar.component(.day, from: date)
            let daysRemaining = (range.upperBound - 1) - day
            guard daysRemaining < 7 else { return nil }
        }

        guard let weekday = expectedWeekday,
              let wd = WeekDay(rawValue: weekday) else {
            return nil
        }
        return (wd, true)
    }
}
