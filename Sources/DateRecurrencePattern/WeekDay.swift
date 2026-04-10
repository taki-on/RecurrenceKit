import Foundation

/// Represents a day of the week, with raw values matching Foundation's `Calendar` weekday numbering.
///
/// Sunday = 1, Monday = 2, ..., Saturday = 7.
public enum WeekDay: Int, Codable, Hashable, CaseIterable, Sendable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

extension WeekDay: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sunday:    "Sunday"
        case .monday:    "Monday"
        case .tuesday:   "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday:  "Thursday"
        case .friday:    "Friday"
        case .saturday:  "Saturday"
        }
    }
}

extension Array where Element == WeekDay {
    /// Whether this array contains exactly the five weekdays (Monday through Friday).
    public var isWeekdays: Bool {
        Set(self) == Set([.monday, .tuesday, .wednesday, .thursday, .friday])
    }

    /// Whether this array contains exactly Saturday and Sunday.
    public var isWeekend: Bool {
        Set(self) == Set([.saturday, .sunday])
    }
}
