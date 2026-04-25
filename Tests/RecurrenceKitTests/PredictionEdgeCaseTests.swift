import Testing
import Foundation
@testable import RecurrenceKit

@Suite("Prediction Edge Cases")
struct PredictionEdgeCaseTests {

    let calendar = Calendar.test

    // MARK: - Year boundary (Weekly)

    @Test func weeklyPatternAcrossYearBoundary() {
        // Mon Dec 30 2024 → Mon Jan 6 2025 (1-week step across year boundary)
        let dates = [
            makeDate(year: 2024, month: 12, day: 30), // Mon
            makeDate(year: 2025, month: 1, day: 6),   // Mon
            makeDate(year: 2025, month: 1, day: 13),  // Mon
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.monday]))
    }

    @Test func biweeklyPatternAcrossYearBoundary() {
        // Every other Monday across Dec/Jan boundary
        let dates = [
            makeDate(year: 2024, month: 12, day: 23), // Mon
            makeDate(year: 2025, month: 1, day: 6),   // Mon (2 weeks later)
            makeDate(year: 2025, month: 1, day: 20),  // Mon (2 weeks later)
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 2, weekDays: [.monday]))
    }

    @Test func weeklyMultipleDaysAcrossYearBoundary() {
        // Mon+Wed across year boundary
        let dates = [
            makeDate(year: 2024, month: 12, day: 30), // Mon
            makeDate(year: 2025, month: 1, day: 1),   // Wed
            makeDate(year: 2025, month: 1, day: 6),   // Mon
            makeDate(year: 2025, month: 1, day: 8),   // Wed
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.monday, .wednesday]))
    }

    // MARK: - Time-of-day normalization

    @Test func dailyWithDifferentTimes() {
        // Same day-interval but different times of day
        let dates = [
            makeDate(year: 2024, month: 1, day: 1, hour: 9, minute: 0),
            makeDate(year: 2024, month: 1, day: 2, hour: 14, minute: 30),
            makeDate(year: 2024, month: 1, day: 3, hour: 22, minute: 15),
            makeDate(year: 2024, month: 1, day: 4, hour: 7, minute: 0),
        ]
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(stepSize: 1))
    }

    @Test func dailyEveryOtherDayWithDifferentTimes() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 1, hour: 8, minute: 0),
            makeDate(year: 2024, month: 1, day: 3, hour: 17, minute: 0),
            makeDate(year: 2024, month: 1, day: 5, hour: 12, minute: 0),
        ]
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(stepSize: 2))
    }

    @Test func weeklyWithDifferentTimes() {
        // Every Monday at different times
        let dates = [
            makeDate(year: 2024, month: 1, day: 1, hour: 9, minute: 0),   // Mon
            makeDate(year: 2024, month: 1, day: 8, hour: 14, minute: 30), // Mon
            makeDate(year: 2024, month: 1, day: 15, hour: 7, minute: 0),  // Mon
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.monday]))
    }

    // MARK: - Duplicate dates

    @Test func dailyWithDuplicates() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 1), // duplicate
            makeDate(year: 2024, month: 1, day: 2),
            makeDate(year: 2024, month: 1, day: 3),
        ]
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(stepSize: 1))
    }

    @Test func dailyWithSameDayDifferentTimes() {
        // Two entries on the same day at different times — should be treated as one date
        let dates = [
            makeDate(year: 2024, month: 1, day: 1, hour: 9, minute: 0),
            makeDate(year: 2024, month: 1, day: 1, hour: 17, minute: 0),
            makeDate(year: 2024, month: 1, day: 2, hour: 10, minute: 0),
            makeDate(year: 2024, month: 1, day: 3, hour: 11, minute: 0),
        ]
        let pattern = DailyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == DailyPattern(stepSize: 1))
    }

    @Test func weeklyWithDuplicates() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 1),  // Mon (duplicate)
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 15), // Mon
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.monday]))
    }

    // MARK: - Incomplete trailing week

    @Test func weeklyMonWedFriWithIncompleteTrailingWeek() {
        // Two full weeks of Mon/Wed/Fri, then only Mon in the third week
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 3),  // Wed
            makeDate(year: 2024, month: 1, day: 5),  // Fri
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 10), // Wed
            makeDate(year: 2024, month: 1, day: 12), // Fri
            makeDate(year: 2024, month: 1, day: 15), // Mon (trailing)
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.monday, .wednesday, .friday]))
    }

    @Test func weeklyMonWedFriWithTrailingMonWed() {
        // Two full weeks, then Mon+Wed in the third
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 3),  // Wed
            makeDate(year: 2024, month: 1, day: 5),  // Fri
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 10), // Wed
            makeDate(year: 2024, month: 1, day: 12), // Fri
            makeDate(year: 2024, month: 1, day: 15), // Mon (trailing)
            makeDate(year: 2024, month: 1, day: 17), // Wed (trailing)
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeeklyPattern(stepSize: 1, weekDays: [.monday, .wednesday, .friday]))
    }

    @Test func weekdaysWithIncompleteTrailingWeek() {
        // Two full weekday weeks + Mon/Tue/Wed of third week
        let dates = (1...5).map { makeDate(year: 2024, month: 1, day: $0) }    // Mon–Fri
            + (8...12).map { makeDate(year: 2024, month: 1, day: $0) }          // Mon–Fri
            + (15...17).map { makeDate(year: 2024, month: 1, day: $0) }          // Mon–Wed
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .weekdays(WeekdaysPattern(stepSize: 1)))
    }

    @Test func weekendsWithIncompleteTrailingWeek() {
        // Two full weekends + only Saturday of third week
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 14), // Sun
            makeDate(year: 2024, month: 1, day: 20), // Sat (trailing)
        ]
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .weekends(WeekendsPattern(stepSize: 1)))
    }

    @Test func incompleteTrailingRejectsInconsistentPattern() {
        // Mon has 3 dates, Wed has 1 — the gap is 2, not 1, so should reject
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),  // Mon
            makeDate(year: 2024, month: 1, day: 3),  // Wed
            makeDate(year: 2024, month: 1, day: 8),  // Mon
            makeDate(year: 2024, month: 1, day: 15), // Mon
        ]
        let pattern = WeeklyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == nil)
    }
}
