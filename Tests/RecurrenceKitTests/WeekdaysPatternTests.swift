import Testing
import Foundation
@testable import RecurrenceKit

@Suite("WeekdaysPattern")
struct WeekdaysPatternTests {

    let calendar = Calendar.test

    // MARK: - Prediction

    @Test func predictWeekdays() {
        // Mon–Fri for two weeks
        let dates = (1...5).map { makeDate(year: 2024, month: 1, day: $0) }
            + (8...12).map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = WeekdaysPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeekdaysPattern(stepSize: 1))
    }

    @Test func predictBiweeklyWeekdays() {
        // Mon–Fri week 1, skip week 2, Mon–Fri week 3
        let dates = (1...5).map { makeDate(year: 2024, month: 1, day: $0) }
            + (15...19).map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = WeekdaysPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeekdaysPattern(stepSize: 2))
    }

    @Test func predictReturnsNilForWeekends() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 14), // Sun
        ]
        #expect(WeekdaysPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForPartialWeekdays() {
        // Mon, Wed, Fri — not all five weekdays
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 3),  // Wed
            makeDate(year: 2024, month: 1, day: 5),  // Fri
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 10), // Wed
            makeDate(year: 2024, month: 1, day: 12), // Fri
        ]
        #expect(WeekdaysPattern.predict(from: dates, calendar: calendar) == nil)
    }

    // MARK: - Extraction by range

    @Test func extractWeekdaysInRange() {
        let pattern = WeekdaysPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 1) // Mon
        let end = makeDate(year: 2024, month: 1, day: 14)  // Sun
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == (1...5).map { makeDate(year: 2024, month: 1, day: $0) }
            + (8...12).map { makeDate(year: 2024, month: 1, day: $0) })
    }

    // MARK: - Extraction by count

    @Test func extractFirstFiveWeekdays() {
        let pattern = WeekdaysPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 1) // Mon
        let dates = pattern.extractDates(start: start, first: 5, calendar: calendar)
        #expect(dates == (1...5).map { makeDate(year: 2024, month: 1, day: $0) })
    }

    @Test func extractBiweeklyWeekdays() {
        let pattern = WeekdaysPattern(stepSize: 2)
        let start = makeDate(year: 2024, month: 1, day: 1) // Mon
        let dates = pattern.extractDates(start: start, first: 10, calendar: calendar)
        #expect(dates == (1...5).map { makeDate(year: 2024, month: 1, day: $0) }
            + (15...19).map { makeDate(year: 2024, month: 1, day: $0) })
    }
}
