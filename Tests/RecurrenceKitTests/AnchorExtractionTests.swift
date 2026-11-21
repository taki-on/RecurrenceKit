import Testing
import Foundation
@testable import RecurrenceKit

@Suite("Anchor and cutoff extraction")
struct AnchorExtractionTests {

    let calendar = Calendar.test

    @Test func biweeklyMondaysKeepPhaseWhenCutoffMoves() {
        // Every other Monday starting 2026-05-04; "today" (Tue 2026-05-12) falls in the off week.
        let selected = [
            makeDate(year: 2026, month: 5, day: 4),
            makeDate(year: 2026, month: 5, day: 18),
            makeDate(year: 2026, month: 6, day: 1),
            makeDate(year: 2026, month: 6, day: 15),
            makeDate(year: 2026, month: 6, day: 29),
        ]
        let pattern = RecurrencePattern.predict(from: selected, calendar: calendar)
        #expect(pattern == .weekly(WeeklyPattern(stepSize: 2, weekDays: [.monday])))

        let dates = pattern.extractDates(
            anchor: selected[0],
            after: makeDate(year: 2026, month: 5, day: 12),
            first: 3,
            calendar: calendar
        )
        #expect(dates == [
            makeDate(year: 2026, month: 5, day: 18),
            makeDate(year: 2026, month: 6, day: 1),
            makeDate(year: 2026, month: 6, day: 15),
        ])
    }

    @Test func cutoffBeforeAnchorStartsAtAnchor() {
        let pattern = RecurrencePattern.daily(DailyPattern(stepSize: 2))
        let anchor = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(
            anchor: anchor,
            after: makeDate(year: 2023, month: 12, day: 1),
            first: 3,
            calendar: calendar
        )
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 3),
            makeDate(year: 2024, month: 1, day: 5),
        ])
    }

    @Test func dailyStepTwoSkipsOffPhaseCutoff() {
        let pattern = RecurrencePattern.daily(DailyPattern(stepSize: 2))
        let anchor = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(
            anchor: anchor,
            after: makeDate(year: 2024, month: 1, day: 4),
            first: 3,
            calendar: calendar
        )
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 5),
            makeDate(year: 2024, month: 1, day: 7),
            makeDate(year: 2024, month: 1, day: 9),
        ])
    }

    @Test func cutoffOnAnOccurrenceIsIncluded() {
        let pattern = RecurrencePattern.daily(DailyPattern(stepSize: 2))
        let anchor = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(
            anchor: anchor,
            after: makeDate(year: 2024, month: 1, day: 5),
            first: 2,
            calendar: calendar
        )
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 5),
            makeDate(year: 2024, month: 1, day: 7),
        ])
    }

    @Test func monthlyStepTwoKeepsPhase() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 2, anchor: .daysOfMonth([15]))
        )
        let dates = pattern.extractDates(
            anchor: makeDate(year: 2024, month: 1, day: 15),
            after: makeDate(year: 2024, month: 2, day: 20),
            first: 2,
            calendar: calendar
        )
        #expect(dates == [
            makeDate(year: 2024, month: 3, day: 15),
            makeDate(year: 2024, month: 5, day: 15),
        ])
    }

    @Test func yearlyStepTwoKeepsPhase() {
        let pattern = RecurrencePattern.yearly(
            YearlyPattern(stepSize: 2, month: 7, anchor: .dayOfMonth(4))
        )
        let dates = pattern.extractDates(
            anchor: makeDate(year: 2024, month: 7, day: 4),
            after: makeDate(year: 2025, month: 1, day: 1),
            first: 2,
            calendar: calendar
        )
        #expect(dates == [
            makeDate(year: 2026, month: 7, day: 4),
            makeDate(year: 2028, month: 7, day: 4),
        ])
    }

    @Test func rangeVariantFiltersToCutoffAndEnd() {
        let pattern = RecurrencePattern.weekly(WeeklyPattern(stepSize: 2, weekDays: [.monday]))
        let dates = pattern.extractDates(
            anchor: makeDate(year: 2026, month: 5, day: 4),
            after: makeDate(year: 2026, month: 5, day: 12),
            end: makeDate(year: 2026, month: 6, day: 15),
            calendar: calendar
        )
        #expect(dates == [
            makeDate(year: 2026, month: 5, day: 18),
            makeDate(year: 2026, month: 6, day: 1),
            makeDate(year: 2026, month: 6, day: 15),
        ])
    }

    @Test func unknownPatternFiltersStoredDates() {
        let stored = [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 9),
            makeDate(year: 2024, month: 2, day: 20),
        ]
        let dates = RecurrencePattern.unknown(stored).extractDates(
            anchor: stored[0],
            after: makeDate(year: 2024, month: 1, day: 5),
            first: 5,
            calendar: calendar
        )
        #expect(dates == [stored[1], stored[2]])
    }

    @Test func nonPositiveCountReturnsEmpty() {
        let pattern = RecurrencePattern.daily(DailyPattern(stepSize: 1))
        let day = makeDate(year: 2024, month: 1, day: 1)
        #expect(pattern.extractDates(anchor: day, after: day, first: 0, calendar: calendar).isEmpty)
    }
}
