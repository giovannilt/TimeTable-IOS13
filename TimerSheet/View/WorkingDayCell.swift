//
//  WorkingDayCell.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 21/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import UIKit

class WorkingDayCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var workedHoursLabel: UILabel!
    @IBOutlet weak var dailyFlexy: UILabel!
    @IBOutlet weak var dailyPayedAdditionalWork: UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           
//           dailyResumeLabel.layer.cornerRadius = dailyResumeLabel.frame.size.height / 2
//
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
       }
}
