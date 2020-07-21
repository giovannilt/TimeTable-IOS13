//
//  WorkingDay.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 14/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//
import Foundation

struct Stamping{
    var userID: String
    var timeStamp: Date
    var subject: StampingSubject
    var isValid: Bool
}

enum StampingSubject: String {
    case ClockIn
    case ClockOut
    case BreakClockOut
    case BreakClockIn
}
