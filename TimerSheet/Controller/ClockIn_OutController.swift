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
    
    var workingDayModel: WorkingDayModel = WorkingDayModel.init(hasClockedInWorkingDay: false, clockInWorkginDay: 0.0, clockOutWorkingDay: 0.0, hasClockedInBreak: false, clockInBreak: 0.0, clockOutBreak: 0.0)
    let db = Firestore.firestore()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        retiveDailyClockInTimeStamp()
        retiveBreakClockInTimeStamp()
        
    }
    @IBAction func clockWorkingDayButtonPressed(_ sender: UIButton) {
        
        if let userUID = Auth.auth().currentUser?.uid{
            if workingDayModel.hasClockedInWorkingDay == false{
                workingDayModel.hasClockedInWorkingDay = true
                workingDayModel.clockInWorkginDay = Date().timeIntervalSince1970
                workingDayModel.clockOutWorkingDay = 0.0
                
                db.collection(K.FSStore.TimeStampCollectionName).addDocument(data: [
                    K.FSStore.UserID: userUID,
                    K.FSStore.TimeStamp: workingDayModel.clockInWorkginDay,
                    K.FSStore.Subject: StampingSubject.ClockIn
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
                workingDayModel.clockOutWorkingDay = Date().timeIntervalSince1970
                db.collection(K.FSStore.TimeStampCollectionName).addDocument(data: [
                    K.FSStore.UserID: userUID,
                    K.FSStore.TimeStamp: workingDayModel.clockInWorkginDay,
                    K.FSStore.Subject: StampingSubject.ClockOut
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
    @IBAction func clockBreakButtonPressed(_ sender: UIButton) {
    
    }
}

//Mark: - NavigationBar

extension ClockIn_OutController{
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
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
    
    func retiveDailyClockInTimeStamp(){
        let date = Date()
        if let userUID = Auth.auth().currentUser?.uid{
            let collection = db.collection(K.FSStore.TimeStampCollectionName
                            ).whereField(K.FSStore.TimeStamp, isGreaterThanOrEqualTo: date.startOfDay
                            ).whereField(K.FSStore.TimeStamp, isLessThan: date.endOfDay
                            ).whereField(K.FSStore.UserID, isEqualTo: userUID
                            ).whereField(K.FSStore.Subject, isEqualTo: StampingSubject.ClockIn
                            ).order(by: K.FSStore.TimeStamp)
            
                collection.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents{
                        let data = snapshotDocuments[0].data()
                        if let timeStamping = data[K.FSStore.TimeStamp] {
                            print(timeStamping)
                            self.workingDayModel.hasClockedInWorkingDay = true
                            self.workingDayModel.clockInWorkginDay = timeStamping as! Double
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
                            ).whereField(K.FSStore.Subject, isEqualTo: StampingSubject.LunchBreakClockIn)
                            .order(by: K.FSStore.TimeStamp)
                
                collection.getDocuments() { (querySnapshot, error) in
                if let e = error {
                    print("There was a issue retrieving data from Firestore: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents{
                        let data = snapshotDocuments[0].data()
                        if let timeStamping = data[K.FSStore.TimeStamp] {
                            print(timeStamping)
                            self.workingDayModel.hasClockedInBreak = true
                            self.workingDayModel.clockInBreak = timeStamping as! Double
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

