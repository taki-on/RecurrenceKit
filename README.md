# RecurrenceKit

A Swift package that detects repeating date patterns from an array of dates and extracts future occurrences.

Given a set of dates, `RecurrenceKit` predicts whether they follow a **daily**, **weekly**, **monthly**, or **yearly** recurrence pattern, then generates future dates matching that pattern.

All types are `Sendable`, `Codable`, and `Hashable` — fully compatible with Swift 6 strict concurrency.

## Installation

### Swift Package Manager

Add RecurrenceKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/taki-on/RecurrenceKit.git", from: "1.0.0"),
]
```

Then add it as a dependency to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["RecurrenceKit"]
),
```

### Xcode

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies…**
3. Paste the URL: `https://github.com/taki-on/RecurrenceKit.git`
4. Choose your version rule and click **Add Package**

## Usage

### Predict a pattern from dates

```swift
import RecurrenceKit

let dates: [Date] = [jan15, feb15, mar15] // 15th of each month

let pattern = RecurrencePattern.predict(from: dates)
// → .monthly(MonthlyPattern(stepSize: 1, anchor: .daysOfMonth([15])))

print(pattern.description)
// → "Every month on the 15th"
```

### Extract future dates

```swift
// Extract the next 10 occurrences
let futureDates = pattern.extractDates(start: Date(), first: 10)

// Or extract within a date range
let rangeDates = pattern.extractDates(start: rangeStart, end: rangeEnd)
```

### Using DateRecurrence (convenience)

```swift
let recurrence = DateRecurrence.make(from: myDates)
// recurrence.pattern   → the detected pattern
// recurrence.startDate → earliest input date
// recurrence.endDate   → projected end date
```

## Supported Patterns

| Pattern | Examples | Description |
|---------|----------|-----------|
| **Daily** | Every day, every 3 days | Uniform day-step between all dates |
| **Weekdays** | Every weekday, every other weekday | Monday through Friday with uniform week-step |
| **Weekends** | Every weekend, every other weekend | Saturday and Sunday with uniform week-step |
| **Weekly** | Every Monday, every Mon/Wed/Fri, biweekly | Consistent weekday grouping with uniform week-step |
| **Monthly** | Every month on the 15th, every month on the 1st and 8th | Fixed days of the month with uniform month-step |
| | Every month on the 2nd Tuesday, every month on the 1st and 3rd Friday | Nth weekday occurrences within each month |
| | Every month on the 1st weekend, every month on the 1st and 3rd weekends | Nth weekend (Sat+Sun) pairs within each month |
| | Every month on the last day, every month on the last Friday | Last day or last weekday of the month |
| **Yearly** | Every year on July 4th, every year on the 3rd Monday of January | Fixed date, Nth weekday, last day, or last weekday in a specific month |
| **Unknown** | Irregular dates | Fallback when no pattern is detected |

### Pattern descriptions

Every pattern produces a human-readable description:

```swift
RecurrencePattern.daily(DailyPattern(stepSize: 2)).description
// → "Every other day"

RecurrencePattern.monthly(MonthlyPattern(stepSize: 1, anchor: .weekdayOrdinals(ordinals: [1, 3], weekDay: .friday))).description
// → "Every month on the 1st and 3rd Friday"

RecurrencePattern.yearly(YearlyPattern(stepSize: 1, month: 11, anchor: .weekdayOrdinal(ordinal: 4, weekDay: .thursday))).description
// → "Every year on the 4th Thursday of November"
```

## API Overview

- **`RecurrencePattern`** — enum with cases: `.daily`, `.weekdays`, `.weekends`, `.weekly`, `.monthly`, `.yearly`, `.unknown`. Entry point for prediction and extraction.
- **`DailyPattern`** — every N days.
- **`WeeklyPattern`** — every N weeks on specific weekdays.
- **`WeekdaysPattern`** — every N weeks on Mon–Fri.
- **`WeekendsPattern`** — every N weeks on Sat–Sun.
- **`MonthlyPattern`** — every N months with anchor: fixed days, Nth weekday(s), weekend ordinals, last day, or last weekday.
- **`YearlyPattern`** — every N years in a specific month with anchor: fixed day, Nth weekday, last day, or last weekday.
- **`DateRecurrence`** — convenience wrapper combining start date, end date, and pattern.
- **`WeekDay`** — enum matching Foundation's `Calendar` weekday numbering (Sunday = 1).

## Prediction Priority

When multiple patterns could match, the most specific one wins:

1. **Yearly** — dates span multiple years in the same month
2. **Monthly** — dates span multiple months with consistent anchors
3. **Weekdays / Weekends** — Mon–Fri or Sat–Sun with consistent week-step
4. **Weekly** — consistent weekdays with uniform week-step
5. **Daily** — uniform day-step between all dates

## Demo App

The repository includes a demo iOS app in the `Demo/` directory that lets you tap dates on a calendar and see the detected pattern in real time. The demo app is not included when consuming the package via SPM.

## Requirements

- Swift 6.0+
- iOS 17+ / macOS 14+ / watchOS 10+ / tvOS 17+
