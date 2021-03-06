//
//  DataServer.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class DataServer: NSObject {
    
    //Firestore References
    let userCollection = Firestore.firestore().collection("users")
    let trainerCollection = Firestore.firestore().collection("trainer")
    let studentCollection = Firestore.firestore().collection("student")
    let courseCollection = Firestore.firestore().collection("course")
    let QRcodeCollection = Firestore.firestore().collection("QRCODE")
    
    let uid:String
    let memberID:String
    let usergroup:userGroup
    let region:userRegion
    var fname:String = ""
    var lname:String = ""
    var email:String = ""
    
    let userRef:DocumentReference
    var studentRef:[DocumentReference] = []
    
    static var courseDic:[String:EFCourse] = [:]
    static var studentDic:[String:EFStudent]  = [:]
    static var trainerDic:[String:EFTrainer]  = [:]
    
    static func initfunc(email:String){
        ActivityViewController.callStart += 1
        Firestore.firestore().collection("users").whereField("email", isEqualTo: email).getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
            } else {
                let doc = snap!.documents
                if doc.count > 0{
                    let data = doc[0].data()
                    DataServer.createDataServer(data: data, uid: doc[0].documentID)
                } else {
                    AppDelegate.showError(title: "邮箱错误", err: "请重新输入邮箱，或与客服联系。您输入的邮箱为: \(email)")

                }
            }
            ActivityViewController.callEnd += 1
        }
        DataServer.updateDatabaseUID()
    }
    
    static func updateDatabaseUID(){
        ActivityViewController.callStart += 1
        Firestore.firestore().collection("users").getDocuments { (snap, err) in
            if let snap = snap {
                for docs in snap.documents{
                    if let usergroup = docs.data()["usergroup"] as? String, let region = docs.data()["region"] as? String{
                        if usergroup == "admin" {
                            Firestore.firestore().collection("admin").document(region).setData(["uid" : docs.documentID])
                        }
                    }
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    static func initfunc(uid:String){
        let userRef = Firestore.firestore().collection("users").document(uid)
        ActivityViewController.callStart += 1
        userRef.getDocument { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
            } else {
                if let data = snap!.data(){
                    DataServer.createDataServer(data: data, uid:uid)
                } else {
                    AppDelegate.showError(title: "登录错误", err: "无法读取用户数据", handler:AppDelegate.AP().signout)
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    static func createDataServer(data:[String:Any], uid:String){
        if let memberID = data["memberID"] as? String,
            let usergroup = data["usergroup"] as? String,
            let region = data["region"] as? String,
            let fname = data["firstName"] as? String,
            let lname = data["lastName"] as? String,
            let email = data["email"] as? String{
            AppDelegate.AP().ds = DataServer(uid: uid, memberID: memberID, usergroup: enumService.toUsergroup(s: usergroup), region: enumService.toRegion(s: region))
            AppDelegate.AP().ds!.fname = fname
            AppDelegate.AP().ds!.lname = lname
            AppDelegate.AP().ds!.email = email
            AppDelegate.AP().dataServerDidFinishInit()
        } else {
            AppDelegate.showError(title: "登录错误", err: "无法读取用户数据", handler:AppDelegate.AP().signout)
        }
        
    }
    
    init(uid:String, memberID:String, usergroup:userGroup, region:userRegion){
        self.uid = uid
        self.memberID = memberID
        self.usergroup = usergroup
        self.region = region
        
        userRef = userCollection.document(uid)
        if usergroup == .student{
            studentRef = [studentCollection.document(memberID)]
            DataServer.studentDic[studentCollection.document(memberID).documentID] = EFStudent.setStudent(with: studentCollection.document(memberID))
        }
        super.init()
        self.download()
    }
    
    func download(){
        switch usergroup {
        case .student:
            let _student = EFStudent.setStudent(with: studentCollection.document(self.memberID))
            _student.download()
            DataServer.studentDic[self.memberID] = _student

        case .trainer:
            let _trainer = EFTrainer.setTrainer(with: self.trainerCollection.document(self.memberID))
            _trainer.download()
            DataServer.trainerDic[self.memberID] = _trainer
        case .admin:
            ActivityViewController.callStart += 1
            self.studentCollection.getDocuments { (snap, err) in
                
                if let err = err {
                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
                } else {
                    self.studentRef = []
                    for doc in snap!.documents{
                        let _student = EFStudent.setStudent(with: doc.reference)
                        self.studentRef.append(doc.reference)
                        _student.download()
                        DataServer.studentDic[doc.documentID] = _student
                    }

                }
                ActivityViewController.callEnd += 1
            }
            ActivityViewController.callStart += 1
            self.trainerCollection.getDocuments { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
                } else {
                    self.studentRef = []
                    for doc in snap!.documents{
                            let _trainer = EFTrainer.setTrainer(with: doc.reference)
                            _trainer.download()
                            DataServer.trainerDic[doc.documentID] = _trainer
                    }



                }
                ActivityViewController.callEnd += 1
            }
        default:
            return
        }
    }
}
