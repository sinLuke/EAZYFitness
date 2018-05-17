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
        Firestore.firestore().collection("users").whereField("email", isEqualTo: email).getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
            } else {
                let doc = snap!.documents
                if doc.count > 0{
                    let data = doc[0].data()
                    DataServer.createDataServer(data: data, uid: doc[0].documentID)
                }
            }
        }
    }
    
    static func initfunc(uid:String){
        let userRef = Firestore.firestore().collection("users").document(uid)
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
            DataServer.studentDic[studentCollection.document(memberID).documentID] = EFStudent(with: studentCollection.document(memberID))
        }
        super.init()
        self.download()
    }
    
    func download(){
        DataServer.studentDic = [:]
        DataServer.trainerDic = [:]
        DataServer.courseDic = [:]
        switch usergroup {
        case .student:
            let _student = EFStudent(with: studentCollection.document(self.memberID))
            _student.download()
            DataServer.studentDic[self.memberID] = _student
            
        case .trainer:
            trainerCollection.document(self.memberID).collection("trainee").getDocuments { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
                } else {
                    self.studentRef = []
                    for doc in snap!.documents{
                        let _ref = doc.data()["ref"] as! DocumentReference
                        self.studentRef.append(_ref)
                        let _student = EFStudent(with: _ref)
                        _student.download()
                        DataServer.studentDic[_ref.documentID] = _student
                    }
                }
            }
        case .admin:
            self.studentCollection.getDocuments { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
                } else {
                    self.studentRef = []
                    for doc in snap!.documents{
                        if doc.data()["region"] as! String == enumService.toString(e: self.region) || self.region == userRegion.All{
                            let _student = EFStudent(with: doc.reference)
                            self.studentRef.append(doc.reference)
                            _student.download()
                            DataServer.studentDic[doc.documentID] = _student
                        }
                    }
                }
            }
            self.trainerCollection.getDocuments { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
                } else {
                    self.studentRef = []
                    for doc in snap!.documents{
                        if doc.data()["region"] as! String == enumService.toString(e: self.region) || self.region == userRegion.All{
                            let _trainer = EFTrainer(with: doc.reference)
                            _trainer.download()
                            DataServer.trainerDic[doc.documentID] = _trainer
                        }
                    }
                }
            }
        default:
            return
        }
    }
}
