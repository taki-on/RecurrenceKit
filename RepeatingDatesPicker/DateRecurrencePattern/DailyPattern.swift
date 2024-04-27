//
//  Created by Taehun Kim on 21.08.23.
//

import Foundation

public struct DailyPattern: Hashable {
    let interval: Int

    public func extractDates(start: Date, end: Date) -> [Date] {
        []
    }

    public func extractDates(start: Date, first: Int) -> [Date] {
        []
    }

    public static func predict(from dates: [Date]) -> DailyPattern? {
        var interval: TimeInterval?
        for (index, date) in dates.sorted().enumerated() {
            guard index > 0 else { continue }
            let diff = abs(date.timeIntervalSince1970 - dates[index-1].timeIntervalSince1970)
            if interval == nil {
                interval = diff
            } else if let previousInterval = interval, diff != previousInterval {
                // Interval is not consistent. Nullify and bail out.
                interval = nil
                break
            }
        }

        guard let interval else { return nil }
        let intervalByDay = Int(interval / (60 * 60 * 24))
        return DailyPattern(interval: intervalByDay)
    }
}
