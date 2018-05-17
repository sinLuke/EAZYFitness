//
//  AllStudentDetailViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class AllStudentDetailViewController: DefaultViewController, UITextFieldDelegate {

    var ref:DocumentReference!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var registered: UISegmentedControl!
    @IBOutlet weak var region: UISegmentedControl!
    @IBOutlet weak var number: UILabel!
    
    @IBOutlet weak var purchaseBtn: UIButton!
    @IBOutlet weak var courseBtn: UIButton!
    
    var _gesture:UIGestureRecognizer!
    
    var Fname: String = ""
    var Lname: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLoading()
        idLabel.text = ref.documentID
        
        self.region.isEnabled = false
        
        if let region = AppDelegate.AP().region{
            let i = enumService.toInt(e: region)
            self.region.selectedSegmentIndex = i
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
    }
    
    @IBAction func donebtn(_ sender: Any) {
        self.doneInput()
    }
    func doneInput(){
        self.fname.endEditing(true)
        self.lname.endEditing(true)
        if self.fname.text != "" && self.lname.text != ""{
            
        } else {
            AppDelegate.showError(title: "上传出现错误", err: "必须填写姓名")
        }
        
    }
    
    
    override func refresh() {
        ref.getDocument { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "获取信息时发生错误", err: err.localizedDescription)
            } else {
                if let docData = snap?.data(){
                    self.Fname = docData["First Name"] as! String
                    self.Lname = docData["Last Name"] as! String
                    self.idLabel.text = snap?.documentID
                    self.registered.selectedSegmentIndex = (docData["Registered"] as! Int) % 3
                    let region = enumService.toRegion(s: docData["region"] as! String)
                    self.region.selectedSegmentIndex = enumService.toInt(e: region)
                    self.title = "\(self.Fname) \(self.Lname)"
                    self.purchaseBtn.isHidden = false
                    self.courseBtn.isHidden = false
                } else {
                    self.title = "创建新的记录"
                    self.purchaseBtn.isHidden = true
                    self.courseBtn.isHidden = true
                }
                self.reload()
            }
        }
    }
    override func reload() {

        self.fname.text = self.Fname
        self.lname.text = self.Lname
        self.fname.text = self.Fname
        self.endLoading()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? AllStudentCourseTableViewController{
            dvc.ref = self.ref.collection("CourseRecorded")
            dvc.title = "\(self.title!) 的课程"
        }
        if let dvc = segue.destination as? PurchaseTableViewController{
            dvc.ref = self.ref.collection("CourseRegistered")
            dvc.studentName = self.title
        }
    }

}
