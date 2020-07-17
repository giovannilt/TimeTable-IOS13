//
//  TimeSheetController.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 13/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ClockIn_OutController: UIViewController{
    
    @IBOutlet weak var clockWorkingDayButton: UIButton!
    @IBOutlet weak var clockInWorkginDayLabel: UILabel!
    @IBOutlet weak var clockOutWorkingDayLabel: UILabel!
    
    @IBOutlet weak var clockBreakButton: UIButton!
    @IBOutlet weak var clockInBreakLabel: UILabel!
    @IBOutlet weak var clockOutBreakLabel: UILabel!
    
    var workingDayModel: WorkingDayModel = WorkingDayModel.init(hasClockedInWorkingDay: false, clockInWorkginDay: nil, clockOutWorkingDay: nil,
                                                                hasClockedInBreak: false, clockInBreak: nil,      clockOutBreak: nil)
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        updateClockInOutView()
        retiveDailyClockInTimeStamp()
        retiveBreakClockInTimeStamp()
    }
}

extension ClockIn_OutController {
    @IBAction func LogOutButtonPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func updateClockInOutView(){
        self.clockWorkingDayButton.setTitle(workingDayModel.clockWorkingDayInOutStatus(), for: .normal)
        clockInWorkginDayLabel.text = workingDayModel.clockInWorkginDayFormatted()
        clockOutWorkingDayLabel.text = workingDayModel.clockOutWorkginDayFormatted()
        clockBreakButton.setTitle(workingDayModel.clockBreakInOutStatus(), for: .normal)
        clockInBreakLabel.text = workingDayModel.clockInBreakFormatted()
        clockOutBreakLabel.text = workingDayModel.clockOutBreakFormatted()
    }
}
//Mark: - queryToFireBase

extension ClockIn_OutController{
    
    @IBAction func clockBreakButtonPressed(_ sender: UIButton) {
        if let userUID = Auth.auth().currentUser?.uid{
            if workingDayModel.hasClockedInBreak == false{
                workingDayModel.hasClockedInBreak = true
                workingDayModel.clockInBreak = Date()
                workingDayModel.clockOutBreak = nil
                
                db.collection(K.FSStore.TimeStampCollectionName).addDocument(data: [
                    K.FSStore.UserID: userUID,
                    K.FSStore.TimeStamp: Timestamp(date: workingDayModel.clockInBreak!),
                    K.FSStore.Subject: "\(StampingSubject.LunchBreakClockIn)"
                ]) { (error) in
                    if let e = error{
                        print("Errore nel salvare in firestore \(e)")
                    }else{
                        DispatchQueue.main.async {
                            self.updateClockInOutView()
                        }
                        print("Salvato Clock IN Lunch")
                    }
                }
            }else{
                workingDayModel.hasClockedInBreak = false
                workingDayModel.clockOutBreak = Date()
                db.collection(K.FSStore.TimeStampCollectionName).addDocument(data: [
                    K.FSStore.UserID: userUID,
                    K.FSStore.TimeStamp: Timestamp(date: workingDayModel.clockOutBreak!),
                    K.FSStore.Subject: "\(StampingSubject.LunchBreakClockOut)"
                ]) { (error) in
                    if let e = error{
                        print("Errore nel salvare in firestore \(e)")
                    }else{
                        DispatchQueue.main.async {
                            self.updateClockInOutView()
                        }
                        print("Salvato Clock OUT Lunch")
                    }
                }
            }
        }
    }
    
    @IBAction func clockWorkingDayButtonPressed(_ sender: UIButton) {
        if let userUID = Auth.auth().currentUser?.uid{
            if workingDayModel.hasClockedInWorkingDay == false{
                workingDayModel.hasClockedInWorkingDay = true
                workingDayModel.clockInWorkginDay = Date()
                workingDayModel.clockOutWorkingDay = nil
                
                db.collection(K.FSStore.TimeStampCollectionName).addDocument(data: [
                    K.FSStore.UserID: userUID,
                    K.FSStore.TimeStamp: Timestamp(date: workingDayModel.clockInWorkginDay!),
                    K.FSStore.Subject: "\(StampingSubject.ClockIn)"
                ]) { (error) in
                    if let e = error{
                        print("Errore nel salvare in firestore \(e)")
                    }else{
                        DispatchQueue.main.async {
                            self.updateClockInOutView()
                        }
                        print("Salvato Clock IN")
                    }
                }
            }else{
                workingDayModel.hasClockedInWorkingDay = false
                workingDayModel.clockOutWorkingDay = Date()
                db.collection(K.FSStore.TimeStampCollectionName).addDocument(data: [
                    K.FSStore.UserID: userUID,
                    K.FSStore.TimeStamp: Timestamp(date: workingDayModel.clockInWorkginDay!),
                    K.FSStore.Subject: "\(StampingSubject.ClockOut)"
                ]) { (error) in
                    if let e = error{
                        print("Errore nel salvare in firestore \(e)")
                    }else{
                        DispatchQueue.main.async {
                            self.updateClockInOutView()
                        }
                        print("Salvato Clock OUT")
                    }
                }
            }
        }
    }
    
