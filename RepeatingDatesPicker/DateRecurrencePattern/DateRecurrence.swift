//
//  Created by Taehun Kim on 21.08.23.
//

import Foundation

public struct DateRecurrence: Hashable {
    public let startDate: Date
    public let endDate: Date
    public let pattern: RecurrencePattern

    public static func make(dates: [Date], start: Date, end: Date) -> DateRecurrence {
        let pattern = RecurrencePattern.predict(from: dates)
        return DateRecurrence(startDate: start, endDate: end, pattern: pattern)
    }
}
