//
//  Created by Taehun Kim on 19.08.23.
//

import XCTest
@testable import DateRecurrencePattern

class PredictionTests: XCTestCase {

    func testRandomDays() {
        let dates = [
            Date(timeIntervalSince1970: 60 * 60 * 24 * 1),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 2),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 5),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 10),
        ]
        let pattern = RecurrencePattern.predict(from: dates)
        XCTAssertEqual(pattern, RecurrencePattern.unknown(dates))
    }

    func testEveryday() {
        let dates = [
            Date(timeIntervalSince1970: 60 * 60 * 24 * 1),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 2),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 3),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 4),
        ]
        let pattern = RecurrencePattern.predict(from: dates)
        XCTAssertEqual(pattern, RecurrencePattern.daily(DailyPattern(interval: 1)))
    }

    func testEverySecondDays() {
        let dates = [
            Date(timeIntervalSince1970: 60 * 60 * 24 * 1),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 3),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 5),
            Date(timeIntervalSince1970: 60 * 60 * 24 * 7),
        ]
        let pattern = RecurrencePattern.predict(from: dates)
        XCTAssertEqual(pattern, RecurrencePattern.daily(DailyPattern(interval: 2)))
    }

    func test_every_x_week_y_weekdays() { }
    func test_every_weekdays() { }
    func test_every_weekends() { }
}
