import Foundation

/// A pattern representing recurrence every N months, anchored to a specific day strategy.
public struct MonthlyPattern: Codable, Hashable, Sendable {

    /// Describes how a monthly occurrence is anchored within its month.
    public enum Anchor: Codable, Hashable, Sendable {
        /// Fixed days of the month (e.g., the 1st and 8th). Each day is
        /// clamped to the last valid day for shorter months.
        case daysOfMonth([Int])

        /// The Nth occurrences of a weekday (e.g., the 1st and 3rd Friday).
        /// Ordinals are 1-based and sorted.
        case weekdayOrdinals(ordinals: [Int], weekDay: WeekDay)

        /// The Nth weekend(s) of the month (e.g., the 1st and 3rd weekends).
        /// Each ordinal produces a Saturday–Sunday pair, keyed off the
        /// Saturday's position. Ordinals are 1-based and sorted.
        case weekendOrdinals([Int])

        /// The last day of the month.
        case lastDay

        /// The last occurrence of a specific weekday in the month.
        case lastWeekday(WeekDay)
    }

    /// The number of months between each occurrence.
    public let stepSize: Int

    /// The anchor strategy within each target month.
    public let anchor: Anchor

    public init(stepSize: Int, anchor: Anchor) {
        precondition(stepSize > 0, "Step size must be positive")
        if case .daysOfMonth(let days) = anchor {
            precondition(!days.isEmpty, "Must have at least one day")
        }
        if case .weekendOrdinals(let ordinals) = anchor {
            precondition(!ordinals.isEmpty, "Must have at least one weekend ordinal")
        }
        self.stepSize = stepSize
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
        let startComps = calendar.dateComponents([.year, .month], from: start)
        guard var year = startComps.year, var month = startComps.month else { return dates }

        outer: while true {
            let anchored = anchoredDates(year: year, month: month, calendar: calendar)
            for date in anchored {
                if date > end { break outer }
                if date >= start {
                    dates.append(date)
                }
            }
            month += stepSize
            while month > 12 {
                month -= 12
                year += 1
            }
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
        let startComps = calendar.dateComponents([.year, .month], from: start)
        guard var year = startComps.year, var month = startComps.month else { return dates }

        while dates.count < count {
            let anchored = anchoredDates(year: year, month: month, calendar: calendar)
            for date in anchored {
                if date >= start {
                    dates.append(date)
                    if dates.count >= count { return dates }
                }
            }
            month += stepSize
            while month > 12 {
                month -= 12
                year += 1
            }
        }
        return dates
    }

    // MARK: - Prediction

    /// Attempts to predict a monthly pattern from an array of dates.
    ///
    /// Returns a `MonthlyPattern` if the dates share a consistent monthly anchor
    /// and uniform month-step, or `nil` if no monthly pattern is found.
    ///
    /// Dates are normalized to start-of-day and deduplicated before analysis.
    /// An incomplete trailing month (fewer dates than previous months) is allowed.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> MonthlyPattern? {
        let sorted = dates.normalizedForPrediction(calendar: calendar)
        guard sorted.count >= 2 else { return nil }

        // Group dates by (year, month).
        let groups = groupByMonth(sorted, calendar: calendar)
        guard groups.count >= 2 else {
            // Need at least 2 months for step derivation (except multi-day
            // in a single month, which we can't derive step from).
            return nil
        }

        // Compute uniform month-step between consecutive groups.
        guard let stepSize = uniformMonthStepBetweenGroups(groups), stepSize > 0 else {
            return nil
        }

        // Try each anchor in order of specificity.
        if let anchor = detectLastDay(groups, calendar: calendar) {
            return MonthlyPattern(stepSize: stepSize, anchor: anchor)
        }
        if let anchor = detectDaysOfMonth(groups, calendar: calendar) {
            return MonthlyPattern(stepSize: stepSize, anchor: anchor)
        }
        if let anchor = detectWeekendOrdinals(groups, calendar: calendar) {
            return MonthlyPattern(stepSize: stepSize, anchor: anchor)
        }
        if let anchor = detectLastWeekday(sorted, calendar: calendar) {
            return MonthlyPattern(stepSize: stepSize, anchor: anchor)
        }
        if let anchor = detectWeekdayOrdinals(groups, calendar: calendar) {
            return MonthlyPattern(stepSize: stepSize, anchor: anchor)
        }

        return nil
    }

    // MARK: - Private Helpers

    /// Returns all resolved dates for the given year/month according to the anchor, sorted.
    private func anchoredDates(year: Int, month: Int, calendar: Calendar) -> [Date] {
        switch anchor {
        case .daysOfMonth(let days):
            return days.sorted().compactMap { day in
                dateForDayOfMonth(day, year: year, month: month, calendar: calendar)
            }

        case .weekdayOrdinals(let ordinals, let weekDay):
            return ordinals.sorted().compactMap { ordinal in
                dateForWeekdayOrdinal(
                    ordinal: ordinal, weekDay: weekDay,
                    year: year, month: month, calendar: calendar
                )
            }

        case .weekendOrdinals(let ordinals):
            return datesForWeekendOrdinals(
                ordinals, year: year, month: month, calendar: calendar
            )

        case .lastDay:
            if let d = dateForLastDay(year: year, month: month, calendar: calendar) {
                return [d]
            }
            return []

        case .lastWeekday(let weekDay):
            if let d = dateForLastWeekday(weekDay, year: year, month: month, calendar: calendar) {
                return [d]
            }
            return []
        }
    }

