//
//  Created by Taehun Kim on 10.08.23.
//

import Foundation

public enum RecurrencePattern: Hashable {
    case daily(DailyPattern)
    case weekly(WeeklyPattern)
    case unknown([Date])

    public static func predict(from dates: [Date]) -> RecurrencePattern {
        if let pattern = DailyPattern.predict(from: dates) {
            return .daily(pattern)
        } else if let pattern = WeeklyPattern.predict(from: dates) {
            return .weekly(pattern)
        }

        return .unknown(dates)
    }

    public func extractDates(start: Date, end: Date) -> [Date] {
        switch self {
        case .daily(let details):
            return details.extractDates(start: start, end: end)
        case .weekly(let details):
            return details.extractDates(start: start, end: end)
        case .unknown(let dates):
            return dates    // TODO: filter out dates
        }
    }

    public func extractDates(start: Date, first: Int) -> [Date] {
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
