# DateRecurrencePattern

A Swift package that detects repeating date patterns from an array of dates and extracts future occurrences.

Given a set of dates, `DateRecurrencePattern` can predict whether they follow a **daily** or **weekly** recurrence pattern, then generate future dates matching that pattern.

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<your-org>/DateRecurrencePattern.git", from: "1.0.0"),
]
```

Or in Xcode: **File → Add Package Dependencies** and paste the repository URL.

## Usage

### Predict a pattern from dates

```swift
import DateRecurrencePattern

// Dates that fall on every Monday
let dates = [
    /* 2024-01-01 */ monday1,
    /* 2024-01-08 */ monday2,
    /* 2024-01-15 */ monday3,
    /* 2024-01-22 */ monday4,
]

let pattern = RecurrencePattern.predict(from: dates)
// → .weekly(WeeklyPattern(stepSize: 1, weekDays: [.monday]))
```

### Extract future dates

```swift
// Extract the next 10 occurrences
let futureDates = pattern.extractDates(
    start: Date(),
    first: 10
)

// Or extract within a date range
let range = pattern.extractDates(
    start: rangeStart,
    end: rangeEnd
)
```

### Using DateRecurrence (convenience)

```swift
let recurrence = DateRecurrence.make(from: myDates)
// recurrence.pattern   → the detected pattern
// recurrence.startDate → earliest input date
// recurrence.endDate   → projected end date
```

## Supported Patterns

| Pattern | Example | Detection |
|---------|---------|-----------|
| **Daily** | Every day, every 3 days | Uniform day-interval between all dates |
| **Weekly** | Every Mon/Wed/Fri, biweekly Saturday | Consistent weekday grouping with uniform week-step |
| **Unknown** | Irregular dates | Fallback when no pattern is detected |

## API Overview

- **`RecurrencePattern`** — enum: `.daily`, `.weekly`, `.unknown`. Entry point for prediction.
- **`DailyPattern`** — every N days. Predict and extract.
- **`WeeklyPattern`** — every N weeks on specific weekdays. Predict and extract.
- **`DateRecurrence`** — convenience wrapper combining a start date, end date, and pattern.
- **`WeekDay`** — enum matching Foundation's `Calendar` weekday numbering (Sunday = 1).

## Roadmap

- [ ] Monthly patterns (e.g., "1st and 15th of every month")
- [ ] Yearly patterns (e.g., "every March 15")
- [ ] Confidence scoring for predictions
- [ ] DocC documentation catalog

## Requirements

- Swift 6.0+
- iOS 17+ / macOS 14+ / watchOS 10+ / tvOS 17+
