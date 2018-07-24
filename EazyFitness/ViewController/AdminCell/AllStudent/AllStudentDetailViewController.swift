//
//  AllStudentDetailViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents
class AllStudentDetailViewController: DefaultViewController, UITextFieldDelegate {

    var thisStudent:EFStudent?
    var titleName:String!
    
    var newStudentIDReady: Int!
    var newStudentRegion: userRegion = .Mississauga
    
    @IBOutlet weak var fname: MDCTextField!
    @IBOutlet weak var lname: MDCTextField!
    
    var new = false
    
    var idLabelString: String!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var registered: UISegmentedControl!
    @IBOutlet weak var region: UISegmentedControl!
    
    @IBOutlet weak var goalField: MDCTextField!
    
    @IBOutlet weak var purchaseBtn: UIButton!
    @IBOutlet weak var courseBtn: UIButton!
    
    var _gesture:UIGestureRecognizer!
    
    override func viewDidAppear(_ animated: Bool) {
        //AppDelegate.showError(title: "该学生不存在", err: "请返回上一页", handler: self.goBack)
    }
    
    func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleName
        
        self.region.isEnabled = false
        idLabel.text = idLabelString ?? ""
        if let region = AppDelegate.AP().ds?.region{
            if region == userRegion.All{
                self.region.selectedSegmentIndex = 0
                self.region.isEnabled = true
            } else {
                let i = enumService.toInt(e: region)
                self.region.selectedSegmentIndex = i
                self.region.isEnabled = false
            }
        } else {
            AppDelegate.showError(title: "无法确定用户组", err: "请重新登录", handler:AppDelegate.AP().signout)
        }
        
        self._gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(_gesture)
        self.refresh()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        self.fname.endEditing(true)
        self.lname.endEditing(true)
        self.goalField.endEditing(true)
    }
    
    @IBAction func donebtn(_ sender: Any) {
        if thisStudent != nil{
            self.doneInput()
        } else {
            if let newID = self.newStudentIDReady{
                self.thisStudent = EFStudent.addStudent(at: "\(newID)", in: self.newStudentRegion)
                self.thisStudent?.memberID = "\(newID)"
                self.doneInput()
            }
        }
    }
    
    func doneInput(){
        self.fname.endEditing(true)
        self.lname.endEditing(true)
        self.goalField.endEditing(true)
        if goalField.text == ""{
            goalField.text = "30"
        }
        if self.fname.text != "" && self.lname.text != "" && goalField.text != "" {

            ActivityViewController.shared?.activityLabelString = "AllStudentDetailViewController"
            self.uploadData()
            thisStudent?.upload(handler: {
                _ = self.navigationController?.popViewController(animated: true)
            })
        } else {
            AppDelegate.showError(title: "上传出现错误", err: "必须填写姓名")
        }
    }
    
    func uploadData(){
        if let thisStudent = thisStudent {
            thisStudent.firstName = self.fname.text!
            thisStudent.lastName = self.lname.text!
            thisStudent.goal = Int(goalField.text!)!
            thisStudent.registered = enumService.toUserStatus(i: self.registered.selectedSegmentIndex)
            thisStudent.region = enumService.Region[self.region.selectedSegmentIndex]
            thisStudent.ready = true
            self.new = false
            self.title = thisStudent.name
            self.reload()
        }
    }
    
    
    override func refresh() {
        //thisStudent?.download()
        self.region.removeAllSegments()
        for i in 0...enumService.RegionName.count-1{
            self.region.insertSegment(withTitle: enumService.RegionName[i], at: i, animated: false)
        }
        self.region.selectedSegmentIndex = enumService.toInt(e: thisStudent?.region ?? .Mississauga)
        reload()
    }
    override func reload() {
        if let thisStudent = thisStudent {
            if let intMemberID = Int(thisStudent.memberID){
                idLabel.text = String(format:"%04d", intMemberID)
            }
            self.fname.text = thisStudent.firstName
            self.lname.text = thisStudent.lastName
            self.goalField.text = String(thisStudent.goal)
            self.region.selectedSegmentIndex = enumService.toInt(e: thisStudent.region)
            self.registered.selectedSegmentIndex = enumService.toInt(i: thisStudent.registered)
        }
        
        if new {
            purchaseBtn.isHidden = true
            courseBtn.isHidden = true
        } else {
            purchaseBtn.isHidden = false
            courseBtn.isHidden = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? CourseTableViewController{
            dvc.thisStudentOrTrainer = self.thisStudent
            if let thisStudent = thisStudent {
                dvc.title = "\(thisStudent.name) 的课程"
            } else {
                dvc.title = "unknown 的课程"
            }
        }
        if let dvc = segue.destination as? PurchaseTableViewController{
            dvc.thisStudent = self.thisStudent
            dvc.title = self.title
        }
    }
}
