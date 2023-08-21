//
//  RecurrencePattern.swift
//  RepeatingDatesPicker
//
//  Created by Taehun Kim on 10.08.23.
//

import Foundation

public enum RecurrencePattern: Hashable {
    case daily(DailyRecurrenceDetails)
    case weekly(WeeklyRecurrenceDetails)
    case unknown([Date])

    static func predict(from dates: [Date]) -> RecurrencePattern {
        if let dailyDetails = DailyRecurrenceDetails.predict(from: dates) {
            return .daily(dailyDetails)
        } else if let weeklyDetails = WeeklyRecurrenceDetails.predict(from: dates) {
            return .weekly(weeklyDetails)
        }

        return .unknown(dates)
    }

    func extractDates(start: Date, end: Date) -> [Date] {
        switch self {
        case .daily(let details):
            return details.extractDates(start: start, end: end)
        case .weekly(let details):
            return details.extractDates(start: start, end: end)
        case .unknown(let dates):
            return dates    // TODO: filter out dates
        }
    }

    func extractDates(start: Date, first: Int) -> [Date] {
        switch self {
        case .daily(let details):
            return details.extractDates(start: start, first: first)
        case .weekly(let details):
            return details.extractDates(start: start, first: first)
        case .unknown(let dates):
            return Array(dates.prefix(first))
        }
    }
}

public enum RecurringWeekDay: Hashable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

private protocol DateExtracting {
    func extractDates(start: Date, end: Date) -> [Date]
    func extractDates(start: Date, first: Int) -> [Date]
}

public enum DailyRecurrenceDetails: DateExtracting, Hashable {
    case days(UInt)
    case weekDays([RecurringWeekDay])

    func extractDates(start: Date, end: Date) -> [Date] {
        []
    }

    func extractDates(start: Date, first: Int) -> [Date] {
        []
    }

    static func predict(from dates: [Date]) -> DailyRecurrenceDetails? {
        nil
    }
}

public struct WeeklyRecurrenceDetails: DateExtracting, Hashable {
    let stepSize: UInt
    let weekDays: [RecurringWeekDay]

    func extractDates(start: Date, end: Date) -> [Date] {
        []
    }

    func extractDates(start: Date, first: Int) -> [Date] {
        []
    }

    static func predict(from dates: [Date]) -> WeeklyRecurrenceDetails? {
        nil
    }
}

extension Array where Element == RecurringWeekDay {
    var isWeekdays: Bool {
        Set(self) == Set([.monday, .tuesday, .wednesday, .thursday, .friday])
    }

    var isWeekends: Bool {
        Set(self) == Set([.saturday, .sunday])
    }
}
