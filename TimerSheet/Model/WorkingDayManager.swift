//
//  WorkingDayBrain.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 17/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol WorkingDayManagerDelegate{
    func didUpdateWorkingDay(_ workingDayManager: WorkingDayManager, workingDay: WorkingDayModel)
    func didSaveStamp(_ workingDayManager: WorkingDayManager, timeStamp: Stamping)
    func didFailWithError(_ error: Error)
}

struct WorkingDayManager{
    let db = Firestore.firestore()
    var delegate: WorkingDayManagerDelegate?
    
    func previsionEndOfDay(workingDay: WorkingDayModel) -> String{
        if let stampingWorkingDayIN = workingDay.stampingWorkingDayIN {
            let endOfDay = stampingWorkingDayIN.timeStamp.addingTimeInterval(8.0 * 60.0 * 60.0)
            if let stampingBreakIN = workingDay.stampingBreakIN, let stampingBreakOUT = workingDay.stampingBreakOUT {
                return endOfDay.addingTimeInterval(stampingBreakOUT.timeStamp.timeIntervalSince(stampingBreakIN.timeStamp)).formatHour()
            }
            if let breakMinutesSimulation = workingDay.breakMinutesSimulation {
                return endOfDay.addingTimeInterval(Double(breakMinutesSimulation * 60)).formatHour()
            }
        }
        return ""
    }
    
    func saveTimeStamp(_ timeStamp: Stamping){
        if let userUID = Auth.auth().currentUser?.uid{
            db.collection(K.FSStore.TimeStampCollectionName).addDocument(data: [
                K.FSStore.UserID: userUID,
                K.FSStore.TimeStamp: Timestamp(date: timeStamp.timeStamp),
                K.FSStore.Subject: "\(timeStamp.subject)"
            ]) { (error) in
                if let e = error{
                    print("Errore nel salvare in firestore \(e)")
                    self.delegate?.didFailWithError(error!)
                }else{
                    self.delegate?.didSaveStamp(self, timeStamp: timeStamp)
                    print("Salvato Clock \(timeStamp.subject)")
                }
            }
        }
    }
    
    func retiveDailyTimeStamps(){
        let date = Date()
        print(date.startOfDay)
        print(date.endOfDay)
        if let userUID = Auth.auth().currentUser?.uid{
            let collection = db.collection(K.FSStore.TimeStampCollectionName
            ).whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: date.startOfDay
            ).whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay
            ).whereField(K.FSStore.UserID, isEqualTo: userUID
            ).order(by: K.FSStore.TimeStamp, descending: false)
            
            collection.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                    self.delegate?.didFailWithError(error!)
                } else {
                    var workingDayModel: WorkingDayModel = WorkingDayModel()
                    if let snapshotDocuments = querySnapshot?.documents, snapshotDocuments.count > 0{
                        for data in snapshotDocuments {
                            if let dataTimeStamp = data[K.FSStore.TimeStamp], let dataSubject = data[K.FSStore.Subject]{
                                let timeStamp = (dataTimeStamp as! Timestamp).dateValue()
                                if let stampingSubject = StampingSubject(rawValue: (dataSubject as! String)){
                                    switch  stampingSubject{
                                    case StampingSubject.ClockIn:
                                        if workingDayModel.stampingWorkingDayIN == nil{
                                            workingDayModel.stampingWorkingDayIN = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.ClockIn)
                                        }else if  let modelDate = workingDayModel.stampingWorkingDayIN, modelDate.timeStamp > timeStamp {
                                            workingDayModel.stampingWorkingDayIN?.timeStamp = timeStamp
                                        }
                                    case StampingSubject.ClockOut:
                                        if workingDayModel.stampingWorkingDayOUT == nil{
                                            workingDayModel.stampingWorkingDayOUT = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.ClockOut)
                                        }else if  let modelDate = workingDayModel.stampingWorkingDayOUT, modelDate.timeStamp <= timeStamp {
                                            workingDayModel.stampingWorkingDayOUT?.timeStamp = timeStamp
                                        }
                                    case StampingSubject.BreakClockIn:
                                        if workingDayModel.stampingBreakIN == nil{
                                            workingDayModel.stampingBreakIN = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.BreakClockIn)
                                        }else if  let modelDate = workingDayModel.stampingBreakIN, modelDate.timeStamp > timeStamp {
                                            workingDayModel.stampingBreakIN?.timeStamp = timeStamp
                                        }
                                    case StampingSubject.BreakClockOut:
                                        if workingDayModel.stampingBreakOUT == nil{
                                            workingDayModel.stampingBreakOUT = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.BreakClockOut)
                                        }else if  let modelDate = workingDayModel.stampingBreakOUT, modelDate.timeStamp > timeStamp {
                                            workingDayModel.stampingBreakOUT?.timeStamp = timeStamp
                                        }
                                    }
                                }
                            }
                        }
                        self.delegate?.didUpdateWorkingDay(self, workingDay: workingDayModel)
                    }
                }
            }
        }
    }
}
