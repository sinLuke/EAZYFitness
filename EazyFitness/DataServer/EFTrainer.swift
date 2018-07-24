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
    
    class func setTrainer(with ref:DocumentReference) -> EFTrainer {
        if let trainer = DataServer.trainerDic[ref.documentID]{
            trainer.download()
            return trainer
        } else {
            let trainer = EFTrainer(with: ref)
            DataServer.trainerDic[ref.documentID] = trainer
            return trainer
        }
    }
    
    override func download(){
        ActivityViewController.callStart += 1
        ref.getDocument { (snap, err) in
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
                    
                    for studentRef in self.trainee{
                        EFStudent.setStudent(with: studentRef)
                    }
                }
            }
            ActivityViewController.callEnd += 1
        }
        ActivityViewController.callStart += 1
        ref.collection("finish").getDocuments { (snap, err) in

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
                        EFCourse.setCourse(with: _ref)
                    }
                }
            }
            ActivityViewController.callEnd += 1
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
        }
        let newTrainer = EFTrainer.setTrainer(with: newref)
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

                    let message = MDCSnackbarMessage()
                    message.text = "对\(self.name)的修改上传成功"
                    MDCSnackbarManager.show(message)
                    self.download()
            }
        }
    }
}
