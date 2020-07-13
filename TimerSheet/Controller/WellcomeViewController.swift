//
//  ViewController.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 13/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import UIKit
import CLTypingLabel

class WellcomeViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = K.appName
    }


}

