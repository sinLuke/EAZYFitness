//
//  EFTrainer.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class EFTrainer: EFData {
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
    let usergroup:userGroup = .trainer
    var heightUnit:String = "cm" //cm/meter/inch
    var weightUnit:String = "kg" //kg/jin/pound
    var goal = 30
    var finish:[DocumentReference] = []
    
    override func download(){
        ref.getDocument { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "读取教练时错误", err: err.localizedDescription)
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
                    self.ready = true
                }
            }
        }
        ref.collection("finish").getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "课程学生时错误", err: err.localizedDescription)
            } else {
                self.finish = []
                for doc in snap!.documents{
                    let _ref = doc["ref"] as! DocumentReference
                    self.finish.append(_ref)
                    if DataServer.courseDic[_ref.documentID] == nil{
                        let _course = EFCourse(with: _ref)
                        _course.download()
                        DataServer.courseDic[_ref.documentID] = _course
                    } else {
                        DataServer.courseDic[_ref.documentID]!.download()
                    }
                }
            }
        }
    }
    
    class func addTrainer(at memberID:String, in region:userRegion) -> EFTrainer{
        let newref = Firestore.firestore().collection("trainer").addDocument(data: ["firstName" : "", "lastName" : "", "memberID" : memberID, "registered" : enumService.toString(e: userStatus.unsigned), "region" : enumService.toString(e: region), "heightUnit":"cm", "weightUnit":"kg", "goal":30]){ (err) in
            if let err = err{
                AppDelegate.showError(title: "添加教练失败", err: err.localizedDescription)
            }
            if let vc = AppDelegate.getCurrentVC() as? refreshableVC{
                vc.endLoading()
            }
        }
        let newTrainer = EFTrainer(with: newref)
        newTrainer.download()
        return newTrainer
    }
    
    override func upload(){
        if ready{
            ref.updateData(["firstName" : self.firstName, "lastName" : self.lastName, "memberID" : self.memberID, "registered" : enumService.toString(e: self.registered), "region" : enumService.toString(e: self.region), "heightUnit":self.heightUnit, "weightUnit":self.weightUnit, "goal":30])
        }
    }
}
