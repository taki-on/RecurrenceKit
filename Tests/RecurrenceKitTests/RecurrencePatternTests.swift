import Testing
import Foundation
@testable import RecurrenceKit

@Suite("RecurrencePattern")
struct RecurrencePatternTests {

    let calendar = Calendar.test

    // MARK: - Prediction dispatch

    @Test func predictDetectsWeeklyOverDaily() {
        // Every Monday for 4 weeks — could be daily(interval:7) but weekly is more specific
        let dates = [1, 8, 15, 22].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        if case .weekly(let weekly) = pattern {
            #expect(weekly.stepSize == 1)
            #expect(weekly.weekDays == [.monday])
        } else {
            Issue.record("Expected .weekly, got \(pattern)")
        }
    }

    @Test func predictDetectsDaily() {
        let dates = (1...4).map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .daily(DailyPattern(stepSize: 1)))
    }

    @Test func predictDetectsWeekdays() {
        // Mon–Fri for two weeks
        let dates = (1...5).map { makeDate(year: 2024, month: 1, day: $0) }
            + (8...12).map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .weekdays(WeekdaysPattern(stepSize: 1)))
    }

    @Test func predictDetectsBiweeklyWeekdays() {
        // Mon–Fri, then skip a week, then Mon–Fri
        let dates = (1...5).map { makeDate(year: 2024, month: 1, day: $0) }
            + (15...19).map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .weekdays(WeekdaysPattern(stepSize: 2)))
    }

    @Test func predictDetectsWeekends() {
        // Sat–Sun for two weeks
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 14), // Sun
        ]
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .weekends(WeekendsPattern(stepSize: 1)))
    }

    @Test func predictDetectsBiweeklyWeekends() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 20), // Sat (2 weeks later)
            makeDate(year: 2024, month: 1, day: 21), // Sun
        ]
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .weekends(WeekendsPattern(stepSize: 2)))
    }

    @Test func predictFallsBackToUnknown() {
        let dates = [1, 2, 5, 10].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .unknown(dates))
    }

    @Test func predictDetectsMonthlyDayOfMonth() {
        let dates = [1, 2, 3].map { makeDate(year: 2024, month: $0, day: 15) }
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .monthly(MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))))
    }

    @Test func predictDetectsMonthlyLastDay() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 31),
            makeDate(year: 2024, month: 2, day: 29),
            makeDate(year: 2024, month: 3, day: 31),
        ]
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .monthly(MonthlyPattern(stepSize: 1, anchor: .lastDay)))
    }

    @Test func predictDetectsMonthlyWeekdayOrdinal() {
        // 2nd Tuesday of Jan (9), Feb (13), Mar (12) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 9),
            makeDate(year: 2024, month: 2, day: 13),
            makeDate(year: 2024, month: 3, day: 12),
        ]
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .monthly(MonthlyPattern(
            stepSize: 1,
            anchor: .weekdayOrdinal(ordinal: 2, weekDay: .tuesday)
        )))
    }

    @Test func predictDetectsMonthlyLastWeekday() {
        // Last Friday of Jan (26), Feb (23), Mar (29) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 26),
            makeDate(year: 2024, month: 2, day: 23),
            makeDate(year: 2024, month: 3, day: 29),
        ]
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .monthly(MonthlyPattern(stepSize: 1, anchor: .lastWeekday(.friday))))
    }

    @Test func predictEmptyInputReturnsUnknown() {
        let pattern = RecurrencePattern.predict(from: [], calendar: calendar)
        #expect(pattern == .unknown([]))
    }

    // MARK: - DateRecurrence

    @Test func dateRecurrenceMakeFromDailyDates() {
        let dates = (1...4).map { makeDate(year: 2024, month: 1, day: $0) }
        let recurrence = DateRecurrence.make(from: dates, calendar: calendar)
        #expect(recurrence != nil)
        #expect(recurrence?.startDate == makeDate(year: 2024, month: 1, day: 1))
        if case .daily(let daily) = recurrence?.pattern {
            #expect(daily.stepSize == 1)
        } else {
            Issue.record("Expected daily pattern")
        }
    }

    @Test func dateRecurrenceMakeFromEmptyReturnsNil() {
        #expect(DateRecurrence.make(from: [], calendar: calendar) == nil)
    }

    @Test func dateRecurrenceExtractDates() {
        let recurrence = DateRecurrence(
            startDate: makeDate(year: 2024, month: 1, day: 1),
            endDate: makeDate(year: 2024, month: 1, day: 10),
            pattern: .daily(DailyPattern(stepSize: 2))
        )
        let dates = recurrence.extractDates(first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 3),
            makeDate(year: 2024, month: 1, day: 5),
        ])
    }
}