    private func dateForDayOfMonth(
        _ day: Int, year: Int, month: Int, calendar: Calendar
    ) -> Date? {
        guard let monthDate = calendar.date(from: DateComponents(year: year, month: month)),
              let range = calendar.range(of: .day, in: .month, for: monthDate)
        else { return nil }
        let clampedDay = min(day, range.upperBound - 1)
        return calendar.date(from: DateComponents(year: year, month: month, day: clampedDay))
    }

    private func dateForWeekdayOrdinal(
        ordinal: Int, weekDay: WeekDay,
        year: Int, month: Int, calendar: Calendar
    ) -> Date? {
        var comps = DateComponents(year: year, month: month)
        comps.weekday = weekDay.rawValue
        comps.weekdayOrdinal = ordinal
        return calendar.date(from: comps)
    }

    private func dateForLastDay(year: Int, month: Int, calendar: Calendar) -> Date? {
        guard let monthDate = calendar.date(from: DateComponents(year: year, month: month)),
              let range = calendar.range(of: .day, in: .month, for: monthDate) else {
            return nil
        }
        let lastDay = range.upperBound - 1
        return calendar.date(from: DateComponents(year: year, month: month, day: lastDay))
    }

    private func dateForLastWeekday(
        _ weekDay: WeekDay, year: Int, month: Int, calendar: Calendar
    ) -> Date? {
        var comps = DateComponents(year: year, month: month)
        comps.weekday = weekDay.rawValue
        comps.weekdayOrdinal = -1
        return calendar.date(from: comps)
    }

    /// Returns Saturday+Sunday pairs for the given weekend ordinals in a month.
    private func datesForWeekendOrdinals(
        _ ordinals: [Int], year: Int, month: Int, calendar: Calendar
    ) -> [Date] {
        var dates: [Date] = []
        for ordinal in ordinals.sorted() {
            // Find the Nth Saturday.
            var satComps = DateComponents(year: year, month: month)
            satComps.weekday = WeekDay.saturday.rawValue
            satComps.weekdayOrdinal = ordinal
            guard let saturday = calendar.date(from: satComps) else { continue }

            // Verify the Saturday is still in the target month.
            guard calendar.component(.month, from: saturday) == month else { continue }
            dates.append(saturday)

            // The Sunday following this Saturday.
            if let sunday = calendar.date(byAdding: .day, value: 1, to: saturday) {
                dates.append(sunday)
            }
        }
        return dates
    }

    // MARK: - Prediction Helpers

    /// A group of dates sharing the same (year, month).
    private struct MonthGroup {
        let year: Int
        let month: Int
        let dates: [Date]
    }

    /// Groups sorted dates by their (year, month), preserving order.
    private static func groupByMonth(
        _ dates: [Date], calendar: Calendar
    ) -> [MonthGroup] {
        var groups: [MonthGroup] = []
        var currentDates: [Date] = []
        var currentYear = -1
        var currentMonth = -1

        for date in dates {
            let y = calendar.component(.year, from: date)
            let m = calendar.component(.month, from: date)
            if y == currentYear && m == currentMonth {
                currentDates.append(date)
            } else {
                if !currentDates.isEmpty {
                    groups.append(MonthGroup(
                        year: currentYear, month: currentMonth, dates: currentDates
                    ))
                }
                currentYear = y
                currentMonth = m
                currentDates = [date]
            }
        }
        if !currentDates.isEmpty {
            groups.append(MonthGroup(
                year: currentYear, month: currentMonth, dates: currentDates
            ))
        }
        return groups
    }

    /// Returns the uniform month-step between consecutive groups, or `nil` if inconsistent.
    private static func uniformMonthStepBetweenGroups(_ groups: [MonthGroup]) -> Int? {
        guard groups.count >= 2 else { return nil }
        var step: Int?
        for i in 1..<groups.count {
            let totalMonths = (groups[i].year - groups[i - 1].year) * 12
                + (groups[i].month - groups[i - 1].month)
            guard totalMonths > 0 else { return nil }

            if let existing = step {
                guard existing == totalMonths else { return nil }
            } else {
                step = totalMonths
            }
        }
        return step
    }

    private static func detectDaysOfMonth(
        _ groups: [MonthGroup], calendar: Calendar
    ) -> Anchor? {
        let daySets = groups.map { group in
            Set(group.dates.map { calendar.component(.day, from: $0) })
        }
        guard let maxSet = daySets.max(by: { $0.count < $1.count }) else { return nil }

        // All groups must match the full set, or the last group may be
        // an incomplete trailing month (a subset of the full set).
        for (i, set) in daySets.enumerated() {
            if i == daySets.count - 1 {
                guard set.isSubset(of: maxSet) else { return nil }
            } else {
                guard set == maxSet else { return nil }
            }
        }

        return .daysOfMonth(maxSet.sorted())
    }

