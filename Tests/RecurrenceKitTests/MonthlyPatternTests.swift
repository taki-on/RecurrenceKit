import Testing
import Foundation
@testable import RecurrenceKit

@Suite("MonthlyPattern")
struct MonthlyPatternTests {

    let calendar = Calendar.test

    // MARK: - Prediction: dayOfMonth

    @Test func predictDayOfMonth() {
        // 15th of Jan, Feb, Mar 2024
        let dates = [1, 2, 3].map { makeDate(year: 2024, month: $0, day: 15) }
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15])))
    }

    @Test func predictDayOfMonthBimonthly() {
        // 1st of Jan, Mar, May 2024
        let dates = [1, 3, 5].map { makeDate(year: 2024, month: $0, day: 1) }
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 2, anchor: .daysOfMonth([1])))
    }

    @Test func predictDayOfMonthQuarterly() {
        // 10th of Jan, Apr, Jul 2024
        let dates = [1, 4, 7].map { makeDate(year: 2024, month: $0, day: 10) }
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 3, anchor: .daysOfMonth([10])))
    }

    @Test func predictDayOfMonthAcrossYearBoundary() {
        // 5th of Nov 2024, Dec 2024, Jan 2025
        let dates = [
            makeDate(year: 2024, month: 11, day: 5),
            makeDate(year: 2024, month: 12, day: 5),
            makeDate(year: 2025, month: 1, day: 5),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([5])))
    }

    // MARK: - Prediction: lastDay

    @Test func predictLastDay() {
        // Last day of Jan (31), Feb (29, leap year), Mar (31) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 31),
            makeDate(year: 2024, month: 2, day: 29),
            makeDate(year: 2024, month: 3, day: 31),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .lastDay))
    }

    @Test func predictLastDayBimonthly() {
        // Last day of Jan (31), Mar (31), May (31) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 31),
            makeDate(year: 2024, month: 3, day: 31),
            makeDate(year: 2024, month: 5, day: 31),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 2, anchor: .lastDay))
    }

    // MARK: - Prediction: weekdayOrdinal

    @Test func predictSecondTuesday() {
        // 2nd Tuesday of Jan (9), Feb (13), Mar (12) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 9),   // 2nd Tue
            makeDate(year: 2024, month: 2, day: 13),   // 2nd Tue
            makeDate(year: 2024, month: 3, day: 12),   // 2nd Tue
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .weekdayOrdinals(ordinals: [2], weekDay: .tuesday)))
    }

    @Test func predictFirstMonday() {
        // 1st Monday of Jan (1), Feb (5), Mar (4) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),   // 1st Mon
            makeDate(year: 2024, month: 2, day: 5),    // 1st Mon
            makeDate(year: 2024, month: 3, day: 4),    // 1st Mon
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .weekdayOrdinals(ordinals: [1], weekDay: .monday)))
    }

    @Test func predictThirdFridayBimonthly() {
        // 3rd Friday of Jan (19), Mar (15), May (17) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 19),  // 3rd Fri
            makeDate(year: 2024, month: 3, day: 15),   // 3rd Fri
            makeDate(year: 2024, month: 5, day: 17),   // 3rd Fri
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 2, anchor: .weekdayOrdinals(ordinals: [3], weekDay: .friday)))
    }

    // MARK: - Prediction: lastWeekday

    @Test func predictLastFriday() {
        // Last Friday of Jan (26), Feb (23), Mar (29) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 26),  // last Fri
            makeDate(year: 2024, month: 2, day: 23),   // last Fri
            makeDate(year: 2024, month: 3, day: 29),   // last Fri
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .lastWeekday(.friday)))
    }

    @Test func predictLastSunday() {
        // Last Sunday of Jan (28), Feb (25), Mar (31) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 28),
            makeDate(year: 2024, month: 2, day: 25),
            makeDate(year: 2024, month: 3, day: 31),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .lastWeekday(.sunday)))
    }

    // MARK: - Prediction: nil cases

    @Test func predictReturnsNilForSingleDate() {
        let dates = [makeDate(year: 2024, month: 1, day: 15)]
        #expect(MonthlyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForEmptyArray() {
        #expect(MonthlyPattern.predict(from: [], calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForInconsistentMonthGaps() {
        // Jan 15, Feb 15, Apr 15 — gaps of 1 and 2 months
        let dates = [1, 2, 4].map { makeDate(year: 2024, month: $0, day: 15) }
        #expect(MonthlyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForInconsistentDays() {
        // Jan 15, Feb 16, Mar 15 — different days
        let dates = [
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2024, month: 2, day: 16),
            makeDate(year: 2024, month: 3, day: 15),
        ]
        #expect(MonthlyPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictHandlesUnsortedInput() {
        let dates = [
            makeDate(year: 2024, month: 3, day: 15),
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2024, month: 2, day: 15),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15])))
    }

    // MARK: - Extraction by range: dayOfMonth

    @Test func extractDayOfMonthInRange() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 3, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2024, month: 2, day: 15),
            makeDate(year: 2024, month: 3, day: 15),
        ])
    }

    @Test func extractDayOfMonthClampedForShortMonth() {
        // Day 31 clamped to 29 in Feb (leap year 2024)
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([31]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 3, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 31),
            makeDate(year: 2024, month: 2, day: 29),
            makeDate(year: 2024, month: 3, day: 31),
        ])
    }

    // MARK: - Extraction by range: lastDay

    @Test func extractLastDayInRange() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .lastDay)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 4, day: 30)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 31),
            makeDate(year: 2024, month: 2, day: 29),
            makeDate(year: 2024, month: 3, day: 31),
            makeDate(year: 2024, month: 4, day: 30),
        ])
    }

    // MARK: - Extraction by range: weekdayOrdinal

    @Test func extractSecondTuesdayInRange() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .weekdayOrdinals(ordinals: [2], weekDay: .tuesday))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 3, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 9),
            makeDate(year: 2024, month: 2, day: 13),
            makeDate(year: 2024, month: 3, day: 12),
        ])
    }

    // MARK: - Extraction by range: lastWeekday

    @Test func extractLastFridayInRange() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .lastWeekday(.friday))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 3, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 26),
            makeDate(year: 2024, month: 2, day: 23),
            makeDate(year: 2024, month: 3, day: 29),
        ])
    }

    // MARK: - Extraction by count

    @Test func extractFirstThreeDayOfMonth() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([10]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 10),
            makeDate(year: 2024, month: 2, day: 10),
            makeDate(year: 2024, month: 3, day: 10),
        ])
    }

    @Test func extractFirstThreeLastDay() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .lastDay)
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 31),
            makeDate(year: 2024, month: 2, day: 29),
            makeDate(year: 2024, month: 3, day: 31),
        ])
    }

    @Test func extractBimonthlyByCount() {
        let pattern = MonthlyPattern(stepSize: 2, anchor: .daysOfMonth([1]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 3, day: 1),
            makeDate(year: 2024, month: 5, day: 1),
            makeDate(year: 2024, month: 7, day: 1),
        ])
    }

    @Test func extractAcrossYearBoundaryByCount() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([20]))
        let start = makeDate(year: 2024, month: 11, day: 1)
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 11, day: 20),
            makeDate(year: 2024, month: 12, day: 20),
            makeDate(year: 2025, month: 1, day: 20),
            makeDate(year: 2025, month: 2, day: 20),
        ])
    }

    // MARK: - Extraction edge cases

    @Test func extractStartAfterEnd() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))
        let start = makeDate(year: 2024, month: 3, day: 1)
        let end = makeDate(year: 2024, month: 1, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func extractCountZero() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 0, calendar: calendar)
        #expect(dates.isEmpty)
    }

    @Test func extractStartMidMonth() {
        // Start on the 20th — the 15th of Jan is before start, so first match is Feb 15
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))
        let start = makeDate(year: 2024, month: 1, day: 20)
        let dates = pattern.extractDates(start: start, first: 2, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 2, day: 15),
            makeDate(year: 2024, month: 3, day: 15),
        ])
    }

    // MARK: - Description

    @Test func descriptionDayOfMonth() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15]))
        )
        #expect(pattern.description == "Every month on the 15th")
    }

    @Test func descriptionDayOfMonthBimonthly() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 2, anchor: .daysOfMonth([1]))
        )
        #expect(pattern.description == "Every other month on the 1st")
    }

    @Test func descriptionDayOfMonthQuarterly() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 3, anchor: .daysOfMonth([22]))
        )
        #expect(pattern.description == "Every 3 months on the 22nd")
    }

    @Test func descriptionWeekdayOrdinal() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .weekdayOrdinals(ordinals: [2], weekDay: .tuesday))
        )
        #expect(pattern.description == "Every month on the 2nd Tuesday")
    }

    @Test func descriptionLastDay() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .lastDay)
        )
        #expect(pattern.description == "Every month on the last day")
    }

    @Test func descriptionLastWeekday() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .lastWeekday(.friday))
        )
        #expect(pattern.description == "Every month on the last Friday")
    }

    @Test func descriptionOrdinalSuffixes() {
        // 1st, 2nd, 3rd, 4th, 11th, 12th, 13th, 21st, 23rd
        let cases: [(Int, String)] = [
            (1, "1st"), (2, "2nd"), (3, "3rd"), (4, "4th"),
            (11, "11th"), (12, "12th"), (13, "13th"),
            (21, "21st"), (23, "23rd"),
        ]
        for (day, expected) in cases {
            let pattern = RecurrencePattern.monthly(
                MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([day]))
            )
            #expect(
                pattern.description == "Every month on the \(expected)",
                "Day \(day) should have suffix \(expected)"
            )
        }
    }

    // MARK: - Multi-day prediction

    @Test func predictMultipleDaysOfMonth() {
        // 1st and 8th of Jan, Feb, Mar 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 8),
            makeDate(year: 2024, month: 2, day: 1),
            makeDate(year: 2024, month: 2, day: 8),
            makeDate(year: 2024, month: 3, day: 1),
            makeDate(year: 2024, month: 3, day: 8),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([1, 8])))
    }

    @Test func predictMultipleDaysBimonthly() {
        // 5th and 20th of Jan, Mar, May 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 5),
            makeDate(year: 2024, month: 1, day: 20),
            makeDate(year: 2024, month: 3, day: 5),
            makeDate(year: 2024, month: 3, day: 20),
            makeDate(year: 2024, month: 5, day: 5),
            makeDate(year: 2024, month: 5, day: 20),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 2, anchor: .daysOfMonth([5, 20])))
    }

    @Test func predictMultipleDaysWithIncompleteTrailingMonth() {
        // 1st and 15th of Jan, Feb; only 1st of Mar (trailing)
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2024, month: 2, day: 1),
            makeDate(year: 2024, month: 2, day: 15),
            makeDate(year: 2024, month: 3, day: 1),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([1, 15])))
    }

    @Test func predictThreeDaysOfMonth() {
        // 1st, 10th, 20th of Jan, Feb 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 10),
            makeDate(year: 2024, month: 1, day: 20),
            makeDate(year: 2024, month: 2, day: 1),
            makeDate(year: 2024, month: 2, day: 10),
            makeDate(year: 2024, month: 2, day: 20),
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([1, 10, 20])))
    }

    // MARK: - Multi-day extraction

    @Test func extractMultipleDaysByCount() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([1, 8]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 6, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 8),
            makeDate(year: 2024, month: 2, day: 1),
            makeDate(year: 2024, month: 2, day: 8),
            makeDate(year: 2024, month: 3, day: 1),
            makeDate(year: 2024, month: 3, day: 8),
        ])
    }

    @Test func extractMultipleDaysByRange() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([1, 15]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 2, day: 28)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2024, month: 2, day: 1),
            makeDate(year: 2024, month: 2, day: 15),
        ])
    }

    @Test func extractMultipleDaysStartMidMonth() {
        // Start on the 10th — the 1st is before start, first match is 15th
        let pattern = MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([1, 15]))
        let start = makeDate(year: 2024, month: 1, day: 10)
        let dates = pattern.extractDates(start: start, first: 3, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 15),
            makeDate(year: 2024, month: 2, day: 1),
            makeDate(year: 2024, month: 2, day: 15),
        ])
    }

    // MARK: - Multi-day description

    @Test func descriptionMultipleDays() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([1, 8]))
        )
        #expect(pattern.description == "Every month on the 1st and 8th")
    }

    @Test func descriptionMultipleDaysThree() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([1, 10, 20]))
        )
        #expect(pattern.description == "Every month on the 1st, 10th, and 20th")
    }

    // MARK: - Multi-ordinal weekday prediction

    @Test func predictFirstAndThirdFriday() {
        // 1st Friday: Jan 5, Feb 2, Mar 1; 3rd Friday: Jan 19, Feb 16, Mar 15
        let dates = [
            makeDate(year: 2024, month: 1, day: 5),   // 1st Fri
            makeDate(year: 2024, month: 1, day: 19),  // 3rd Fri
            makeDate(year: 2024, month: 2, day: 2),   // 1st Fri
            makeDate(year: 2024, month: 2, day: 16),  // 3rd Fri
            makeDate(year: 2024, month: 3, day: 1),   // 1st Fri
            makeDate(year: 2024, month: 3, day: 15),  // 3rd Fri
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(
            stepSize: 1, anchor: .weekdayOrdinals(ordinals: [1, 3], weekDay: .friday)
        ))
    }

    @Test func predictFirstAndSecondMonday() {
        // 1st Mon: Jan 1, Feb 5; 2nd Mon: Jan 8, Feb 12
        let dates = [
            makeDate(year: 2024, month: 1, day: 1),   // 1st Mon
            makeDate(year: 2024, month: 1, day: 8),   // 2nd Mon
            makeDate(year: 2024, month: 2, day: 5),   // 1st Mon
            makeDate(year: 2024, month: 2, day: 12),  // 2nd Mon
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(
            stepSize: 1, anchor: .weekdayOrdinals(ordinals: [1, 2], weekDay: .monday)
        ))
    }

    @Test func predictMultiOrdinalWeekdayWithTrailing() {
        // 1st and 3rd Fri of Jan, Feb; only 1st Fri of Mar (trailing)
        let dates = [
            makeDate(year: 2024, month: 1, day: 5),   // 1st Fri
            makeDate(year: 2024, month: 1, day: 19),  // 3rd Fri
            makeDate(year: 2024, month: 2, day: 2),   // 1st Fri
            makeDate(year: 2024, month: 2, day: 16),  // 3rd Fri
            makeDate(year: 2024, month: 3, day: 1),   // 1st Fri (trailing)
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(
            stepSize: 1, anchor: .weekdayOrdinals(ordinals: [1, 3], weekDay: .friday)
        ))
    }

    // MARK: - Multi-ordinal weekday extraction

    @Test func extractFirstAndThirdFridayByCount() {
        let pattern = MonthlyPattern(
            stepSize: 1, anchor: .weekdayOrdinals(ordinals: [1, 3], weekDay: .friday)
        )
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 6, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 5),   // 1st Fri
            makeDate(year: 2024, month: 1, day: 19),  // 3rd Fri
            makeDate(year: 2024, month: 2, day: 2),   // 1st Fri
            makeDate(year: 2024, month: 2, day: 16),  // 3rd Fri
            makeDate(year: 2024, month: 3, day: 1),   // 1st Fri
            makeDate(year: 2024, month: 3, day: 15),  // 3rd Fri
        ])
    }

    // MARK: - Multi-ordinal weekday description

    @Test func descriptionFirstAndThirdFriday() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .weekdayOrdinals(ordinals: [1, 3], weekDay: .friday))
        )
        #expect(pattern.description == "Every month on the 1st and 3rd Friday")
    }

    // MARK: - Weekend ordinal prediction

    @Test func predictFirstWeekend() {
        // 1st weekend of Jan (6-7), Feb (3-4), Mar (2-3) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 2, day: 3),  // Sat
            makeDate(year: 2024, month: 2, day: 4),  // Sun
            makeDate(year: 2024, month: 3, day: 2),  // Sat
            makeDate(year: 2024, month: 3, day: 3),  // Sun
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .weekendOrdinals([1])))
    }

    @Test func predictThirdWeekend() {
        // 3rd weekend of Jan (20-21), Feb (17-18), Mar (16-17) 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 20), // Sat
            makeDate(year: 2024, month: 1, day: 21), // Sun
            makeDate(year: 2024, month: 2, day: 17), // Sat
            makeDate(year: 2024, month: 2, day: 18), // Sun
            makeDate(year: 2024, month: 3, day: 16), // Sat
            makeDate(year: 2024, month: 3, day: 17), // Sun
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .weekendOrdinals([3])))
    }

    @Test func predictFirstAndThirdWeekends() {
        // 1st and 3rd weekends of Jan and Feb 2024
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // 1st Sat
            makeDate(year: 2024, month: 1, day: 7),  // 1st Sun
            makeDate(year: 2024, month: 1, day: 20), // 3rd Sat
            makeDate(year: 2024, month: 1, day: 21), // 3rd Sun
            makeDate(year: 2024, month: 2, day: 3),  // 1st Sat
            makeDate(year: 2024, month: 2, day: 4),  // 1st Sun
            makeDate(year: 2024, month: 2, day: 17), // 3rd Sat
            makeDate(year: 2024, month: 2, day: 18), // 3rd Sun
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .weekendOrdinals([1, 3])))
    }

    @Test func predictWeekendOrdinalsWithTrailingMonth() {
        // 1st weekend of Jan, Feb; only Saturday of Mar (trailing)
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 2, day: 3),  // Sat
            makeDate(year: 2024, month: 2, day: 4),  // Sun
            makeDate(year: 2024, month: 3, day: 2),  // Sat (trailing)
        ]
        let pattern = MonthlyPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == MonthlyPattern(stepSize: 1, anchor: .weekendOrdinals([1])))
    }

    // MARK: - Weekend ordinal extraction

    @Test func extractFirstWeekendByCount() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .weekendOrdinals([1]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let dates = pattern.extractDates(start: start, first: 6, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 2, day: 3),  // Sat
            makeDate(year: 2024, month: 2, day: 4),  // Sun
            makeDate(year: 2024, month: 3, day: 2),  // Sat
            makeDate(year: 2024, month: 3, day: 3),  // Sun
        ])
    }

    @Test func extractFirstAndThirdWeekendsByRange() {
        let pattern = MonthlyPattern(stepSize: 1, anchor: .weekendOrdinals([1, 3]))
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 1, day: 31)
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 6),  // 1st Sat
            makeDate(year: 2024, month: 1, day: 7),  // 1st Sun
            makeDate(year: 2024, month: 1, day: 20), // 3rd Sat
            makeDate(year: 2024, month: 1, day: 21), // 3rd Sun
        ])
    }

    // MARK: - Weekend ordinal description

    @Test func descriptionFirstWeekend() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .weekendOrdinals([1]))
        )
        #expect(pattern.description == "Every month on the 1st weekend")
    }

    @Test func descriptionFirstAndThirdWeekends() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 1, anchor: .weekendOrdinals([1, 3]))
        )
        #expect(pattern.description == "Every month on the 1st and 3rd weekends")
    }

    @Test func descriptionSecondWeekendBimonthly() {
        let pattern = RecurrencePattern.monthly(
            MonthlyPattern(stepSize: 2, anchor: .weekendOrdinals([2]))
        )
        #expect(pattern.description == "Every other month on the 2nd weekend")
    }
}
