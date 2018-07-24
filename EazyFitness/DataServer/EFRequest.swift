//
//  EFRequest.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class EFRequest: EFData {
    
    var title:String = ""
    var receiver:String = ""
    var sander:String = ""
    var text:String = ""
    var date:Date = Date()
    var type:requestType = .other
    var bageRef:DocumentReference!
    
    static var requestList:[EFRequest] = []
    
    var requestRef:DocumentReference!
    
    var disable = false
    
    override func download() {
        ActivityViewController.callStart += 1
        ref.getDocument { (snap, err) in
            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取申请时错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                if let data = snap?.data(){
                    self.title = data["title"] as! String
                    self.receiver = data["receiver"] as! String
                    self.sander = data["sander"] as? String ?? ""
                    self.text = data["text"] as! String
                    self.date = data["date"] as! Date
                    self.bageRef = data["bageRef"] as? DocumentReference
                    self.requestRef = data["requestRef"] as? DocumentReference
                    //studentApproveCourse: studentcourse
                    //trainerApproveCourse: course
                    //studentAddValue:
                    self.type = enumService.toRequestType(s: data["type"] as! String)
                    self.ready = true
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    override func upload(handler: (()->())? = nil) {
        
    }
    
    class func removeRequestForReference(ref:DocumentReference){
        ActivityViewController.callStart += 1
        Firestore.firestore().collection("request").whereField("requestRef", isEqualTo: ref).getDocuments { (snaps, err) in
            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "移除申请时失败: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                for doc in snaps!.documents{
                    doc.reference.delete()
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    class func createRequest(bageRef:DocumentReference, title:String, receiver:String, sander:String, text:String, requestRef:DocumentReference, type:requestType){
        
        AppDelegate.SandNotification(to: receiver, with: text, and: title)
        
        Firestore.firestore().collection("request").addDocument(data:[
            "title" : title,
            "receiver" : receiver,
            "text" : text,
            "requestRef" : requestRef,
            "sander" : sander,
            "type": enumService.toString(e: type),
            "bageRef": bageRef,
            "date": Date()]){ (err) in
                if let err = err{
                    let message = MDCSnackbarMessage()
                    message.text = "添加申请失败: \(err.localizedDescription)"
                    MDCSnackbarManager.show(message)
                }
                if let vc = AppDelegate.getCurrentVC() as? refreshableVC{
                    let message = MDCSnackbarMessage()
                    message.text = "添加申请成功，已成功添加\(enumService.toDescription(e: type))"
                    MDCSnackbarManager.show(message)

                }
        }
    }
    
    func cancel(){
        if self.disable == false {
            ref.delete()
            if self.bageRef != nil {
                self.bageRef.delete()
            }
            switch self.type{
            case .studentAddValue:
                self.requestRef.delete()
            case .studentApproveCourse:
                self.requestRef.updateData(["status" : enumService.toString(e: .decline)])
            case .trainerApproveCourse:
                if let course = DataServer.courseDic[self.requestRef.documentID]{
                    for studentCourseRef in course.traineeStudentCourseRef{
                        studentCourseRef.updateData(["status" : enumService.toString(e: .waitForStudent)])
                    }
                }
            case .studentRemove:
                break
            case .trainerRemove:
                break
            case .other:
                break
            case .notification:
                break
            }
            
            if self.type != .notification{
                let bageRef = Firestore.firestore().collection("Message").addDocument(data: ["uid" : self.sander, "bage":2])
                EFRequest.createRequest(bageRef: bageRef, title: "\"\(self.title)\"已被拒绝", receiver: self.sander, sander: self.receiver, text: "\"\(self.text)\" 已被拒绝", requestRef: self.ref, type: .notification)
            }
            
            self.disable = true
        }
    }
    
    func approve(){
        if self.disable == false{
            ref.delete()
            if self.bageRef != nil {
                self.bageRef.delete()
            }
            switch self.type{
            case .studentAddValue:
                self.requestRef.updateData(["approved" : true])
            case .studentApproveCourse:
                self.requestRef.updateData(["status" : enumService.toString(e: .approved)])
            case .trainerApproveCourse:
                if let course = DataServer.courseDic[self.requestRef.documentID]{
                    for studentCourseRef in course.traineeStudentCourseRef{
                        studentCourseRef.updateData(["status" : enumService.toString(e: .waitForStudent)])
                    }
                }
                case .studentRemove:
                break
            case .trainerRemove:
                break
            case .other:
                break
            case .notification:
                break
            }
            
            if self.type != .notification{
                let bageRef = Firestore.firestore().collection("Message").addDocument(data: ["uid" : self.sander, "bage":2])
                EFRequest.createRequest(bageRef: bageRef, title: "\"\(self.title)\"已添加成功", receiver: self.sander, sander: self.receiver, text: "\"\(self.text)\" 已添加", requestRef: self.ref, type: .notification)
            }
            
            self.disable = true
        }
    }
    
    func dismiss(){
        if self.type == .notification{
            if self.disable == false{
                ref.delete()
                if self.bageRef != nil {
                    self.bageRef.delete()
                }
            }
        }
    }
    
    class func getRequestForCurrentUser(type:requestType?){

        if let currentUserUID = Auth.auth().currentUser?.uid{
            ActivityViewController.callStart += 1
            Firestore.firestore().collection("request").whereField("receiver", isEqualTo: currentUserUID).getDocuments { (snap, err) in
                if let err = err {
                    let message = MDCSnackbarMessage()
                    message.text = "读取申请时失败: \(err.localizedDescription)"
                    MDCSnackbarManager.show(message)
                } else {
                    EFRequest.requestList = []
                    for doc in snap!.documents{
                        if ((enumService.toRequestType(s: doc["type"] as! String) == type && type != nil) || type == nil) {
                            let efRequest = EFRequest(with: doc.reference)
                            efRequest.download()
                            EFRequest.requestList.append(efRequest)
                        }
                    }
                    AppDelegate.load()
                }
                ActivityViewController.callEnd += 1
            }
        }
    }
}
