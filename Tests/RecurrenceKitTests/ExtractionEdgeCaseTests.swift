import Testing
import Foundation
@testable import RecurrenceKit

@Suite("Extraction Edge Cases")
struct ExtractionEdgeCaseTests {

    let calendar = Calendar.test

    // MARK: - Year boundary extraction

    @Test func dailyExtractionAcrossYearBoundary() {
        let pattern = DailyPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 12, day: 30)
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 12, day: 30),
            makeDate(year: 2024, month: 12, day: 31),
            makeDate(year: 2025, month: 1, day: 1),
            makeDate(year: 2025, month: 1, day: 2),
        ])
    }

    @Test func dailyExtractionAcrossYearBoundaryByRange() {
        let pattern = DailyPattern(stepSize: 2)
        let start = makeDate(year: 2024, month: 12, day: 29)
        let end = makeDate(year: 2025, month: 1, day: 4)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 12, day: 29),
            makeDate(year: 2024, month: 12, day: 31),
            makeDate(year: 2025, month: 1, day: 2),
            makeDate(year: 2025, month: 1, day: 4),
        ])
    }

    @Test func weeklyExtractionAcrossYearBoundary() {
        let pattern = WeeklyPattern(stepSize: 1, weekDays: [.monday])
        let start = makeDate(year: 2024, month: 12, day: 23) // Mon
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 12, day: 23),
            makeDate(year: 2024, month: 12, day: 30),
            makeDate(year: 2025, month: 1, day: 6),
        ])
    }

    @Test func weeklyMultipleDaysExtractionAcrossYearBoundary() {
        let pattern = WeeklyPattern(stepSize: 1, weekDays: [.monday, .friday])
        let start = makeDate(year: 2024, month: 12, day: 27) // Fri
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 12, day: 27), // Fri
            makeDate(year: 2024, month: 12, day: 30), // Mon
            makeDate(year: 2025, month: 1, day: 3),   // Fri
            makeDate(year: 2025, month: 1, day: 6),   // Mon
        ])
    }

    // MARK: - start > end

    @Test func dailyExtractionStartAfterEnd() {
        let pattern = DailyPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 10)
        let end = makeDate(year: 2024, month: 1, day: 5)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func weeklyExtractionStartAfterEnd() {
        let pattern = WeeklyPattern(stepSize: 1, weekDays: [.monday])
        let start = makeDate(year: 2024, month: 1, day: 15)
        let end = makeDate(year: 2024, month: 1, day: 8)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func weekdaysExtractionStartAfterEnd() {
        let pattern = WeekdaysPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 15)
        let end = makeDate(year: 2024, month: 1, day: 8)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func weekendsExtractionStartAfterEnd() {
        let pattern = WeekendsPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 15)
        let end = makeDate(year: 2024, month: 1, day: 8)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates.isEmpty)
    }

    // MARK: - count = 0

    @Test func dailyExtractionCountZero() {
        let pattern = DailyPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 0, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func weeklyExtractionCountZero() {
        let pattern = WeeklyPattern(stepSize: 1, weekDays: [.monday])
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 0, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func weekdaysExtractionCountZero() {
        let pattern = WeekdaysPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 0, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func weekendsExtractionCountZero() {
        let pattern = WeekendsPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 0, calendar: calendar)
        #expect(dates.isEmpty)
    }

    // MARK: - Large intervals

    @Test func dailyLargeInterval() {
        let pattern = DailyPattern(stepSize: 30)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 31),
            makeDate(year: 2024, month: 3, day: 1), // 2024 is a leap year
        ])
    }

    @Test func weeklyLargeStepSize() {
        let pattern = WeeklyPattern(stepSize: 4, weekDays: [.monday])
        let start = makeDate(year: 2024, month: 1, day: 1) // Mon
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 29),
            makeDate(year: 2024, month: 2, day: 26),
        ])
    }

    @Test func predictDailyLargeInterval() {
        let dates = [1, 31].map { makeDate(year: 2024, month: 1, day: $0) }
            + [makeDate(year: 2024, month: 3, day: 1)]
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(stepSize: 30))
    }

    @Test func predictWeeklyLargeStepSize() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 29), // Mon (4 weeks later)
            makeDate(year: 2024, month: 2, day: 26), // Mon (4 weeks later)
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 4, weekDays: [.monday]))
    }

    // MARK: - Unknown pattern extraction

    @Test func monthlyExtractionAcrossYearBoundary() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))
        let start = makeDate(year: 2024, month: 11, day: 1)
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 11, day: 15),
            makeDate(year: 2024, month: 12, day: 15),
            makeDate(year: 2025, month: 1, day: 15),
            makeDate(year: 2025, month: 2, day: 15),
        ])
    }

    @Test func monthlyExtractionAcrossYearBoundaryByRange() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .lastDay)
        let start = makeDate(year: 2024, month: 11, day: 1)
        let end = makeDate(year: 2025, month: 2, day: 28)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 11, day: 30),
            makeDate(year: 2024, month: 12, day: 31),
            makeDate(year: 2025, month: 1, day: 31),
            makeDate(year: 2025, month: 2, day: 28),
        ])
    }

    @Test func monthlyExtractionStartAfterEnd() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))
        let start = makeDate(year: 2024, month: 6, day: 1)
        let end = makeDate(year: 2024, month: 3, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func monthlyExtractionCountZero() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 0, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func monthlyLargeStepSize() {
        let pattern = MonthlyPattern(stepSize: 6, anchor: .daysOfMonth([1]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 7, day: 1),
            makeDate(year: 2025, month: 1, day: 1),
        ])
    }

    @Test func predictMonthlyAcrossYearBoundary() {
        let dates = [
            makeDate(year: 2024, month: 11, day: 15),
            makeDate(year: 2024, month: 12, day: 15),
            makeDate(year: 2025, month: 1, day: 15),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15])))
    }

    // MARK: - Unknown pattern extraction

    @Test func unknownPatternExtractionByRange() {
        let allDates = [1, 2, 5, 10, 20].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.unknown(allDates)
        let start = makeDate(year: 2024, month: 1, day: 3)
        let end = makeDate(year: 2024, month: 1, day: 15)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 5),
            makeDate(year: 2024, month: 1, day: 10),
        ])
    }

    @Test func unknownPatternExtractionByCount() {
        let allDates = [1, 2, 5, 10, 20].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.unknown(allDates)
        let dates = pattern.extractDates(start: allDates[0], first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 2),
            makeDate(year: 2024, month: 1, day: 5),
        ])
    }

    @Test func unknownPatternExtractionEmptyRange() {
        let allDates = [1, 2, 5].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.unknown(allDates)
        let start = makeDate(year: 2024, month: 2, day: 1)
        let end = makeDate(year: 2024, month: 2, day: 28)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates.isEmpty)
    }
}
