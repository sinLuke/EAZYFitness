//
//  EFTrainer.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class EFTrainer: EFData {
    var firstName:String = ""
    var lastName:String = ""
    var name:String {
        get {
            return "\(firstName) \(lastName)"
        }
    }
    var uid:String?
    var memberID:String = ""
    var registered:userStatus = .canceled
    var region:userRegion = .Mississauga
    let usergroup:userGroup = .trainer
    var heightUnit:String = "cm" //cm/meter/inch
    var weightUnit:String = "kg" //kg/jin/pound
    var goal = 30
    var finish:[DocumentReference] = []
    var trainee:[DocumentReference] = []
    
    override func download(){
        AppDelegate.startLoading()
        ref.getDocument { (snap, err) in
            AppDelegate.endLoading()
            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取教练时错误: \(err.localizedDescription)"
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
                    self.trainee = data["trainee"] as! [DocumentReference]
                    self.ready = true
                    self.uid = data["uid"] as? String
                    
                    
                    self.setStudentTrainerUID()
                    AppDelegate.reload()
                    
                    for studentRef in self.trainee{
                        let newStudent = EFStudent(with: studentRef)
                        newStudent.download()
                        print(studentRef)
                        DataServer.studentDic[studentRef.documentID] = newStudent
                    }
                }
            }
        }
        ref.collection("finish").getDocuments { (snap, err) in
            AppDelegate.endLoading()
            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取已完成课程时错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                self.finish = []
                for doc in snap!.documents{
                    let _ref = doc["ref"] as! DocumentReference
                    self.finish.append(_ref)
                    if DataServer.courseDic[_ref.documentID] == nil{
                        let _course = EFCourse(with: _ref)
                        _course.download()
                        DataServer.courseDic[_ref.documentID] = _course
                    }
                }
                print("finish")
                AppDelegate.reload()
            }
        }
        
    }
    
    func setStudentTrainerUID(){
        for traineeRef in self.trainee {
            traineeRef.updateData(["trainerUID" : self.uid])
            traineeRef.updateData(["trainer" : self.memberID])
        }
    }
    
    func finishACourse(By courseRef:DocumentReference){
        ref.collection("finish").document(courseRef.documentID).setData(["ref" : courseRef])
        self.download()
    }
    
    class func addTrainer(at memberID:String, in region:userRegion) -> EFTrainer{
        if DataServer.trainerDic[memberID] != nil {
            return DataServer.trainerDic[memberID]!
        }
        let newref = Firestore.firestore().collection("trainer").document(memberID)
        newref.setData([
            "firstName" : "",
            "lastName" : "",
            "memberID" : memberID,
            "registered" : enumService.toString(e: userStatus.unsigned),
            "region" : enumService.toString(e: region),
            "heightUnit":"cm",
            "weightUnit":"kg",
            "trainee":[],
            "goal":30]){ (err) in
            if let err = err{
                let message = MDCSnackbarMessage()
                message.text = "添加教练失败: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            }
            if let vc = AppDelegate.getCurrentVC() as? refreshableVC{
                vc.endLoading()
            }
            AppDelegate.reload()
        }
        let newTrainer = EFTrainer(with: newref)
        newTrainer.download()
        return newTrainer
    }
    
    override func upload(handler: (()->())? = nil){
        if ready{
            ref.updateData([
                "firstName" : self.firstName,
                "lastName" : self.lastName,
                "memberID" : self.memberID,
                "registered" : enumService.toString(e: self.registered),
                "region" : enumService.toString(e: self.region),
                "heightUnit":self.heightUnit,
                "weightUnit":self.weightUnit,
                "trainee":self.trainee,
                "goal":self.goal]) { (_) in
                    AppDelegate.endLoading()
                    let message = MDCSnackbarMessage()
                    message.text = "对\(self.name)的修改上传成功"
                    MDCSnackbarManager.show(message)
                    self.download()
            }
        }
    }
}
