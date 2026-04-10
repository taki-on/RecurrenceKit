import Testing
import Foundation
@testable import RecurrenceKit

@Suite("WeekendsPattern")
struct WeekendsPatternTests {

    let calendar = Calendar.test

    // MARK: - Prediction

    @Test func predictWeekends() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 14), // Sun
        ]
        let pattern = WeekendsPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeekendsPattern(stepSize: 1))
    }

    @Test func predictBiweeklyWeekends() {
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 20), // Sat (2 weeks later)
            makeDate(year: 2024, month: 1, day: 21), // Sun
        ]
        let pattern = WeekendsPattern.predict(from: dates, calendar: calendar)
        #expect(pattern == WeekendsPattern(stepSize: 2))
    }

    @Test func predictReturnsNilForWeekdays() {
        let dates = (1...5).map { makeDate(year: 2024, month: 1, day: $0) }
            + (8...12).map { makeDate(year: 2024, month: 1, day: $0) }
        #expect(WeekendsPattern.predict(from: dates, calendar: calendar) == nil)
    }

    @Test func predictReturnsNilForSaturdayOnly() {
        // Only Saturdays — not a full weekend pattern
        let dates = [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 13), // Sat
        ]
        #expect(WeekendsPattern.predict(from: dates, calendar: calendar) == nil)
    }

    // MARK: - Extraction by range

    @Test func extractWeekendsInRange() {
        let pattern = WeekendsPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 1)  // Mon
        let end = makeDate(year: 2024, month: 1, day: 14)   // Sun
        let dates = pattern.extractDates(start: start, end: end, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 14), // Sun
        ])
    }

    // MARK: - Extraction by count

    @Test func extractFirstFourWeekendDays() {
        let pattern = WeekendsPattern(stepSize: 1)
        let start = makeDate(year: 2024, month: 1, day: 1) // Mon
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 6),  // Sat
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 14), // Sun
        ])
    }

    @Test func extractBiweeklyWeekends() {
        let pattern = WeekendsPattern(stepSize: 2)
        // Start on a Saturday so the first weekend pair is included
        let start = makeDate(year: 2024, month: 1, day: 7) // Sun
        let dates = pattern.extractDates(start: start, first: 4, calendar: calendar)
        #expect(dates == [
            makeDate(year: 2024, month: 1, day: 7),  // Sun
            makeDate(year: 2024, month: 1, day: 13), // Sat
            makeDate(year: 2024, month: 1, day: 21), // Sun (2 weeks later)
            makeDate(year: 2024, month: 1, day: 27), // Sat
        ])
    }
}
