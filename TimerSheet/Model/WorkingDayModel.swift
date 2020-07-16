//
//  WorkingDayModel.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 15/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import Foundation

struct WorkingDayModel{
    var hasClockedInWorkingDay: Bool
    var clockInWorkginDay: Double
    var clockOutWorkingDay: Double
   
    var hasClockedInBreak: Bool
    var clockInBreak: Double
    var clockOutBreak: Double

    func clockWorkingDayInOutStatus() -> String{
        if hasClockedInWorkingDay{
            return "ClockOut"
        }else{
            return "ClockIn"
        }
    }
    func clockBreakInOutStatus() -> String{
        if hasClockedInBreak{
            return "ClockOut"
        }else{
            return "ClockIn"
        }
    }
    func clockInWorkginDayFormatted() -> String{
        let date = Date(timeIntervalSince1970: clockInWorkginDay)
        return date.getFormattedDate(format: "dd-MM-yyyy HH:mm:ss") // Set output formate
    }
    func clockOutWorkginDayFormatted() -> String{
        let date = Date(timeIntervalSince1970: clockOutWorkingDay)
        return date.getFormattedDate(format: "dd-MM-yyyy HH:mm:ss") // Set output formate
    }
    func clockInBreakFormatted() -> String{
          let date = Date(timeIntervalSince1970: clockInBreak)
          return date.getFormattedDate(format: "dd-MM-yyyy HH:mm:ss") // Set output formate
    }
    func clockOutBreakFormatted() -> String{
        let date = Date(timeIntervalSince1970: clockOutBreak)
        return date.getFormattedDate(format: "dd-MM-yyyy HH:mm:ss") // Set output formate
    }
}


