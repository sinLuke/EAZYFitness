//
//  TimeTabelCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class TimeTabelCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var report: UIButton!
    @IBOutlet weak var requirChangeBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var thisCourseRef:DocumentReference!
    
    @IBAction func requirChangeTime(_ sender: Any) {
    }

    @IBAction func goTimeTabel(_ sender: Any) {
    }
    
    @IBAction func report(_ sender: Any) {
        //教练没来
        thisCourseRef.getDocument { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "记录异常时发生错误", err: err.localizedDescription)
            } else{
                if let datadic = snap?.data(){
                    if (datadic["Record"] as? Bool) == false{
                        self.thisCourseRef.updateData(["notrainer" : true])
                        self.thisCourseRef.updateData(["nostudent" : false])
                        AppDelegate.showError(title: "记录完成", err: "已记录为教练未按时到达")
                    } else {
                        AppDelegate.showError(title: "无法记录", err: "该课程已经被记录")
                    }
                }
            }
        }
        
    }
}
