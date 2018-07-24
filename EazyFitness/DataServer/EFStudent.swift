//
//  EFStudent.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class EFStudent: EFData {
    var firstName:String = ""
    var lastName:String = ""
    var name:String {
        get {
            return "\(firstName) \(lastName)"
        }
    }
    var memberID:String = ""
    var registered:userStatus = .canceled
    var region:userRegion = .Mississauga
    let usergroup:userGroup = .student
    var goal:Int = 30
    var heightUnit:String = "cm" //cm/meter/inch
    var weightUnit:String = "kg" //kg/jin/pound
    var courseDic:[String:EFStudentCourse] = [:]
    var registeredDic:[String:EFStudentRegistered] = [:]
    var messageDic:[String:EFStudentMessage] = [:]
    var personalDic:[String:EFStudentPersonal] = [:]
    var trainer:String?
    var trainerUID:String?
    var uid:String?
    
    class func setStudent(with ref:DocumentReference) -> EFStudent{
        if let student = DataServer.studentDic[ref.documentID]{
            student.download()
            return student
        } else {
            let student = EFStudent(with: ref)
            DataServer.studentDic[ref.documentID] = student
            return student
        }
    }
    
    override func download(){
        ActivityViewController.callStart += 1
        ref.getDocument { (snap, err) in
            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取学生时错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                if let data = snap?.data(){
                    self.firstName = data["firstName"] as! String
                    self.lastName = data["lastName"] as! String
                    self.memberID = data["memberID"] as! String
                    self.registered = enumService.toUserStatus(s: data["registered"] as! String)
                    self.region = enumService.toRegion(s: data["region"] as! String)
                    self.heightUnit = data["heightUnit"] as! String
                    self.weightUnit = data["weightUnit"] as! String
                    self.goal = data["goal"] as! Int
                    self.uid = data["uid"] as? String
                    self.trainer = data["trainer"] as? String
                    self.trainerUID = data["trainerUID"] as? String
                    self.ready = true
                }
            }
            ActivityViewController.callEnd += 1
        }
        ActivityViewController.callStart += 1
        ref.collection("course").getDocuments { (snap, err) in

            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取学生时错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                for doc in snap!.documents{
                    let efStudentCourse = EFStudentCourse(with: doc.reference)
                    efStudentCourse.parent = self.ref.documentID
                    efStudentCourse.courseRef = doc["ref"] as! DocumentReference
                    efStudentCourse.note = doc["note"] as! String
                    efStudentCourse.status = enumService.toCourseStatus(s: doc["status"] as! String)
                    if DataServer.courseDic[efStudentCourse.courseRef.documentID] == nil{
                        let _course = EFCourse(with: efStudentCourse.courseRef)
                        _course.download()
                        DataServer.courseDic[efStudentCourse.courseRef.documentID] = _course
                    } else {
                        DataServer.courseDic[efStudentCourse.courseRef.documentID]!.download()
                    }
                    self.courseDic[(doc["ref"] as! DocumentReference).documentID] = efStudentCourse
                }

            }
            
            ActivityViewController.callEnd += 1
        }
        ActivityViewController.callStart += 1
        ref.collection("registered").getDocuments { (snap, err) in

            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取学生时错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                for doc in snap!.documents{
                    let efStudentRegistered = EFStudentRegistered(with: doc.reference)
                    efStudentRegistered.amount = doc["amount"] as? Int
                    efStudentRegistered.approved = doc["approved"] as? Bool
                    efStudentRegistered.date = doc["date"] as? Date
                    efStudentRegistered.note = doc["note"] as? String
                    self.registeredDic[doc.documentID] = efStudentRegistered
                }
            }
            ActivityViewController.callEnd += 1
        }
        ActivityViewController.callStart += 1
        ref.collection("message").getDocuments { (snap, err) in

            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取学生时错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                for doc in snap!.documents{
                    let efStudentMessage = EFStudentMessage(with: doc.reference)
                    efStudentMessage.byStudent = doc["byStudent"] as! Bool
                    efStudentMessage.read = doc["read"] as! Bool
                    efStudentMessage.text = doc["text"] as! String
                    efStudentMessage.type = enumService.toMessageType(s: doc["type"] as! String)
                    efStudentMessage.date = doc["date"] as! Date
                    self.messageDic[(doc["ref"] as! DocumentReference).documentID] = efStudentMessage
                }
            }
            ActivityViewController.callEnd += 1
        }
        ActivityViewController.callStart += 1
        ref.collection("personal").getDocuments { (snap, err) in

            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取学生时错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                self.personalDic = [:]
                for doc in snap!.documents{
                    let efStudentPersonal = EFStudentPersonal(with: doc.reference)
                    efStudentPersonal.date = doc["date"] as! Date
                    efStudentPersonal.recordKey = doc["recordKey"] as! String
                    efStudentPersonal.recordValue = doc["recordValue"] as! Float
                    self.personalDic[(doc["ref"] as! DocumentReference).documentID] = efStudentPersonal
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    class func addStudent(at memberID:String, in region:userRegion) -> EFStudent{
        let newref = Firestore.firestore().collection("student").document(memberID)
        newref.setData([
            "firstName" : "",
            "lastName" : "",
            "memberID" : memberID,
            "registered" : enumService.toString(e: userStatus.unsigned),
            "region" : enumService.toString(e: region),
            "heightUnit":"cm",
            "weightUnit":"kg",
            "goal":30]){ (err) in
            if let err = err{
                let message = MDCSnackbarMessage()
                message.text = "添加学生失败: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            }
            if let vc = AppDelegate.getCurrentVC() as? refreshableVC{
                let message = MDCSnackbarMessage()
                message.text = "添加学生完成"
                MDCSnackbarManager.show(message)

            }
        }
        let newStudent = EFStudent.setStudent(with: newref)
        DataServer.studentDic[memberID] = newStudent
        newStudent.download()
        return newStudent
    }
    
    class func addCourse(of studentList:[EFStudent], date:Date, amount:Int, note:String?, trainer:DocumentReference, status:courseStatus){
        
        guard let cuid = Auth.auth().currentUser?.uid else {
            AppDelegate.showError(title: "用户错误", err: "请重新登录", handler: AppDelegate.AP().signout)
            return
        }
        
        for theStudent in studentList{
            if theStudent.uid == nil || theStudent.uid == "" {
                let message = MDCSnackbarMessage()
                message.text = "\(theStudent.name)尚未注册, 暂时无法添加"
                MDCSnackbarManager.show(message)
                return
            }
        }
        var traineeStudentCourse:[DocumentReference] = []
        var trainee:[DocumentReference] = []
        let courseRef = Firestore.firestore().collection("course").addDocument(data: ["note" : "正在创建"])
        for theStudent in studentList{
            
            let traineeStudentCourseRef = theStudent.ref.collection("course").document(courseRef.documentID)
            traineeStudentCourseRef.setData(["note" : note ?? "无备注", "ref":courseRef, "status":enumService.toString(e: status)])
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .medium
            
            if let ds = AppDelegate.AP().ds {
                let bageRef = Firestore.firestore().collection("Message").addDocument(data: ["uid" : theStudent.uid ?? "null", "bage":2])
                EFRequest.createRequest(
                    bageRef:bageRef,
                    title: "为\(theStudent.name)添加课程",
                    receiver: theStudent.uid!,
                    sander: cuid,
                    text: "\(enumService.toString(e:ds.region))申请添加\(date.descriptDate()), 长度为\(AppDelegate.prepareCourseNumber(amount))的课程",
                    requestRef: traineeStudentCourseRef,
                    type: requestType.studentApproveCourse)
                traineeStudentCourse.append(traineeStudentCourseRef)
                trainee.append(theStudent.ref)
            } else {
                AppDelegate.showError(title: "读取当前用户出现问题", err: "请重新登录", handler: AppDelegate.AP().signout)
            }
        }
        
        EFCourse.addCourse(courseRef:courseRef, date: date, amount: amount, note: note, trainer: trainer, trainee: trainee, traineeStudentCourse: traineeStudentCourse)
    }
    
    func addRegistered(amount:Int, note:String, approved:Bool, sutdentName:String){
        
        guard let cuid = Auth.auth().currentUser?.uid else {
            AppDelegate.showError(title: "用户错误", err: "请重新登录", handler: AppDelegate.AP().signout)
            return
        }
        if let ds = AppDelegate.AP().ds {
            let registerRef = ref.collection("registered").addDocument(data: ["amount" : amount, "note" : note, "approved":approved, "date":Date()])
            let bageRef = Firestore.firestore().collection("Message").addDocument(data: ["uid" : AppDelegate.AP().superUID, "bage":2])
            EFRequest.createRequest(
                bageRef: bageRef,
                title: "\(enumService.toString(e:ds.region))小助手为\(sutdentName)购买\(amount)课时",
                receiver: AppDelegate.AP().superUID,
                sander: cuid,
                text: note,
                requestRef: registerRef,
                type: requestType.studentAddValue)
            if let vc = AppDelegate.getCurrentVC() as? refreshableVC{

            }
            self.download()
        }
    }
    
    func getTrainer(){
        ActivityViewController.callStart += 1
        Firestore.firestore().collection("trainer").getDocuments { (snaps, err) in
            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "未知错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                for doc in snaps!.documents{
                    if let traineeList = doc.data()["trainee"] as? [DocumentReference]{
                        for ref in traineeList {
                            if ref.documentID == self.memberID {
                                self.trainer = doc.documentID
                                self.trainerUID = doc.data()["uid"] as? String
                            }
                        }
                    }
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    func addMessage(text:String, type:messageType){
        if let ds = AppDelegate.AP().ds{
            ref.collection("message").addDocument(data: ["byStudent" : ds.usergroup == .student, "text":text, "read":false, "type":type, "date":Date()]){ (err) in
                if let err = err{
                    let message = MDCSnackbarMessage()
                    message.text = "发送信息失败: \(err.localizedDescription)"
                    MDCSnackbarManager.show(message)
                }
            }
        } else {
            let message = MDCSnackbarMessage()
            message.text = "发送信息失败: 无法确定用户组"
            MDCSnackbarManager.show(message)
        }
    }
    
    override func upload(handler: (()->())? = nil){
        if ready{
            ref.updateData(["firstName" : self.firstName, "lastName" : self.lastName, "memberID" : self.memberID, "registered" : enumService.toString(e: self.registered), "region" : enumService.toString(e: self.region), "heightUnit":self.heightUnit, "weightUnit":self.weightUnit, "goal":self.goal, "uid":self.uid ?? ""]){ (err) in
                if err == nil {
                    handler?()
                }
            }
        }
        for efStudentCourse in self.courseDic.values{
            efStudentCourse.upload()
        }
    }
}
