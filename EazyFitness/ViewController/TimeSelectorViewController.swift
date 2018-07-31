//
//  TimeSelectorViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-07-28.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class TimeSelectorViewController: UIViewController {
    
    
    var thisCourse: EFCourse!
    var TimeDate: Date!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeDetailLabel: UILabel!
    @IBOutlet weak var timeSelector: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeSelector.minimumDate = Date()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishBtn(_ sender: Any) {
        
        for traineeStudentCourseRef in self.thisCourse.traineeStudentCourseRef {
            traineeStudentCourseRef.updateData(["status":enumService.toString(e: courseStatus.waitForStudent)])
            
        }
        let oldtime = self.thisCourse.date
        self.thisCourse.date = self.TimeDate
        for trainee in self.thisCourse.traineeRef {
            trainee.getDocument { (snap, err) in
                if let snap = snap {
                    if let uid = snap.data()?["uid"] as? String{
                        AppDelegate.SandNotification(to: uid, with: "\(oldtime.descriptDate())的课程已更改为\(self.TimeDate.descriptDate())", and: nil)
                        
                    }
                }
            }
        }
        
        if let TimeDate = self.TimeDate, let ref = self.thisCourse?.ref {
            ref.updateData(["date" : TimeDate]) { (err) in
                if let err = err {
                    AppDelegate.showError(title: "更该课程时间时发生错误", err: err.localizedDescription)
                } else {
                    AppDelegate.showWarning(title: "时间修改成功", err: nil)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
