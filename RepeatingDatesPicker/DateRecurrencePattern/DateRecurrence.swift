//
//  Created by Taehun Kim on 21.08.23.
//

import Foundation

public struct DateRecurrence: Hashable {
    public let startDate: Date
    public let endDate: Date
    public let pattern: RecurrencePattern
}
