//
//  ReportManager.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 22/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol ReportManagerDelegate{
    func didLoadWorkingDays(_ reportManager: ReportManager, workingDays: [String: WorkingDayModel], weeks: [String])
    func didFailWithError(_ error: Error)
}

struct ReportManager{
    let db = Firestore.firestore()
    var delegate: ReportManagerDelegate?
    
    func loadWorkingDays(date: Date){
        if let userUID = Auth.auth().currentUser?.uid{
            let days30Ago = date - (30.0 * (24 * 60 * 60))
            let collection = db.collection(K.FSStore.TimeStampCollectionName)
                .whereField(K.FSStore.UserID, isEqualTo: userUID)
                .whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay)
                .whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: days30Ago.startOfDay)
                .whereField(K.FSStore.IsValid, isEqualTo: true).order(by: K.FSStore.TimeStamp, descending: false)
            collection.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("Error loading wokgin Days: \(e)")
                    self.delegate?.didFailWithError(error!)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents, snapshotDocuments.count > 0{
                        var workingDays = [String: WorkingDayModel]()
                        var weeks = [Int: String]()
                        for data in snapshotDocuments {
                            if let dataTimeStamp = data[K.FSStore.TimeStamp], let dataSubject = data[K.FSStore.Subject]{
                                let timeStamp = (dataTimeStamp as! Timestamp).dateValue()
                                weeks[timeStamp.weekOfYear()] = "\(timeStamp.weekOfYear())"
                                if let stampingSubject = StampingSubject(rawValue: (dataSubject as! String)){
                                    var workingDay: WorkingDayModel = WorkingDayModel(breakMinutesSimulation: 30)
                                    if let wd = workingDays[timeStamp.formatToday()]{
                                        workingDay = wd
//                                      workingDays.updateValue(workingDay, forKey: timeStamp.formatToday())
                                    }
                                    switch  stampingSubject{
                                    case StampingSubject.ClockIn:
                                        workingDay.stampingWorkingDayIN = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.ClockIn, isValid: true)
                                    case StampingSubject.ClockOut:
                                        workingDay.stampingWorkingDayOUT = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.ClockOut, isValid: true)
                                    case StampingSubject.BreakClockIn:
                                        workingDay.stampingBreakIN = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.BreakClockIn, isValid: true)
                                    case StampingSubject.BreakClockOut:
                                        workingDay.stampingBreakOUT = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.BreakClockOut, isValid: true)
                                    }
                                    
                                    workingDays[ timeStamp.formatToday()] = workingDay
                                
                                }
                            }
                        }
                        let sorted = weeks.sorted( by:{$0.key < $1.key})
                        self.delegate?.didLoadWorkingDays(self, workingDays: workingDays, weeks:Array(sorted.map({$0.value})))
                    }
                }
            }
        }
    }
    
}
