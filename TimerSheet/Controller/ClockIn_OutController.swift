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
    
    let userDefault = UserDefaults.standard
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var clockInWorkingDayButton: UIButton!
    @IBOutlet weak var clockOutWorkginDayButton: UIButton!
    @IBOutlet weak var clockInWorkginDayLabel: UILabel!
    @IBOutlet weak var clockOutWorkingDayLabel: UILabel!
    
    @IBOutlet weak var clockInBreakButton: UIButton!
    @IBOutlet weak var clockOutBreakButton: UIButton!
    @IBOutlet weak var clockInBreakLabel: UILabel!
    @IBOutlet weak var clockOutBreakLabel: UILabel!
    @IBOutlet weak var breakTimeLabel: UITextField!
    @IBOutlet weak var previsionLabel: UILabel!
    
    @IBOutlet weak var breakStepper: UIStepper!
    
    @IBOutlet weak var workedHours: UILabel!
    
    var workingDayManager = WorkingDayManager()
    
    let db = Firestore.firestore()
    var workingDay =  WorkingDayModel(breakMinutesSimulation: 30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        workingDayManager.delegate = self
        clockInWorkingDayButton.setTitle("\(StampingSubject.ClockIn)", for: .normal)
        clockOutWorkginDayButton.setTitle("\(StampingSubject.ClockOut)", for: .normal)
        clockInBreakButton.setTitle("\(StampingSubject.BreakClockIn)", for: .normal)
        clockOutBreakButton.setTitle("\(StampingSubject.BreakClockOut)", for: .normal)
        dayLabel.text = Date().formatToday()
        workingDayManager.retiveDailyTimeStamps()
        workedHours.text = "-"
        
        previsionLabel.text = workingDayManager.previsionEndOfDay(workingDay: workingDay)
    }
    @IBAction func breakTimerStepperPressed(_ sender: UIStepper) {
        workingDay.breakMinutesSimulation = Int(sender.value)
        previsionLabel.text = workingDayManager.previsionEndOfDay(workingDay: workingDay)
        breakTimeLabel.text = "\(workingDay.breakMinutesSimulation)"
    }
    
    
    
}

extension ClockIn_OutController {
    @IBAction func LogOutButtonPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.userDefault.set(false, forKey: "usersignedin")
            self.userDefault.synchronize()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func clockButtonPressed(_ sender: UIButton) {
        if let userUID = Auth.auth().currentUser?.uid, let buttonTitle = sender.currentTitle{
            let subject = StampingSubject(rawValue: buttonTitle)
            if let subject = subject{
                let timeStamp = Stamping(userID: userUID, timeStamp: Date(), subject: subject, isValid: true)
                workingDayManager.saveTimeStamp(timeStamp)
                if subject == StampingSubject.BreakClockOut{
                    breakStepper.isEnabled = false
                }
            }
        }
    }
    
    func updateClockInOutView(_ workingDay: WorkingDayModel){
        clockInWorkingDayButton.isEnabled = !workingDay.hasClockedInWorkingDay()
        clockOutWorkginDayButton.isEnabled = !workingDay.hasClockedOutWorkingDay()
        clockInWorkginDayLabel.text = workingDay.clockInWorkginDayFormatted()
        clockOutWorkingDayLabel.text = workingDay.clockOutWorkginDayFormatted()
        clockInBreakButton.isEnabled = !workingDay.hasClockedInBreak()
        clockOutBreakButton.isEnabled = !workingDay.hasClockedOutBreak()
        clockInBreakLabel.text = workingDay.clockInBreakFormatted()
        clockOutBreakLabel.text = workingDay.clockOutBreakFormatted()
        breakTimeLabel.text = "\(workingDay.breakMinutesSimulation)"
        previsionLabel.text = workingDayManager.previsionEndOfDay(workingDay: workingDay)
        if workingDay.stampingBreakOUT == nil{
            breakStepper.isEnabled = true
        }
        breakStepper.value = Double(workingDay.breakMinutesSimulation)
        workedHours.text = "Working time: \(workingDay.workingDayFormatted())"
    }
    @IBAction func cleanButtonPressed(_ sender: UIButton) {
        workingDayManager.cleanCurrentDay(workingDay: workingDay)
    }
    
    @IBAction func IdealDay(_ sender: UIButton) {
        workingDayManager.idealDay(workingDay: workingDay)
    }
    
    @IBAction func add30DaysCasual(_ sender: UIButton) {
        workingDayManager.generateOneMonts()
    }
}


//Mark: - queryToFireBase
extension ClockIn_OutController: WorkingDayManagerDelegate{
    func diddDeleteDay(_ workingDayManager: WorkingDayManager, workingDay: WorkingDayModel) {
        self.workingDay = workingDay
        DispatchQueue.main.async {
            self.updateClockInOutView(self.workingDay)
        }
    }
    
    func didSaveStamp(_ workingDayManager: WorkingDayManager, timeStamp: Stamping ) {
        self.workingDay.setStamping(timeStamp)
        DispatchQueue.main.async {
            self.updateClockInOutView(self.workingDay)
        }
    }
    
    func didUpdateWorkingDay(_ workingDayManager: WorkingDayManager, workingDay: WorkingDayModel) {
        DispatchQueue.main.async {
            self.workingDay = workingDay
            self.updateClockInOutView(self.workingDay)
        }
    }
    
    func didFailWithError(_ error: Error) {
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

