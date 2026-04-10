import Foundation

/// A fixed Gregorian calendar with UTC timezone for deterministic tests.
extension Calendar {
    static let test: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        cal.firstWeekday = 1 // Sunday
        return cal
    }()
}

/// Creates a date from components using the test calendar.
func makeDate(
    year: Int, month: Int, day: Int,
    hour: Int = 0, minute: Int = 0
) -> Date {
    let components = DateComponents(
        year: year, month: month, day: day,
        hour: hour, minute: minute
    )
    return Calendar.test.date(from: components)!
}
