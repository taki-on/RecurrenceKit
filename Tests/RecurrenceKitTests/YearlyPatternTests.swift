import Testing
import Foundation
@testable import RecurrenceKit

@Suite("YearlyPattern")
struct YearlyPatternTests {

    let calendar = Calendar.test

    // MARK: - Prediction: dayOfMonth

    @Test func predictFixedDate() {
        // March 15 of 2023, 2024, 2025
        let dates = [2023, 2024, 2025].map { makeDate(year: $0, month: 3, day: 15) }
        let pattern = YearlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == YearlyPattern(stepSize: 1, month: 3, anchor: .dayOfMonth(15)))
    }

    @Test func predictFixedDateBiennial() {
        // Jan 1 of 2020, 2022, 2024
        let dates = [2020, 2022, 2024].map { makeDate(year: $0, month: 1, day: 1) }
        let pattern = YearlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == YearlyPattern(stepSize: 2, month: 1, anchor: .dayOfMonth(1)))
    }

    // MARK: - Prediction: weekdayOrdinal

    @Test func predictThirdMondayOfJanuary() {
        // MLK Day: 3rd Monday of January
        // 2023: Jan 16, 2024: Jan 15, 2025: Jan 20
        let dates = [
            makeDate(year: 2023, month: 1, day: 16),
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2025, month: 1, day: 20),
        ]
        let pattern = YearlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == YearlyPattern(
            stepSize: 1, month: 1,
            anchor: .weekdayOrdinal(ordinal: 3, weekDay: .monday)
        ))
    }

    @Test func predictFourthThursdayOfNovember() {
        // Thanksgiving: 4th Thursday of November
        // 2023: Nov 23, 2024: Nov 28, 2025: Nov 27
        let dates = [
            makeDate(year: 2023, month: 11, day: 23),
            makeDate(year: 2024, month: 11, day: 28),
            makeDate(year: 2025, month: 11, day: 27),
        ]
        let pattern = YearlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == YearlyPattern(
            stepSize: 1, month: 11,
            anchor: .weekdayOrdinal(ordinal: 4, weekDay: .thursday)
        ))
    }

    // MARK: - Prediction: lastDay

    @Test func predictLastDayOfFebruary() {
        // Last day of Feb: 28 (2023), 29 (2024), 28 (2025)
        let dates = [
            makeDate(year: 2023, month: 2, day: 28),
            makeDate(year: 2024, month: 2, day: 29),
            makeDate(year: 2025, month: 2, day: 28),
        ]
        let pattern = YearlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == YearlyPattern(stepSize: 1, month: 2, anchor: .lastDay))
    }

    // MARK: - Prediction: lastWeekday

    @Test func predictLastMondayOfMay() {
        // Memorial Day: last Monday of May
        // 2023: May 29, 2024: May 27, 2025: May 26
        let dates = [
            makeDate(year: 2023, month: 5, day: 29),
            makeDate(year: 2024, month: 5, day: 27),
            makeDate(year: 2025, month: 5, day: 26),
        ]
        let pattern = YearlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == YearlyPattern(stepSize: 1, month: 5, anchor: .lastWeekday(.monday)))
    }

    // MARK: - Prediction: nil cases

    @Test func predictReturnsNilForSingleDate() {
        let dates = [makeDate(year: 2024, month: 3, day: 15)]
        #expect(YearlyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForEmptyArray() {
        #expect(YearlyPattern.predict(from: [], calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForDifferentMonths() {
        let dates = [
            makeDate(year: 2023, month: 3, day: 15),
            makeDate(year: 2024, month: 4, day: 15),
        ]
        #expect(YearlyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForInconsistentYearGaps() {
        // 2023, 2024, 2026 — gaps of 1 and 2
        let dates = [2023, 2024, 2026].map { makeDate(year: $0, month: 6, day: 1) }
        #expect(YearlyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForInconsistentDays() {
        let dates = [
            makeDate(year: 2023, month: 3, day: 15),
            makeDate(year: 2024, month: 3, day: 16),
        ]
        #expect(YearlyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictHandlesUnsortedInput() {
        let dates = [
            makeDate(year: 2025, month: 7, day: 4),
            makeDate(year: 2023, month: 7, day: 4),
            makeDate(year: 2024, month: 7, day: 4),
        ]
        let pattern = YearlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == YearlyPattern(stepSize: 1, month: 7, anchor: .dayOfMonth(4)))
    }

    // MARK: - Extraction by range

    @Test func extractFixedDateInRange() {
        let pattern = YearlyPattern(stepSize: 1, month: 3, anchor: .dayOfMonth(15))
        let start = makeDate(year: 2023, month: 1, day: 1)
        let end = makeDate(year: 2025, month: 12, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2023, month: 3, day: 15),
            makeDate(year: 2024, month: 3, day: 15),
            makeDate(year: 2025, month: 3, day: 15),
        ])
    }

    @Test func extractLastDayOfFebInRange() {
        let pattern = YearlyPattern(stepSize: 1, month: 2, anchor: .lastDay)
        let start = makeDate(year: 2023, month: 1, day: 1)
        let end = makeDate(year: 2025, month: 12, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2023, month: 2, day: 28),
            makeDate(year: 2024, month: 2, day: 29),
            makeDate(year: 2025, month: 2, day: 28),
        ])
    }

    @Test func extractWeekdayOrdinalInRange() {
        // 3rd Monday of January
        let pattern = YearlyPattern(
            stepSize: 1, month: 1,
            anchor: .weekdayOrdinal(ordinal: 3, weekDay: .monday)
        )
        let start = makeDate(year: 2023, month: 1, day: 1)
        let end = makeDate(year: 2025, month: 12, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2023, month: 1, day: 16),
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2025, month: 1, day: 20),
        ])
    }

    @Test func extractLastWeekdayInRange() {
        // Last Monday of May
        let pattern = YearlyPattern(stepSize: 1, month: 5, anchor: .lastWeekday(.monday))
        let start = makeDate(year: 2023, month: 1, day: 1)
        let end = makeDate(year: 2025, month: 12, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2023, month: 5, day: 29),
            makeDate(year: 2024, month: 5, day: 27),
            makeDate(year: 2025, month: 5, day: 26),
        ])
    }

    // MARK: - Extraction by count

    @Test func extractFirstThreeByCount() {
        let pattern = YearlyPattern(stepSize: 1, month: 7, anchor: .dayOfMonth(4))
        let start = makeDate(year: 2023, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2023, month: 7, day: 4),
            makeDate(year: 2024, month: 7, day: 4),
            makeDate(year: 2025, month: 7, day: 4),
        ])
    }

    @Test func extractBiennialByCount() {
        let pattern = YearlyPattern(stepSize: 2, month: 1, anchor: .dayOfMonth(1))
        let start = makeDate(year: 2020, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2020, month: 1, day: 1),
            makeDate(year: 2022, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 1),
        ])
    }

    @Test func extractStartAfterOccurrence() {
        // Start in August — July 4th of this year is past, first match is next year
        let pattern = YearlyPattern(stepSize: 1, month: 7, anchor: .dayOfMonth(4))
        let start = makeDate(year: 2024, month: 8, day: 1)
        let dates = pattern.extractDates(start: start, first: 2, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2025, month: 7, day: 4),
            makeDate(year: 2026, month: 7, day: 4),
        ])
    }

    // MARK: - Extraction edge cases

    @Test func extractStartAfterEnd() {
        let pattern = YearlyPattern(stepSize: 1, month: 3, anchor: .dayOfMonth(15))
        let start = makeDate(year: 2025, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 12, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func extractCountZero() {
        let pattern = YearlyPattern(stepSize: 1, month: 3, anchor: .dayOfMonth(15))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 0, calendar: calendar)
        #expect(dates.isEmpty)
    }

    // MARK: - Description

    @Test func descriptionFixedDate() {
        let pattern = RecurrencePattern.yearly(
            YearlyPattern(stepSize: 1, month: 7, anchor: .dayOfMonth(4))
        )
        #expect(pattern.description == "Every year on July 4th")
    }

    @Test func descriptionBiennial() {
        let pattern = RecurrencePattern.yearly(
            YearlyPattern(stepSize: 2, month: 1, anchor: .dayOfMonth(1))
        )
        #expect(pattern.description == "Every other year on January 1st")
    }

    @Test func descriptionWeekdayOrdinal() {
        let pattern = RecurrencePattern.yearly(
            YearlyPattern(stepSize: 1, month: 1,
                          anchor: .weekdayOrdinal(ordinal: 3, weekDay: .monday))
        )
        #expect(pattern.description == "Every year on the 3rd Monday of January")
    }

    @Test func descriptionLastDay() {
        let pattern = RecurrencePattern.yearly(
            YearlyPattern(stepSize: 1, month: 2, anchor: .lastDay)
        )
        #expect(pattern.description == "Every year on the last day of February")
    }

    @Test func descriptionLastWeekday() {
        let pattern = RecurrencePattern.yearly(
            YearlyPattern(stepSize: 1, month: 5, anchor: .lastWeekday(.monday))
        )
        #expect(pattern.description == "Every year on the last Monday of May")
    }

    // MARK: - Codable

    @Test func yearlyDayOfMonthCodable() throws {
        let pattern = YearlyPattern(stepSize: 1, month: 7, anchor: .dayOfMonth(4))
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(YearlyPattern.self, from: data)
        #expect(decoded == pattern)
    }

    @Test func yearlyWeekdayOrdinalCodable() throws {
        let pattern = YearlyPattern(
            stepSize: 1, month: 11,
            anchor: .weekdayOrdinal(ordinal: 4, weekDay: .thursday)
        )
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(YearlyPattern.self, from: data)
        #expect(decoded == pattern)
    }

    @Test func yearlyLastDayCodable() throws {
        let pattern = YearlyPattern(stepSize: 1, month: 2, anchor: .lastDay)
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(YearlyPattern.self, from: data)
        #expect(decoded == pattern)
    }

    @Test func yearlyLastWeekdayCodable() throws {
        let pattern = YearlyPattern(stepSize: 1, month: 5, anchor: .lastWeekday(.monday))
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(YearlyPattern.self, from: data)
        #expect(decoded == pattern)
    }

    @Test func recurrencePatternYearlyCodable() throws {
        let pattern = RecurrencePattern.yearly(
            YearlyPattern(stepSize: 1, month: 7, anchor: .dayOfMonth(4))
        )
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(RecurrencePattern.self, from: data)
        #expect(decoded == pattern)
    }
}
