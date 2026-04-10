import Testing
import Foundation
@testable import RecurrenceKit

@Suite("Codable Round-Trip")
struct CodableTests {

    let calendar = Calendar.test

    // MARK: - DailyPattern

    @Test func dailyPatternCodable() throws {
        let pattern = DailyPattern(interval: 3)
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(DailyPattern.self, from: data)
        #expect(decoded == pattern)
    }

    // MARK: - WeeklyPattern

    @Test func weeklyPatternCodable() throws {
        let pattern = WeeklyPattern(stepSize: 2, weekDays: [.monday, .wednesday, .friday])
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(WeeklyPattern.self, from: data)
        #expect(decoded == pattern)
    }

    // MARK: - WeekdaysPattern

    @Test func weekdaysPatternCodable() throws {
        let pattern = WeekdaysPattern(stepSize: 1)
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(WeekdaysPattern.self, from: data)
        #expect(decoded == pattern)
    }

    // MARK: - WeekendsPattern

    @Test func weekendsPatternCodable() throws {
        let pattern = WeekendsPattern(stepSize: 2)
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(WeekendsPattern.self, from: data)
        #expect(decoded == pattern)
    }

    // MARK: - RecurrencePattern (enum)

    @Test func recurrencePatternDailyCodable() throws {
        let pattern = RecurrencePattern.daily(DailyPattern(interval: 1))
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(RecurrencePattern.self, from: data)
        #expect(decoded == pattern)
    }

    @Test func recurrencePatternWeeklyCodable() throws {
        let pattern = RecurrencePattern.weekly(
            WeeklyPattern(stepSize: 1, weekDays: [.monday, .friday])
        )
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(RecurrencePattern.self, from: data)
        #expect(decoded == pattern)
    }

    @Test func recurrencePatternWeekdaysCodable() throws {
        let pattern = RecurrencePattern.weekdays(WeekdaysPattern(stepSize: 1))
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(RecurrencePattern.self, from: data)
        #expect(decoded == pattern)
    }

    @Test func recurrencePatternWeekendsCodable() throws {
        let pattern = RecurrencePattern.weekends(WeekendsPattern(stepSize: 2))
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(RecurrencePattern.self, from: data)
        #expect(decoded == pattern)
    }

    @Test func recurrencePatternUnknownCodable() throws {
        let dates = [1, 5, 10].map { makeDate(year: 2024, month: 1, day: $0) }
        let pattern = RecurrencePattern.unknown(dates)
        let data = try JSONEncoder().encode(pattern)
        let decoded = try JSONDecoder().decode(RecurrencePattern.self, from: data)
        #expect(decoded == pattern)
    }

    // MARK: - DateRecurrence

    @Test func dateRecurrenceCodable() throws {
        let recurrence = DateRecurrence(
            startDate: makeDate(year: 2024, month: 1, day: 1),
            endDate: makeDate(year: 2024, month: 3, day: 1),
            pattern: .daily(DailyPattern(interval: 2))
        )
        let data = try JSONEncoder().encode(recurrence)
        let decoded = try JSONDecoder().decode(DateRecurrence.self, from: data)
        #expect(decoded == recurrence)
    }
}
