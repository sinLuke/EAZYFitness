//
//  StudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/24.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class StudentVC: DefaultViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var studentInfo: NSDictionary?
    var MemberID: Int!
    var ref: DatabaseReference!

    
    @IBOutlet weak var studentName: UILabel!
    
    
    @IBOutlet weak var cLeftBoard: UIView!
    @IBOutlet weak var cLeftLabel: UILabel!
    @IBOutlet weak var cLeftNum: UILabel!
    
    
    @IBOutlet weak var totalBoard: UIView!
    @IBOutlet weak var totalCourse: UILabel!
    @IBOutlet weak var totalFinish: UILabel!
    @IBOutlet weak var monthCourse: UILabel!
    @IBOutlet weak var monthFinish: UILabel!
    
    var firstName = ""
    var lastName = ""
    var finishedCourseValue = 0.0
    var monthFinishedValue = 0.0
    var monthTotalValue = 0.0
    var TotalCourseValue = 0.0
    var totalRemainedValue = 0.0
    
    func requireUpdate(){
        ref.child("student").child("\(MemberID!)").observeSingleEvent(of: .value) { (snapshot) in
            self.studentInfo = snapshot.value as? NSDictionary
            self.updateData()
        }
    }
    
    func updateData(){
        
        firstName = studentInfo?.value(forKey: "First Name") as! String
        lastName = studentInfo?.value(forKey: "Last Name") as! String
        finishedCourseValue = studentInfo?.value(forKey: "Finished Course") as! Double
        monthFinishedValue = studentInfo?.value(forKey: "Month Finished") as! Double
        monthTotalValue = studentInfo?.value(forKey: "Month Total") as! Double
        TotalCourseValue = studentInfo?.value(forKey: "Total Course") as! Double
        
        totalRemainedValue = TotalCourseValue - finishedCourseValue
        
        if(totalRemainedValue<5){
            cLeftLabel.text = "请及时续课"
            cLeftLabel.textColor = UIColor.orange
        } else {
            cLeftLabel.text = "余课充足"
            cLeftLabel.textColor = UIColor.blue
        }
        
        cLeftNum.text = "\(totalRemainedValue)"
        studentName.text = "\(firstName) \(lastName)"
        totalCourse.text = "总课时：\(TotalCourseValue)"
        monthCourse.text = "本月课时：\(monthTotalValue)"
        totalFinish.text = "已完成：\(finishedCourseValue)"
        monthFinish.text = "本月已完成：\(monthFinishedValue)"
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
