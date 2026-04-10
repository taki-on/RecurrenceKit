import Testing
import Foundation
@testable import RecurrenceKit

@Suite("WeeklyPattern")
struct WeeklyPatternTests {

    let calendar = Calendar.test

    // MARK: - Prediction

    // 2024-01-01 = Monday
    // 2024-01-06 = Saturday, 2024-01-07 = Sunday

    @Test func predictWeeklySatSun() {
        // Two Saturdays and two Sundays, one week apart
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 14), // Sun
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.sunday, .saturday]))
    }

    @Test func predictWeeklyMonWedFri() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 3),  // Wed
            makeDate(year: 2024, month: 1, day: 5),  // Fri
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 10), // Wed
            makeDate(year: 2024, month: 1, day: 12), // Fri
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.monday, .wednesday, .friday]))
    }

    @Test func predictBiweeklyMonWedFri() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 3),  // Wed
            makeDate(year: 2024, month: 1, day: 5),  // Fri
            makeDate(year: 2024, month: 1, day: 15), // Mon (2 weeks later)
            makeDate(year: 2024, month: 1, day: 17), // Wed
            makeDate(year: 2024, month: 1, day: 19), // Fri
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 2, weekDays: [.monday, .wednesday, .friday]))
    }

    @Test func predictWeeklyMonday() {
        // Four consecutive Mondays
        let dates = [1, 8, 15, 22].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.monday]))
    }

    @Test func predictBiweeklyMonday() {
        let dates = [1, 15, 29].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 2, weekDays: [.monday]))
    }

    @Test func predictWeekdays() {
        // Mon–Fri for two weeks
        let dates = (1...5).map { makeDate(year: 2024, month: 1, day: $0) }
            + (8...12).map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern != nil)
        #expect(pattern?.weekDays.isWeekdays == true)
        #expect(pattern?.stepSize == 1)
    }

    @Test func predictWeekends() {
        // Sat–Sun for two weeks
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 14), // Sun
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern != nil)
        #expect(pattern?.weekDays.isWeekend == true)
    }

    @Test func predictReturnsNilForInconsistentWeeks() {
        // Mon, Wed, Fri in week 1, then Mon, Thu, Sat in week 2 — different weekday sets
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 3),  // Wed
            makeDate(year: 2024, month: 1, day: 5),  // Fri
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 11), // Thu
            makeDate(year: 2024, month: 1, day: 13), // Sat
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == nil)
    }

    @Test func predictReturnsNilForSingleDate() {
        let dates = [makeDate(year: 2024, month: 1, day: 1)]
        #expect(WeeklyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForEmptyArray() {
        #expect(WeeklyPattern.predict(from: [], calendar: calendar) == nil)
    }

    // MARK: - Extraction by range

    @Test func extractWeeklyMondaysInRange() {
        let pattern = WeeklyPattern(stepSize: 1, weekDays: [.monday])
        let start = makeDate(year: 2024, month: 1, day: 1)  // Mon
        let end = makeDate(year: 2024, month: 1, day: 21)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 8),
            makeDate(year: 2024, month: 1, day: 15),
        ])
    }

    @Test func extractWeeklyMultipleDaysInRange() {
        let pattern = WeeklyPattern(stepSize: 1, weekDays: [.monday, .wednesday])
        let start = makeDate(year: 2024, month: 1, day: 1) // Mon
        let end = makeDate(year: 2024, month: 1, day: 10)  // Wed
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 3),  // Wed
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 10), // Wed
        ])
    }

    // MARK: - Extraction by count

    @Test func extractFirstFourMondays() {
        let pattern = WeeklyPattern(stepSize: 1, weekDays: [.monday])
        let start = makeDate(year: 2024, month: 1, day: 1) // Mon
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 8),
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2024, month: 1, day: 22),
        ])
    }

    @Test func extractBiweeklyFirstThree() {
        let pattern = WeeklyPattern(stepSize: 2, weekDays: [.monday])
        let start = makeDate(year: 2024, month: 1, day: 1) // Mon
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2024, month: 1, day: 29),
        ])
    }

    @Test func extractStartingMidWeek() {
        // Start on a Wednesday; pattern is Mon+Fri. First match should be the Friday.
        let pattern = WeeklyPattern(stepSize: 1, weekDays: [.monday, .friday])
        let start = makeDate(year: 2024, month: 1, day: 3) // Wed
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 5),  // Fri
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 12), // Fri
        ])
    }
}
