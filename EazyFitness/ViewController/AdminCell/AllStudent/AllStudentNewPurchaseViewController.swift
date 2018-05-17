//
//  AllStudentNewPurchaseViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class AllStudentNewPurchaseViewController: DefaultViewController {

    @IBOutlet weak var courseTime: UITextField!
    var studentName:String!
    var _gesture:UIGestureRecognizer!
    @IBOutlet weak var plusOrMinus: UISegmentedControl!
    @IBOutlet weak var Note: UITextField!
    
    var thisStudent:EFStudent!
    override func viewDidLoad() {
        super.viewDidLoad()
        self._gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.title = "为\(studentName!)加课"
        // Do any additional setup after loading the view.
    }

    @objc func dismissKeyboard(){
        self.courseTime.endEditing(true)
        self.Note.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(_ sender: Any) {
        if self.plusOrMinus.selectedSegmentIndex == 1 && Note.text == ""{
            AppDelegate.showError(title: "请填写备注", err: "减课时必须填写备注")
        } else {
            if self.courseTime.text != ""{
                if let amount = Int(self.courseTime.text!){
                    let updateAmount = (self.plusOrMinus.selectedSegmentIndex * (-2)) + 1
                    var note = "购买课程"
                    if self.Note.text != "" {
                        note = self.Note.text!
                    }
                    let approve = (AppDelegate.AP().region == userRegion.All)
                    thisStudent.ref.collection("registered").addDocument(data: ["Amount" : amount * updateAmount, "Approved":approve, "Date":Date(), "Note":note]) { (err) in
                        if let err = err{
                            AppDelegate.showError(title: "添加课程时发生错误", err: err.localizedDescription)
                        } else {
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                AppDelegate.showError(title: "请填写课时数", err: "请注意，填写的数字代表半小时数，例如，1代表该节课长度为半小时，如果要为一个学员加课20节，则填写40。")
            }
        }
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
