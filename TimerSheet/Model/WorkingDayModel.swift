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
    var clockInWorkginDay: Date?
    var clockOutWorkingDay: Date?
   
    var hasClockedInBreak: Bool
    var clockInBreak: Date?
    var clockOutBreak: Date?

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
        return format(date: clockInWorkginDay)
    }
    func clockOutWorkginDayFormatted() -> String{
        return format(date: clockOutWorkingDay)
    }
    func clockInBreakFormatted() -> String{
         return format(date: clockInBreak)
    }
    func clockOutBreakFormatted() -> String{
        return format(date: clockOutBreak)
    }
    
    func format(date: Date?) -> String{
        if let d = date {
            return d.getFormattedDate(format: "dd-MM-yyyy HH:mm:ss") // Set output formate
        }else{
            return "-"
        }
        
    }
}


