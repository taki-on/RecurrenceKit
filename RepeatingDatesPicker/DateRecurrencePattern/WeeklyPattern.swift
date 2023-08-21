//
//  Created by Taehun Kim on 21.08.23.
//

import Foundation

public struct WeeklyPattern: Hashable {
    public let stepSize: UInt
    public let weekDays: [WeekDay]

    public func extractDates(start: Date, end: Date) -> [Date] {
        []
    }

    public func extractDates(start: Date, first: Int) -> [Date] {
        []
    }

    static func predict(from dates: [Date]) -> WeeklyPattern? {
        nil
    }
}
