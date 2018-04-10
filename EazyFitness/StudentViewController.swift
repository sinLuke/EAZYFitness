//
//  StudentViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-03-22.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase

class StudentViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    var postView_y:CGFloat = 0
    let _MINIMUM_ADJEST_VALUE_ = 0.5
    let _MINIMUM_ACCEPT_VALUE_ = 0.5
    
    var studentInfo: NSDictionary?
    var MemberID: Int!
    var group = "" //4 inside nav
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var bugNumber: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var textlabel: UILabel!
    
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var monthTotal: UILabel!
    @IBOutlet weak var finished: UILabel!
    @IBOutlet weak var monthFinished: UILabel!

    @IBOutlet weak var reminderLabel: UILabel!
    
    var firstName = ""
    var lastName = ""
    var finishedCourseValue = 0.0
    var monthFinishedValue = 0.0
    var monthTotalValue = 0.0
    var TotalCourseValue = 0.0
    var totalRemainedValue = 0.0
    
    var reminderTextValue = ""
    
    //trainer
    @IBOutlet weak var reminderText: UITextField!
    @IBOutlet weak var trainer_label: UILabel!
    @IBOutlet weak var trainer_plusButton: UIButton!
    @IBOutlet weak var trainer_minusButton: UIButton!
    @IBOutlet weak var trainer_enterButton: UIButton!
    @IBOutlet weak var trainer_number: UILabel!
    lazy var value = _MINIMUM_ACCEPT_VALUE_
    
    //super
    @IBOutlet weak var super_delete: UIButton!
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        postView_y = self.view.frame.origin.y
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        // do whatever you want with this keyboard height
        
        self.view.frame.origin.y = postView_y - keyboardHeight + 100
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // keyboard is dismissed/hidden from the screen
        self.view.frame.origin.y = postView_y
    }
    
    override func viewDidLoad() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        if self.group == "Back"{
            self.backButton.isHidden = true
        } else {
            self.backButton.isHidden = false
        }
        super.viewDidLoad()
        ref = Database.database().reference()
        
        self.updateData()
        self.requireUpdate()
        
        
        //let numberValue = value?.value(forKey: "MemberID")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func trainer_updateCourseValue(){
        trainer_number.text = "\(self.value)"
        trainer_plusButton.isHidden = false
        trainer_minusButton.isHidden = false
        trainer_number.isHidden = false
        trainer_enterButton.isHidden = false
        trainer_label.text = "记录课时"
        if self.totalRemainedValue == 0 {
            trainer_plusButton.isHidden = true
            trainer_minusButton.isHidden = true
            trainer_number.isHidden = true
            trainer_enterButton.isHidden = true
            trainer_label.text = "无法记录"
            trainer_label.textColor = UIColor.red
            self.value = 0
        } else {
            if value + _MINIMUM_ADJEST_VALUE_ > self.totalRemainedValue{
                trainer_plusButton.isHidden = true
            }
            if value - _MINIMUM_ADJEST_VALUE_ <= 0{
                trainer_minusButton.isHidden = true
            }
            if value < _MINIMUM_ACCEPT_VALUE_{
                trainer_enterButton.isHidden = true
                trainer_label.text = "无法记录"
                requireUpdate()
            }
        }
        
    }
    @IBAction func editEnd(_ sender: Any) {
        reminderTextValue = self.reminderText.text!
        self.reminderText.text = "请稍候……"
        
        let reminderUpdates = ["/student/\(self.MemberID!)/Reminder": reminderTextValue]
        ref.updateChildValues(reminderUpdates)
        self.requireUpdate()
    }
    
    @IBAction func minus(_ sender: Any) {
        self.value -= _MINIMUM_ADJEST_VALUE_
        self.trainer_updateCourseValue()
    }
    
    @IBAction func plus(_ sender: Any) {
        self.value += _MINIMUM_ADJEST_VALUE_
        self.trainer_updateCourseValue()
    }
    
    
    @IBAction func enter(_ sender: Any) {
        let childUpdates = ["/student/\(self.MemberID!)/Finished Course": finishedCourseValue + value,
                            "/student/\(self.MemberID!)/Month Finished": monthFinishedValue + value]
        ref.updateChildValues(childUpdates) { (err, _) in
            if let error = err{
                self.trainer_label.text = "网络错误，修改尚未保存，请稍后再试！"
                self.trainer_label.textColor = UIColor.red
            }
            self.requireUpdate()
        }
        self.trainer_label.text = "请稍候……"
        self.trainer_enterButton.isHidden = true
        self.trainer_minusButton.isHidden = true
        self.trainer_plusButton.isHidden = true
        self.value = _MINIMUM_ACCEPT_VALUE_
        
    }
    func requireUpdate(){
        ref.child("student").child("\(MemberID!)").observeSingleEvent(of: .value) { (snapshot) in
            self.studentInfo = snapshot.value as? NSDictionary
            self.updateData()
        }
    }
    func updateData(){
        
        self.trainer_enterButton.isHidden = false
        firstName = studentInfo?.value(forKey: "First Name") as! String
        lastName = studentInfo?.value(forKey: "Last Name") as! String
        finishedCourseValue = studentInfo?.value(forKey: "Finished Course") as! Double
        monthFinishedValue = studentInfo?.value(forKey: "Month Finished") as! Double
        monthTotalValue = studentInfo?.value(forKey: "Month Total") as! Double
        TotalCourseValue = studentInfo?.value(forKey: "Total Course") as! Double
        reminderTextValue = (studentInfo?.value(forKey: "Reminder") ?? "") as! String
        
        reminderText.text = reminderTextValue
        reminderLabel.text = reminderTextValue
        
        totalRemainedValue = TotalCourseValue - finishedCourseValue
        self.trainer_updateCourseValue()
        if(totalRemainedValue<5){
            textlabel.text = "请及时续课"
            textlabel.textColor = UIColor.orange
        } else {
            textlabel.text = "余课充足"
            textlabel.textColor = UIColor.blue
        }
        
        bugNumber.text = "\(totalRemainedValue)"
        name.text = "\(firstName) \(lastName)"
        total.text = "总课时：\(TotalCourseValue)"
        monthTotal.text = "本月课时：\(monthTotalValue)"
        finished.text = "已完成：\(finishedCourseValue)"
        monthFinished.text = "本月已完成：\(monthFinishedValue)"
        
        switch self.group {
        case "trainer":
            trainer_label.isHidden = false
            trainer_plusButton.isHidden = false
            trainer_minusButton.isHidden = false
            trainer_enterButton.isHidden = false
            trainer_number.isHidden = false
            super_delete.isHidden = true
            reminderText.isHidden = true
            reminderLabel.isHidden = true
        case "super", "mississauga", "scarbrough", "waterloo":
            trainer_label.isHidden = false
            trainer_plusButton.isHidden = false
            trainer_minusButton.isHidden = false
            trainer_enterButton.isHidden = false
            trainer_number.isHidden = false
            super_delete.isHidden = false
            reminderText.isHidden = true
            reminderLabel.isHidden = true
        case "Back":
            trainer_label.isHidden = true
            trainer_plusButton.isHidden = true
            trainer_minusButton.isHidden = true
            trainer_enterButton.isHidden = true
            trainer_number.isHidden = true
            super_delete.isHidden = true
            reminderText.isHidden = false
            reminderLabel.isHidden = true
        default:
            trainer_label.isHidden = true
            trainer_plusButton.isHidden = true
            trainer_minusButton.isHidden = true
            trainer_enterButton.isHidden = true
            trainer_number.isHidden = true
            super_delete.isHidden = true
            reminderText.isHidden = true
            reminderLabel.isHidden = false
        }
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        reminderText.resignFirstResponder()
        self.view.frame.origin.y = postView_y
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
