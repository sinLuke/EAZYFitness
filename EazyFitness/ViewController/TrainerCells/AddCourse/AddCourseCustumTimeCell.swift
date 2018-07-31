//
//  AddCourseCustumTimeCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/7/29.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

class AddCourseCustumTimeCell: UITableViewCell {
    var model: AddCourseDataModel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseNoteField: UITextField!
    @IBOutlet weak var courseAmount: UILabel!
    @IBOutlet weak var courseDatePicker: UIDatePicker!
    @IBOutlet weak var courseDate: UILabel!
    
    var _gesture:UIGestureRecognizer!
    var PickedDate:Date?
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var minusBtn: UIButton!
    
    var readyAmount:Int = 3
    @IBAction func datePicked(_ sender: Any) {
        if let datepicker = sender as? UIDatePicker{
            PickedDate = datepicker.date
        } else {
            PickedDate = courseDatePicker.date
        }
        let dateformater = DateFormatter()
        dateformater.dateStyle = .medium
        dateformater.timeStyle = .none
        let timeformater = DateFormatter()
        timeformater.dateStyle = .none
        timeformater.timeStyle = .short
        self.courseDate.text = "\(dateformater.string(from: PickedDate!)) \(PickedDate!.getThisWeekDayLongName()) \(timeformater.string(from: PickedDate!))"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.courseNoteField.resignFirstResponder()
        if self.courseNoteField.text == ""{
            self.courseNoteField.isEnabled = false
        } else {
            self.courseNoteField.isEnabled = true
        }
        return true
    }
    
    @objc func dismissKeyboard(){
        self.courseNoteField.endEditing(true)
    }
    
    func reload(){
        if model.studentList.count == 1{
            titleLabel.text = "添加单人课"
        } else {
            titleLabel.text = "添加多人课"
        }
        let calendar = Calendar.current
        let nextday = calendar.date(byAdding: .day, value: 1, to: Date())
        
        self._gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.addGestureRecognizer(_gesture)
        
        courseDatePicker.minimumDate = Date()
    }
    
    @IBAction func minus(_ sender: Any) {
        readyAmount = readyAmount - 1
        if readyAmount == 0 {
            minusBtn.isHidden = true
        }
        courseAmount.text = AppDelegate.prepareCourseNumber(readyAmount)
    }
    
    @IBAction func plus(_ sender: Any) {
        readyAmount = readyAmount + 1
        courseAmount.text = AppDelegate.prepareCourseNumber(readyAmount)
    }
    
    @IBAction func addCourseToArray(_ sender: Any) {
        if PickedDate == nil {
            AppDelegate.showError(title: "请输入时间", err: "请选择一个时间")
        } else {
            let newCourse = courseReadyItem(date: PickedDate!, amount: readyAmount, note: courseNoteField.text ?? "标准课程", count: 0)
            self.model.courseReadyList.insert(newCourse, at: 0)
            self.model.reload()
            AppDelegate.showWarning(title: "添加成功", err: nil)
        }
    }
}
