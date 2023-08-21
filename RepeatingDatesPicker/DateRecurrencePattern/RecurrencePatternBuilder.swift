//
//  Created by Taehun Kim on 10.08.23.
//

import Foundation

public enum RecurrencePatternBuilder {
    public func predict(from: [Date], start: Date, end: Date) -> DateRecurrence {
        let pattern = RecurrencePattern.daily(.days(1))
        return DateRecurrence(startDate: start, endDate: end, pattern: pattern)
    }
}
