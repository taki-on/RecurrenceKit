import Foundation

/// A pattern representing recurrence every N days.
public struct DailyPattern: Codable, Hashable, Sendable {
    /// The number of days between each occurrence.
    public let interval: Int

    public init(interval: Int) {
        precondition(interval > 0, "Interval must be positive")
        self.interval = interval
    }

    /// Extracts all dates matching this pattern between `start` and `end` (inclusive).
    public func extractDates(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        var dates: [Date] = []
        var current = start
        while current <= end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: interval, to: current) else { break }
            current = next
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
        var current = start
        for _ in 0..<count {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: interval, to: current) else { break }
            current = next
        }
        return dates
    }

    /// Attempts to predict a daily pattern from an array of dates.
    ///
    /// Returns a `DailyPattern` if all consecutive dates are separated by the same
    /// number of days, or `nil` if no consistent interval is found.
    public static func predict(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> DailyPattern? {
        let sorted = dates.sorted()
        guard sorted.count >= 2 else { return nil }

        var expectedInterval: Int?
        for i in 1..<sorted.count {
            let days = calendar.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day
            guard let days, days > 0 else { return nil }

            if let expected = expectedInterval {
                guard days == expected else { return nil }
            } else {
                expectedInterval = days
            }
        }

        guard let interval = expectedInterval else { return nil }
        return DailyPattern(interval: interval)
    }
}