    private static func detectLastDay(
        _ groups: [MonthGroup], calendar: Calendar
    ) -> Anchor? {
        for group in groups {
            for date in group.dates {
                guard let range = calendar.range(of: .day, in: .month, for: date) else {
                    return nil
                }
                let lastDay = range.upperBound - 1
                let day = calendar.component(.day, from: date)
                guard day == lastDay else { return nil }
            }
            guard group.dates.count == 1 else { return nil }
        }
        return .lastDay
    }

    private static func detectWeekdayOrdinals(
        _ groups: [MonthGroup], calendar: Calendar
    ) -> Anchor? {
        // All dates must be the same weekday.
        let allDates = groups.flatMap(\.dates)
        let weekdays = Set(allDates.map { calendar.component(.weekday, from: $0) })
        guard weekdays.count == 1, let weekday = weekdays.first,
              let wd = WeekDay(rawValue: weekday) else {
            return nil
        }

        // For each month group, collect the ordinal set.
        var ordinalSets: [Set<Int>] = []
        for group in groups {
            let ordinals = Set(group.dates.map {
                calendar.component(.weekdayOrdinal, from: $0)
            })
            ordinalSets.append(ordinals)
        }

        guard let maxSet = ordinalSets.max(by: { $0.count < $1.count }) else { return nil }

        // All groups must match, or last may be trailing (subset).
        for (i, set) in ordinalSets.enumerated() {
            if i == ordinalSets.count - 1 {
                guard set.isSubset(of: maxSet) else { return nil }
            } else {
                guard set == maxSet else { return nil }
            }
        }

        return .weekdayOrdinals(ordinals: maxSet.sorted(), weekDay: wd)
    }

    private static func detectLastWeekday(
        _ dates: [Date], calendar: Calendar
    ) -> Anchor? {
        var expectedWeekday: Int?

        for date in dates {
            let weekday = calendar.component(.weekday, from: date)

            if let ew = expectedWeekday {
                guard weekday == ew else { return nil }
            } else {
                expectedWeekday = weekday
            }

            // Verify this is the last occurrence of this weekday in the month.
            guard let range = calendar.range(of: .day, in: .month, for: date) else { return nil }
            let day = calendar.component(.day, from: date)
            let daysRemaining = (range.upperBound - 1) - day
            guard daysRemaining < 7 else { return nil }
        }

        guard let weekday = expectedWeekday,
              let wd = WeekDay(rawValue: weekday) else {
            return nil
        }
        return .lastWeekday(wd)
    }

    private static func detectWeekendOrdinals(
        _ groups: [MonthGroup], calendar: Calendar
    ) -> Anchor? {
        // All dates must be Saturday or Sunday.
        let allDates = groups.flatMap(\.dates)
        guard allDates.allSatisfy({
            let wd = calendar.component(.weekday, from: $0)
            return wd == WeekDay.saturday.rawValue || wd == WeekDay.sunday.rawValue
        }) else {
            return nil
        }

        // For each month group, determine the set of weekend ordinals.
        // A weekend ordinal is the Saturday's weekdayOrdinal value.
        var ordinalSets: [Set<Int>] = []
        for group in groups {
            var ordinals = Set<Int>()
            for date in group.dates {
                let wd = calendar.component(.weekday, from: date)
                if wd == WeekDay.saturday.rawValue {
                    let ord = calendar.component(.weekdayOrdinal, from: date)
                    ordinals.insert(ord)
                } else {
                    // Sunday: its weekend ordinal is the preceding Saturday's ordinal.
                    // The preceding Saturday is 1 day before.
                    guard let saturday = calendar.date(byAdding: .day, value: -1, to: date) else {
                        return nil
                    }
                    // Verify the Saturday is in the same month or simply use
                    // its ordinal if it's a valid Saturday.
                    guard calendar.component(.weekday, from: saturday) == WeekDay.saturday.rawValue else {
                        return nil
                    }
                    let ord = calendar.component(.weekdayOrdinal, from: saturday)
                    ordinals.insert(ord)
                }
            }
            ordinalSets.append(ordinals)
        }

        guard let maxSet = ordinalSets.max(by: { $0.count < $1.count }) else { return nil }

        // All groups must match, or last group may be trailing (subset).
        for (i, set) in ordinalSets.enumerated() {
            if i == ordinalSets.count - 1 {
                guard set.isSubset(of: maxSet) else { return nil }
            } else {
                guard set == maxSet else { return nil }
            }
        }

        // Each full group must have exactly 2 dates per weekend ordinal
        // (Sat + Sun), or trailing may have fewer.
        let expectedCount = maxSet.count * 2
        for (i, group) in groups.enumerated() {
            if i < groups.count - 1 {
                guard group.dates.count == expectedCount else { return nil }
            }
        }

        return .weekendOrdinals(maxSet.sorted())
    }
}
