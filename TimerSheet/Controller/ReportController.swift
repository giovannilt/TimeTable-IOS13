//
//  ReportController.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 21/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ReportController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reportLabel: UILabel!
    
    var reportManager = ReportManager()
    var workingDays: [WorkingDayModel] = []
    var arrIndexSection : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.setHidesBackButton(true, animated: false)
        reportManager.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        reportManager.loadWorkingDays(date: Date())
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        workingDays = []
        reportManager.loadWorkingDays(date: selectedDate)
    }
    @IBAction func reportButtonPressed(_ sender: UIButton) {
    }
}

//Mark: - UITableViewDataSource

extension ReportController: UITableViewDataSource{
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return arrIndexSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workingDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! WorkingDayCell
        
        if( workingDays.count >  indexPath.row){
            let workingDayModel = workingDays[indexPath.row]
            cell.dateLabel.text = workingDayModel.workingDayFormatted()
            cell.workedHoursLabel.text = workingDayModel.workedHours()
            cell.dailyFlexy.text = workingDayModel.dailyFlexy()
            cell.dailyPayedAdditionalWork.text = workingDayModel.dailyPayedAdditionalWork()
        }
        return cell
    }
}

//Mark: - queryToFireBase

extension ReportController: ReportManagerDelegate{
    func didLoadWorkingDays(_ reportManager: ReportManager, workingDays: [String : WorkingDayModel], weeks: [String]) {
        let sorted = workingDays.sorted( by:{$0.key > $1.key})
        self.workingDays = Array(sorted.map({$0.value}))
        self.arrIndexSection = weeks
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let indexPath = IndexPath(row: self.workingDays.count - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func didFailWithError(_ error: Error) {
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
