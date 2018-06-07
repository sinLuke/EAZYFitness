//
//  TrainerMonthCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import MaterialComponents
class TrainerMonthCell: MDCCardCollectionCell {
    @IBOutlet weak var monthFinishedLabel: UILabel!
    @IBOutlet weak var totalCourse: UILabel!
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    @IBAction func goCourseRecord(_ sender: Any) {
    }
}