    func retiveDailyClockInTimeStamp(){
        let date = Date()
        print(date.startOfDay)
        print(date.endOfDay)
        if let userUID = Auth.auth().currentUser?.uid{
            let collection = db.collection(K.FSStore.TimeStampCollectionName
            ).whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: date.startOfDay
            ).whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay
            ).whereField(K.FSStore.UserID, isEqualTo: userUID
            ).whereField(K.FSStore.Subject, isEqualTo: "\(StampingSubject.ClockIn)"
            ).order(by: K.FSStore.TimeStamp, descending: false)
            
            collection.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents, snapshotDocuments.count > 0{
                        let data = snapshotDocuments[0].data()
                        if let timeStamping = data[K.FSStore.TimeStamp] {
                            print(timeStamping)
                            self.workingDayModel.hasClockedInWorkingDay = true
                            self.workingDayModel.clockInWorkginDay =  (timeStamping as! Timestamp).dateValue()
                        }
                        DispatchQueue.main.async {
                            self.updateClockInOutView()
                        }
                    }
                }
            }
            
            let collectionOut = db.collection(K.FSStore.TimeStampCollectionName
            ).whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: date.startOfDay
            ).whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay
            ).whereField(K.FSStore.UserID, isEqualTo: userUID
            ).whereField(K.FSStore.Subject, isEqualTo: "\(StampingSubject.ClockOut)"
            ).order(by: K.FSStore.TimeStamp, descending: true)
            
            collectionOut.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents, snapshotDocuments.count > 0{
                        let data = snapshotDocuments[0].data()
                        if let timeStamping = data[K.FSStore.TimeStamp] {
                            print(timeStamping)
                            self.workingDayModel.clockOutWorkingDay =  (timeStamping as! Timestamp).dateValue()
                        }
                        DispatchQueue.main.async {
                            self.updateClockInOutView()
                        }
                    }
                }
            }
            
        }
    }
    
    func retiveBreakClockInTimeStamp(){
        let date = Date()
        if let userUID = Auth.auth().currentUser?.uid{
            let collection = db.collection(K.FSStore.TimeStampCollectionName
            ).whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: date.startOfDay
            ).whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay
            ).whereField(K.FSStore.UserID, isEqualTo: userUID
            ).whereField(K.FSStore.Subject, isEqualTo: "\(StampingSubject.LunchBreakClockIn)"
            ).order(by: K.FSStore.TimeStamp, descending: false)
            
            collection.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents, snapshotDocuments.count > 0{
                        let data = snapshotDocuments[0].data()
                        if let timeStamping = data[K.FSStore.TimeStamp] {
                            print(timeStamping)
                            self.workingDayModel.hasClockedInBreak = true
                            self.workingDayModel.clockInBreak = (timeStamping as! Timestamp).dateValue()
                        }
                        DispatchQueue.main.async {
                            self.updateClockInOutView()
                        }
                    }
                }
            }
            let collectionOut = db.collection(K.FSStore.TimeStampCollectionName
            ).whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: date.startOfDay
            ).whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay
            ).whereField(K.FSStore.UserID, isEqualTo: userUID
            ).whereField(K.FSStore.Subject, isEqualTo: "\(StampingSubject.LunchBreakClockOut)"
            ).order(by: K.FSStore.TimeStamp, descending: true)
            
            collectionOut.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents, snapshotDocuments.count > 0{
                        let data = snapshotDocuments[0].data()
                        if let timeStamping = data[K.FSStore.TimeStamp] {
                            print(timeStamping)
                            self.workingDayModel.clockOutBreak = (timeStamping as! Timestamp).dateValue()
                        }
                        DispatchQueue.main.async {
                            self.updateClockInOutView()
                        }
                    }
                }
            }
            
        }
    }
}

