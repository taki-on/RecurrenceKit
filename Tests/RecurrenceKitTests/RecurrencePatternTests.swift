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
        #expect(pattern == .daily(DailyPattern(interval: 1)))
    }

    @Test func predictFallsBackToUnknown() {
        let dates = [1, 2, 5, 10].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.predict(from: dates, calendar: calendar)
        #expect(pattern == .unknown(dates))
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
            #expect(daily.interval == 1)
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
            pattern: .daily(DailyPattern(interval: 2))
        )
        let dates = recurrence.extractDates(first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 3),
            makeDate(year: 2024, month: 1, day: 5),
        ])
    }
}
