//
//  AllStudentNewPurchaseViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class AllStudentNewPurchaseViewController: DefaultViewController, UITextFieldDelegate {

    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var courseTime: UITextField!
    var _gesture:UIGestureRecognizer!
    @IBOutlet weak var plusOrMinus: UISegmentedControl!
    @IBOutlet weak var Note: UITextField!
    
    var thisStudent:EFStudent!
    override func viewDidLoad() {
        super.viewDidLoad()
        self._gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.title = "为\(thisStudent.name)加课"
        
        courseTime.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
                    let approve = (AppDelegate.AP().ds?.region == userRegion.All)
                    thisStudent.addRegistered(amount: amount * updateAmount, note: note, approved: approve, sutdentName: thisStudent.name)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            } else {
                AppDelegate.showError(title: "请填写课时数", err: "请注意，填写的数字代表半小时数，例如，1代表该节课长度为半小时，如果要为一个学员加课20节，则填写40。")
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let stringValue = courseTime.text, let intValue = Int(stringValue){
            if self.plusOrMinus.selectedSegmentIndex == 0 {
                courseLabel.text = "（记录为：\(prepareCourseNumber(intValue))课时）"
            } else {
                courseLabel.text = "（记录为：减去\(prepareCourseNumber(intValue))课时）"
            }
        } else {
            courseLabel.text = "（记录为：0课时）"
        }
    }

    @IBAction func textFieldValueChanged(_ sender: Any) {
        
    }
    
    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
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
