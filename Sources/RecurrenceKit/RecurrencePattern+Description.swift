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
        case .monthly(let p):
            p.recurrenceDescription
        case .yearly(let p):
            p.recurrenceDescription
        case .unknown:
            "No pattern detected"
        }
    }
}

extension DailyPattern {
    var recurrenceDescription: String {
        switch stepSize {
        case 1: "Every day"
        case 2: "Every other day"
        default: "Every \(stepSize) days"
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

extension MonthlyPattern {
    var recurrenceDescription: String {
        let frequency: String
        switch stepSize {
        case 1: frequency = "Every month"
        case 2: frequency = "Every other month"
        default: frequency = "Every \(stepSize) months"
        }

        let anchorText: String
        switch anchor {
        case .daysOfMonth(let days):
            if days.count == 1 {
                anchorText = "on the \(ordinalString(days[0]))"
            } else {
                let dayList = days.map { ordinalString($0) }
                    .formatted(.list(type: .and))
                anchorText = "on the \(dayList)"
            }
        case .weekdayOrdinals(let ordinals, let weekDay):
            if ordinals.count == 1 {
                anchorText = "on the \(ordinalString(ordinals[0])) \(weekDay)"
            } else {
                let list = ordinals.map { ordinalString($0) }
                    .formatted(.list(type: .and))
                anchorText = "on the \(list) \(weekDay)"
            }
        case .weekendOrdinals(let ordinals):
            if ordinals.count == 1 {
                anchorText = "on the \(ordinalString(ordinals[0])) weekend"
            } else {
                let list = ordinals.map { ordinalString($0) }
                    .formatted(.list(type: .and))
                anchorText = "on the \(list) weekends"
            }
        case .lastDay:
            anchorText = "on the last day"
        case .lastWeekday(let weekDay):
            anchorText = "on the last \(weekDay)"
        }

        return "\(frequency) \(anchorText)"
    }

    private func ordinalString(_ n: Int) -> String {
        let suffix: String
        let ones = n % 10
        let tens = (n / 10) % 10
        if tens == 1 {
            suffix = "th"
        } else {
            switch ones {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(n)\(suffix)"
    }
}

extension YearlyPattern {
    var recurrenceDescription: String {
        let frequency: String
        switch stepSize {
        case 1: frequency = "Every year"
        case 2: frequency = "Every other year"
        default: frequency = "Every \(stepSize) years"
        }

        let monthName = Self.monthName(month)

        let anchorText: String
        switch anchor {
        case .dayOfMonth(let day):
            anchorText = "on \(monthName) \(ordinalString(day))"
        case .weekdayOrdinal(let ordinal, let weekDay):
            anchorText = "on the \(ordinalString(ordinal)) \(weekDay) of \(monthName)"
        case .lastDay:
            anchorText = "on the last day of \(monthName)"
        case .lastWeekday(let weekDay):
            anchorText = "on the last \(weekDay) of \(monthName)"
        }

        return "\(frequency) \(anchorText)"
    }

    private func ordinalString(_ n: Int) -> String {
        let suffix: String
        let ones = n % 10
        let tens = (n / 10) % 10
        if tens == 1 {
            suffix = "th"
        } else {
            switch ones {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(n)\(suffix)"
    }

    private static func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.monthSymbols[month - 1]
    }
}
