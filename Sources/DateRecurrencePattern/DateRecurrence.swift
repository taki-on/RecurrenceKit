import Foundation

/// A fully resolved recurrence: a start date, end date, and the detected pattern.
public struct DateRecurrence: Codable, Hashable, Sendable {
    public let startDate: Date
    public let endDate: Date
    public let pattern: RecurrencePattern

    public init(startDate: Date, endDate: Date, pattern: RecurrencePattern) {
        self.startDate = startDate
        self.endDate = endDate
        self.pattern = pattern
    }

    /// Attempts to detect a recurrence from an array of dates.
    ///
    /// Returns `nil` if the input is empty. The `endDate` is derived by extracting
    /// the recommended number of future dates from the detected pattern.
    public static func make(
        from dates: [Date],
        calendar: Calendar = .current
    ) -> DateRecurrence? {
        let sorted = dates.sorted()
        guard let start = sorted.first else { return nil }

        let pattern = RecurrencePattern.predict(from: sorted, calendar: calendar)
        let extractedDates = pattern.extractDates(
            start: start,
            first: pattern.recommendedExtractionCount,
            calendar: calendar
        )

        guard let end = extractedDates.last else { return nil }
        return DateRecurrence(startDate: start, endDate: end, pattern: pattern)
    }

    /// Extracts the first `count` dates from this recurrence.
    public func extractDates(
        first count: Int,
        calendar: Calendar = .current
    ) -> [Date] {
        pattern.extractDates(start: startDate, first: count, calendar: calendar)
    }
}
