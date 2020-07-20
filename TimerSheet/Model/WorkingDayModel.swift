//
//  WorkingDayModel.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 15/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import Foundation

struct WorkingDayModel{
    var stampingWorkingDayIN: Stamping?
    var stampingWorkingDayOUT: Stamping?
    var stampingBreakIN: Stamping?
    var stampingBreakOUT: Stamping?
    
    var breakMinutesSimulation: Int
    
    mutating func setStamping(_ timeStamp: Stamping){
        switch timeStamp.subject{
            case StampingSubject.ClockIn:
                stampingWorkingDayIN = timeStamp
            case StampingSubject.ClockOut:
                stampingWorkingDayOUT = timeStamp
            case StampingSubject.BreakClockIn:
                stampingBreakIN = timeStamp
            case StampingSubject.BreakClockOut:
                stampingBreakOUT = timeStamp
        }
    }
    func hasClockedInWorkingDay() -> Bool{
        if  stampingWorkingDayIN != nil{
            return true
        }
        return false
    }
    func hasClockedOutWorkingDay() -> Bool{
        if  stampingWorkingDayOUT != nil{
            return true
        }
        return false
    }
    func hasClockedInBreak() -> Bool{
        if stampingBreakIN != nil{
            return true
        }
        return false
    }
    func hasClockedOutBreak() -> Bool{
        if  stampingBreakOUT != nil{
            return true
        }
        return false
    }
    
    func clockInWorkginDayFormatted() -> String{
        if let stampingWIN = stampingWorkingDayIN {
            return stampingWIN.timeStamp.formatHour()
        }
        return "-"
    }
    func clockOutWorkginDayFormatted() -> String{
        if let stampingWOUT = stampingWorkingDayOUT {
            return stampingWOUT.timeStamp.formatHour()
        }
        return "-"
    }
    func clockInBreakFormatted() -> String{
        if let stampingBIN = stampingBreakIN {
            return stampingBIN.timeStamp.formatHour()
        }
        return "-"
    }
    func clockOutBreakFormatted() -> String{
        if let stampingBOUT = stampingBreakOUT {
            return stampingBOUT.timeStamp.formatHour()
        }
        return "-"
    }
}


