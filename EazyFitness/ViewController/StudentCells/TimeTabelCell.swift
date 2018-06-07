//
//  TimeTabelCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class TimeTabelCell: MDCCardCollectionCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var report: UIButton!
    @IBOutlet weak var requirChangeBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    var thisStudentCourseRef:DocumentReference!
    
    @IBAction func requirChangeTime(_ sender: Any) {
    }

    @IBAction func goTimeTabel(_ sender: Any) {
    }
    
    @IBAction func report(_ sender: Any) {
        //教练没来
        self.thisStudentCourseRef.updateData(["status" : enumService.toString(e: .noTrainer)])
        AppDelegate.showError(title: "记录成功", err: "已成功记录教练为没来")
    }
}
