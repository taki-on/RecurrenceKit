import Testing
import Foundation
@testable import DateRecurrencePattern

@Suite("DailyPattern")
struct DailyPatternTests {

    let calendar = Calendar.test

    // MARK: - Prediction

    @Test func predictEveryDay() {
        // Jan 1–4, 2024 (consecutive days)
        let dates = (1...4).map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(interval: 1))
    }

    @Test func predictEverySecondDay() {
        let dates = [1, 3, 5, 7].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(interval: 2))
    }

    @Test func predictEveryThirdDay() {
        let dates = [1, 4, 7, 10].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(interval: 3))
    }

    @Test func predictReturnsNilForIrregularDates() {
        let dates = [1, 2, 5, 10].map { makeDate(year: 2024, month: 1, day: $0) }
        #expect(DailyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForSingleDate() {
        let dates = [makeDate(year: 2024, month: 1, day: 1)]
        #expect(DailyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForEmptyArray() {
        #expect(DailyPattern.predict(from: [], calendar: calendar) == nil)
    }

    @Test func predictHandlesUnsortedInput() {
        // Dates given out of order should still be detected
        let dates = [5, 1, 3, 7].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(interval: 2))
    }

    // MARK: - Extraction by range

    @Test func extractEveryDayInRange() {
        let pattern = DailyPattern(interval: 1)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 1, day: 3)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 2),
            makeDate(year: 2024, month: 1, day: 3),
        ])
    }

    @Test func extractEverySecondDayInRange() {
        let pattern = DailyPattern(interval: 2)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 1, day: 5)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 3),
            makeDate(year: 2024, month: 1, day: 5),
        ])
    }

    // MARK: - Extraction by count

    @Test func extractFirstThreeDaysWithInterval2() {
        let pattern = DailyPattern(interval: 2)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 3),
            makeDate(year: 2024, month: 1, day: 5),
        ])
    }

    @Test func extractAcrossMonthBoundary() {
        let pattern = DailyPattern(interval: 1)
        let start = makeDate(year: 2024, month: 1, day: 30)
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 30),
            makeDate(year: 2024, month: 1, day: 31),
            makeDate(year: 2024, month: 2, day: 1),
            makeDate(year: 2024, month: 2, day: 2),
        ])
    }
}
