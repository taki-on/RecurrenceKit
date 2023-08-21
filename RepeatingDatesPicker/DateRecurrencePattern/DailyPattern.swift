//
//  Created by Taehun Kim on 21.08.23.
//

import Foundation

public enum DailyPattern: Hashable {
    case days(UInt)
    case weekDays([WeekDay])

    public func extractDates(start: Date, end: Date) -> [Date] {
        []
    }

    public func extractDates(start: Date, first: Int) -> [Date] {
        []
    }

    public static func predict(from dates: [Date]) -> DailyPattern? {
        nil
    }
}
