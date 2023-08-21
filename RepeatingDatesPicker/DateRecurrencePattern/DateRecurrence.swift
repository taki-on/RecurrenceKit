//
//  DateRecurrence.swift
//  DateRecurrencePattern
//
//  Created by Taehun Kim on 21.08.23.
//

import Foundation

public struct DateRecurrence: Hashable {
    let startDate: Date
    let endDate: Date
    let pattern: RecurrencePattern
}
