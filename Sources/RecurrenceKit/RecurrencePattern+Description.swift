import Foundation

extension RecurrencePattern: CustomStringConvertible {
    /// A natural-language description of this recurrence pattern.
    public var description: String {
        switch self {
        case .daily(let p):
            p.recurrenceDescription
        case .weekdays(let p):
            p.recurrenceDescription
        case .weekends(let p):
            p.recurrenceDescription
        case .weekly(let p):
            p.recurrenceDescription
        case .unknown:
            "No pattern detected"
        }
    }
}

extension DailyPattern {
    var recurrenceDescription: String {
        switch interval {
        case 1: "Every day"
        case 2: "Every other day"
        default: "Every \(interval) days"
        }
    }
}

extension WeekdaysPattern {
    var recurrenceDescription: String {
        switch stepSize {
        case 1: "Every weekday"
        case 2: "Every other weekday"
        default: "Every \(stepSize) weeks on weekdays"
        }
    }
}

extension WeekendsPattern {
    var recurrenceDescription: String {
        switch stepSize {
        case 1: "Every weekend"
        case 2: "Every other weekend"
        default: "Every \(stepSize) weeks on weekends"
        }
    }
}

extension WeeklyPattern {
    var recurrenceDescription: String {
        let daysList = weekDays
            .sorted(by: { $0.rawValue < $1.rawValue })
            .map(\.description)
            .formatted(.list(type: .and))

        switch stepSize {
        case 1:
            if weekDays.count == 1 {
                return "Every \(daysList)"
            }
            return "Every \(daysList)"
        case 2:
            if weekDays.count == 1 {
                return "Every other \(daysList)"
            }
            return "Every 2 weeks on \(daysList)"
        default:
            return "Every \(stepSize) weeks on \(daysList)"
        }
    }
}
