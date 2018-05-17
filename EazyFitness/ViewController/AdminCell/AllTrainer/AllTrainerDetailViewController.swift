//
//  AllTrainerDetailViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class AllTrainerDetailViewController: DefaultViewController, UITextFieldDelegate {

    var thisTrainer:EFTrainer!
    var titleName:String!
    
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var goalField: UITextField!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var registered: UISegmentedControl!
    @IBOutlet weak var region: UISegmentedControl!
    
    @IBOutlet weak var btnManager: UIButton!
    var _gesture:UIGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLoading()
        self.title = titleName
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        self.region.isEnabled = false
        
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
        self.doneInput()
    }
    
    @IBAction func manageTrainer(_ sender: Any) {
        self.uploadData()
        if goalField.text == ""{
            goalField.text = "30"
        }
        if self.fname.text == "" || self.lname.text == ""{
            AppDelegate.showError(title: "不允许姓名为空", err: "必须填写姓名")
        } else {
            performSegue(withIdentifier: "manage", sender: self)
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
            self.startLoading()
            self.uploadData()
            thisTrainer.upload()
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            AppDelegate.showError(title: "上传出现错误", err: "必须填写姓名")
        }
    }
    
    func uploadData(){
        thisTrainer.firstName = self.fname.text!
        thisTrainer.lastName = self.lname.text!
        thisTrainer.goal = Int(goalField.text!)!
        thisTrainer.registered = enumService.toUserStatus(i: self.registered.selectedSegmentIndex)
        thisTrainer.region = enumService.Region[self.region.selectedSegmentIndex]
        self.title = thisTrainer.name
    }
    
    override func refresh() {
        thisTrainer.download()
        self.region.removeAllSegments()
        for i in 0...enumService.RegionName.count-1{
            self.region.insertSegment(withTitle: enumService.RegionName[i], at: i, animated: false)
        }
        self.region.selectedSegmentIndex = enumService.toInt(e: thisTrainer.region)
    }
    
    override func reload() {
        if let intMemberID = Int(thisTrainer.memberID){
            idLabel.text = String(format:"%04d", intMemberID)
        }
        self.fname.text = thisTrainer.firstName
        self.lname.text = thisTrainer.lastName
        self.goalField.text = String(thisTrainer.goal)
        self.region.selectedSegmentIndex = enumService.toInt(e: thisTrainer.region)
        self.registered.selectedSegmentIndex = enumService.toInt(i: thisTrainer.registered)
        self.endLoading()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? AllTrainerStudentTableViewController{
            dvc.title = "\(self.title!) 的学生"
            dvc.thisTrainer = self.thisTrainer
            
        }
    }
}
