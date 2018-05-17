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

    var ref:DocumentReference!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var registered: UISegmentedControl!
    @IBOutlet weak var region: UISegmentedControl!
    @IBOutlet weak var number: UILabel!
    
    @IBOutlet weak var btnManager: UIButton!
    var _gesture:UIGestureRecognizer!
    
    var Fname: String = ""
    var Lname: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLoading()
        idLabel.text = String(format:"%04d", Int(ref.documentID)!)
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
    
    @IBAction func manageTrainer(_ sender: Any) {
    }
    
    func doneInput(){
        self.fname.endEditing(true)
        self.lname.endEditing(true)
        if self.fname.text != "" && self.lname.text != ""{
            self.startLoading()
            ref.setData(["First Name" : self.fname.text!, "Last Name" : self.lname.text!, "Registered": self.registered.selectedSegmentIndex, "region": enumService.RegionString[self.region.selectedSegmentIndex], "usergroup":"trainer", "MemberID":ref.documentID]) { (err) in
                if let err = err{
                    AppDelegate.showError(title: "上传出现错误", err: err.localizedDescription)
                    self.endLoading()
                } else {
                    AppDelegate.showError(title: "创建成功", err: "已成功修改记录", of: self)
                    self.refresh()
                }
            }
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
                    self.btnManager.isHidden = false
                } else {
                    self.title = "创建新的记录"
                    self.btnManager.isHidden = true
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
        if let dvc = segue.destination as? AllTrainerStudentTableViewController{
            dvc.navigationItem.title = "\(self.title!) 的学生"
            dvc.ref = self.ref.collection("trainee")
        }
    }
}
