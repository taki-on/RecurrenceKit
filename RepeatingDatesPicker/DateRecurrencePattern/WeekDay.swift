//
//  Created by Taehun Kim on 21.08.23.
//

import Foundation

public enum WeekDay: Int, Hashable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

public extension Array where Element == WeekDay {
    var isWeekdays: Bool {
        Set(self) == Set([.monday, .tuesday, .wednesday, .thursday, .friday])
    }

    var isWeekends: Bool {
        Set(self) == Set([.saturday, .sunday])
    }
}
