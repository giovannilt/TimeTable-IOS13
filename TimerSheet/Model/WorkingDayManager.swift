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
    func diddDeleteDay(_ workingDayManager: WorkingDayManager, workingDay: WorkingDayModel)
    func didSaveStamp(_ workingDayManager: WorkingDayManager, timeStamp: Stamping)
    func didFailWithError(_ error: Error)
}

struct WorkingDayManager{
    let db = Firestore.firestore()
    var delegate: WorkingDayManagerDelegate?
    
    func cleanCurrentDay (workingDay: WorkingDayModel){
        let date = Date()
        if let userUID = Auth.auth().currentUser?.uid{
            let collection = db.collection(K.FSStore.TimeStampCollectionName)
                .whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: date.startOfDay)
                .whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay)
                .whereField(K.FSStore.UserID, isEqualTo: userUID)
                .whereField(K.FSStore.IsValid, isEqualTo: true).order(by: K.FSStore.TimeStamp, descending: false)
            
            collection.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                    self.delegate?.didFailWithError(error!)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents, snapshotDocuments.count > 0{
                        for data in snapshotDocuments {
                            self.db.collection(K.FSStore.TimeStampCollectionName).document(data.documentID).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                    self.delegate?.didFailWithError(err)
                                } else {
                                    
                                    print("Deleted  \(date.formatToday())")
                                }
                            }
                        }
                        self.delegate?.diddDeleteDay(self,  workingDay: WorkingDayModel(breakMinutesSimulation: 30))
                    }
                }
            }
        }
    }
   
    func idealDay(workingDay: WorkingDayModel){
        if let userUID = Auth.auth().currentUser?.uid{
            var date = Date().startOfDay + (7 * 60.0 * 60.0) // 07:00 del mattino
            saveTimeStamp(Stamping(userID: userUID, timeStamp: date , subject: StampingSubject.ClockIn, isValid: true))
            date = date + (5 * 60.0 * 60.0)   // 12:00 ora di pranzo
            saveTimeStamp(Stamping(userID: userUID, timeStamp: date, subject: StampingSubject.BreakClockIn, isValid: true))
            date = date + (Double(workingDay.breakMinutesSimulation) * 60.0) // 12:30 fine pranzo
            saveTimeStamp(Stamping(userID: userUID, timeStamp: date, subject: StampingSubject.BreakClockOut, isValid: true))
            date = date + (3 * 60.0 * 60.0) // 16:30 ora di uscita
            saveTimeStamp(Stamping(userID: userUID, timeStamp: date, subject: StampingSubject.ClockOut, isValid: true))
        }
    }
    
    
    func generateOneMonts(){
        if let userUID = Auth.auth().currentUser?.uid{
            var date = Date()
            for i in 1...date.getDaysInMonth()  {
                date =  date.startOfDay + (7 * 60.0 * 60.0)
                saveTimeStamp(Stamping(userID: userUID, timeStamp: date, subject: StampingSubject.ClockIn, isValid: true))
                
                var randomMinutes = Double(Int.random(in: 0 ..< 10)) * 60.0
                date = date + ((5 * 60.0 * 60.0) + randomMinutes ) // 12:00 ora di pranzo + un random di 0 ... 9 minuti
                saveTimeStamp(Stamping(userID: userUID, timeStamp: date, subject: StampingSubject.BreakClockIn, isValid: true))
                
                randomMinutes =  Double(Int.random(in: 0 ..< 10)) * 60.0
                date = date + (30.0 * 60.0) + randomMinutes
                saveTimeStamp(Stamping(userID: userUID, timeStamp: date, subject: StampingSubject.BreakClockOut, isValid: true))
                
                randomMinutes =  Double(Int.random(in: 0 ..< 30)) * 60.0
                date = date + (3 * 60.0 * 60.0) + randomMinutes
                saveTimeStamp(Stamping(userID: userUID, timeStamp: date, subject: StampingSubject.ClockOut, isValid: true))
                
                date = date.startOfDay - (Double(i) * 60.0 * 60.0)
            }
        }
    }
    
    func previsionEndOfDay(workingDay: WorkingDayModel) -> String{
        if let stampingWorkingDayIN = workingDay.stampingWorkingDayIN {
            let endOfDay = stampingWorkingDayIN.timeStamp.addingTimeInterval(8.0 * 60.0 * 60.0)
            if let stampingBreakIN = workingDay.stampingBreakIN, let stampingBreakOUT = workingDay.stampingBreakOUT {
                return "The Working Day will finish at: \(endOfDay.addingTimeInterval(stampingBreakOUT.timeStamp.timeIntervalSince(stampingBreakIN.timeStamp)).formatHour())"
            }
            return "The Working Day will finish at: \(endOfDay.addingTimeInterval(Double( workingDay.breakMinutesSimulation * 60)).formatHour())"
        }
        return ""
    }
    
    func saveTimeStamp(_ timeStamp: Stamping){
        if let userUID = Auth.auth().currentUser?.uid{
            db.collection(K.FSStore.TimeStampCollectionName).addDocument(data: [
                K.FSStore.UserID: userUID,
                K.FSStore.TimeStamp: Timestamp(date: timeStamp.timeStamp),
                K.FSStore.Subject: "\(timeStamp.subject)",
                K.FSStore.IsValid: timeStamp.isValid
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
            let collection = db.collection(K.FSStore.TimeStampCollectionName)
                .whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: date.startOfDay)
                .whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay)
                .whereField(K.FSStore.UserID, isEqualTo: userUID)
                .whereField(K.FSStore.IsValid, isEqualTo: true).order(by: K.FSStore.TimeStamp, descending: false)
            
            collection.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                    self.delegate?.didFailWithError(error!)
                } else {
                    var workingDayModel: WorkingDayModel = WorkingDayModel( breakMinutesSimulation: 30)
                    if let snapshotDocuments = querySnapshot?.documents, snapshotDocuments.count > 0{
                        for data in snapshotDocuments {
                            if let dataTimeStamp = data[K.FSStore.TimeStamp], let dataSubject = data[K.FSStore.Subject]{
                                let timeStamp = (dataTimeStamp as! Timestamp).dateValue()
                                if let stampingSubject = StampingSubject(rawValue: (dataSubject as! String)){
                                    switch  stampingSubject{
                                    case StampingSubject.ClockIn:
                                        if workingDayModel.stampingWorkingDayIN == nil{
                                            workingDayModel.stampingWorkingDayIN = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.ClockIn, isValid: true)
                                        }else if  let modelDate = workingDayModel.stampingWorkingDayIN, modelDate.timeStamp > timeStamp {
                                            workingDayModel.stampingWorkingDayIN?.timeStamp = timeStamp
                                        }
                                    case StampingSubject.ClockOut:
                                        if workingDayModel.stampingWorkingDayOUT == nil{
                                            workingDayModel.stampingWorkingDayOUT = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.ClockOut, isValid: true)
                                        }else if  let modelDate = workingDayModel.stampingWorkingDayOUT, modelDate.timeStamp <= timeStamp {
                                            workingDayModel.stampingWorkingDayOUT?.timeStamp = timeStamp
                                        }
                                    case StampingSubject.BreakClockIn:
                                        if workingDayModel.stampingBreakIN == nil{
                                            workingDayModel.stampingBreakIN = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.BreakClockIn, isValid: true)
                                        }else if  let modelDate = workingDayModel.stampingBreakIN, modelDate.timeStamp > timeStamp {
                                            workingDayModel.stampingBreakIN?.timeStamp = timeStamp
                                        }
                                    case StampingSubject.BreakClockOut:
                                        if workingDayModel.stampingBreakOUT == nil{
                                            workingDayModel.stampingBreakOUT = Stamping(userID: "", timeStamp: timeStamp, subject: StampingSubject.BreakClockOut, isValid: true)
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
