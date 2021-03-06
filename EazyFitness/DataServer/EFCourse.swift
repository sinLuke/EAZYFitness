//
//  EFCourse.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

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
    
    func getTraineesNames() {
        for thisref in traineeRef{
            ActivityViewController.callStart += 1
            thisref.getDocument { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取课程中学生名字时失败", err: err.localizedDescription)
                } else {
                    if let fname = snap!.data()?["firstName"] as? String, let lname = snap!.data()?["lastName"] as? String {
                        self.traineesNamesList[thisref.documentID] = "\(fname) \(lname)"
                    }
                }
                ActivityViewController.callEnd += 1
            }
        }
    }
    
    class func setCourse(with ref:DocumentReference) -> EFCourse{
        if let course = DataServer.courseDic[ref.documentID]{
            course.download()
            return course
        } else {
            let course = EFCourse(with: ref)
            DataServer.courseDic[ref.documentID] = course
            return course
        }
    }
    
    var traineesNamesList:[String:String] = [:]
    
    var traineesNames:String{
        get{
            //print("traineeRef.count")
            //print(traineeRef.count)
            var _name = ""
            let nameList = traineesNamesList.values.sorted()
            if nameList.count == 0{
                return ""
            }
            if nameList.count == 1{
                return nameList[0]
            }
            for i in 0...nameList.count - 1 {
                if i != nameList.count - 1{
                    _name = "\(_name)\(nameList[i]), "
                } else {
                    _name = "\(_name)\(nameList[i])"
                }
            }
            return _name
        }
    }
    
    func getTraineesStatus(){
        for thisref in traineeRef{
            ActivityViewController.callStart += 1
            thisref.collection("course").document(ref.documentID) .getDocument { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取课程中学生名字时失败", err: err.localizedDescription)
                } else {
                    if let status = snap!.data()?["status"] as? String{
                        self.traineesStatusList[thisref.documentID] = enumService.toCourseStatus(s: status)
                    }
                }
                ActivityViewController.callEnd += 1
            }
        }
    }
    
    var traineesStatusList:[String:courseStatus] = [:]
    
    var traineesStatus:[courseStatus]{
        get{
            return Array(traineesStatusList.values)
        }
    }
    
    var traineesMultiStatus:multiCourseStatus {
        get {
            return enumService.toMultiCourseStataus(list: traineesStatus)
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
        ActivityViewController.callStart += 1
        
        let newCourse = EFCourse.init(with: courseRef)
        newCourse.amount = amount
        newCourse.type = type
        newCourse.date = date
        newCourse.traineeRef = trainee
        newCourse.trainerRef = trainer
        newCourse.traineeStudentCourseRef = traineeStudentCourse
        
        DataServer.courseDic[courseRef.documentID] = newCourse
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
            ActivityViewController.callEnd += 1
        }
    }
    
    func delete(){
        for studentRef in self.traineeRef {
            ActivityViewController.callStart += 1
            studentRef.collection("course").document(self.ref.documentID).updateData(["status" : enumService.toString(e: .deleted)]) { (err) in
                if let err = err {
                    AppDelegate.showError(title: "删除课程时出现错误", err: err.localizedDescription)
                }
                ActivityViewController.callEnd += 1
            }
        }
        EFRequest.removeRequestForReference(ref: self.ref)
        
        for theStudentRef in self.traineeRef {
            theStudentRef.getDocument { (snap, err) in
                if let snap = snap {
                    if let receiverUID = snap.data()?["uid"] as? String {
                        AppDelegate.SandNotification(to: receiverUID, with: "\(self.date.descriptDate())的课程已删除", and: "")
                    }
                }
            }
        }
    }
    
    override func download(){
        ActivityViewController.callStart += 1
        ref.getDocument { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "课程下载时错误", err: err.localizedDescription)
            } else {
                if let data = snap!.data(){
                    self.amount = data["amount"] as! Int
                    self.date = data["date"] as! Date
                    self.note = data["note"] as! String
                    self.type = enumService.toCourseType(s: data["type"] as! String)
                    self.trainerRef = data["trainerRef"] as? DocumentReference
                    self.traineeRef = data["traineeRef"] as! [DocumentReference]
                    self.traineeStudentCourseRef = data["traineeStudentCourseRef"] as! [DocumentReference]
                    self.ready = true
                    self.getTraineesNames()
                    self.getTraineesStatus()
                    
                } else {
                    
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    override func upload(handler: (()->())? = nil){
        if ready {
            ref.updateData(["type" : enumService.toString(e: self.type),
                            "amount": self.amount,
                            "note":self.note,
                            "trainerRef":self.trainerRef!,
                            "traineeRef":self.traineeRef,
                            "traineeStudentCourseRef":self.traineeStudentCourseRef])
        }
    }
}
