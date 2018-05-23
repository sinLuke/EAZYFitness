//
//  EFCourse.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class EFCourse: EFData {
    var amount:Int = 0
    var date:Date = Date()
    var note:String = ""
    var type:courseType = .general
    var trainerRef:DocumentReference?
    var traineeRef:[DocumentReference] = []
    var traineeStudentCourseRef:[DocumentReference] = []
    var amountString:String{
        get {
            let float = Float(amount)/2.0
            if amount%2 == 0{
                return String(format: "%.0f", float)
            } else {
                return String(float)
            }
        }
    }
    var dateString:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        return "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"
    }
    var dateOnlyString:String{
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            return "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName())"
        }
    }
    
    var timeOnlyString:String{
        get{
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            return "\(timeFormatter.string(from: date))"
        }
    }
    
    var getTraineesNames:String{
        get{
            //print("traineeRef.count")
            //print(traineeRef.count)
            var _name = ""
            traineeRef.sort { (a, b) -> Bool in
                a.documentID > b.documentID
            }
            if traineeRef.count == 0{
                return ""
            }
            for i in 0...traineeRef.count - 1{
                if let student = DataServer.studentDic[traineeRef[i].documentID]{
                    if traineeRef.count == 1{
                        return student.name
                    } else {
                        //print("student.name")
                        //print(name)
                        if i != traineeRef.count - 1{
                            _name = "\(_name)\(student.name), "
                        } else {
                            _name = "\(_name)\(student.name)"
                        }
                    }
                }
                print("name:\(_name)")
            }
            return _name
        }
    }
    
    var getTraineesStatus:[courseStatus]{
        get{
            var list:[courseStatus] = []
            if traineeRef.count != traineeStudentCourseRef.count{
                print("traineeRef.count != traineeStudentCourseRef.count")
            } else {
                if traineeRef.count == 0{
                    return []
                }
                for i in 0...traineeRef.count - 1{
                    if let student = DataServer.studentDic[traineeRef[i].documentID]{
                        if let studentCourse = student.courseDic[traineeStudentCourseRef[i].documentID]{
                            list.append(studentCourse.status)
                        } else {
                            print("getTraineesStatus: 找不到学生的课程")
                        }
                    } else {
                        print("getTraineesStatus: 找不到学生")
                    }
                }
            }
            return list
        }
    }
    
    class func addCourse(courseRef:DocumentReference, date:Date, amount:Int, note:String?, trainer:DocumentReference, trainee:[DocumentReference], traineeStudentCourse:[DocumentReference]){
        var type = courseType.general
        if trainee.count == 0 || traineeStudentCourse.count != trainee.count{
            AppDelegate.showError(title: "添加课程失败", err: "参数错误")
        } else {
            if trainee.count == 1 {
                type = courseType.general
            } else {
                type = courseType.multiple
            }
        }
        courseRef.setData([
            "type" : enumService.toString(e: type),
            "amount": amount,
            "date": date,
            "note": note ?? "一般课程",
            "trainerRef": trainer,
            "traineeRef": trainee,
            "traineeStudentCourseRef": traineeStudentCourse]){ (err) in
            if let err = err{
                AppDelegate.showError(title: "添加课程失败", err: err.localizedDescription)
            }
            if let vc = AppDelegate.getCurrentVC() as? refreshableVC{
                vc.endLoading()
            }
        }
    }
    
    override func download(){
        ref.getDocument { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "课程下载时错误", err: err.localizedDescription)
            } else {
                if let data = snap?.data(){
                    self.amount = data["amount"] as! Int
                    self.date = data["date"] as! Date
                    self.note = data["note"] as! String
                    self.type = enumService.toCourseType(s: data["type"] as! String)
                    self.trainerRef = data["trainerRef"] as? DocumentReference
                    self.traineeRef = data["traineeRef"] as! [DocumentReference]
                    self.traineeStudentCourseRef = data["traineeStudentCourseRef"] as! [DocumentReference]
                    self.ready = true
                }
            }
        }
    }
    override func upload(){
        if ready {
            ref.updateData(["type" : enumService.toString(e: self.type),
                            "amount": self.amount,
                            "date":self.date,
                            "note":self.note,
                            "trainerRef":self.trainerRef!,
                            "traineeRef":self.traineeRef,
                            "traineeStudentCourseRef":self.traineeStudentCourseRef])
        }
    }
}
