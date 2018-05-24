//
//  EFRequest.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class EFRequest: EFData {
    
    var title:String = ""
    var sander:String = ""
    var receiver:String = ""
    var text:String = ""
    var date:Date = Date()
    var type:requestType = .other
    var bageRef:DocumentReference!
    
    static var requestList:[EFRequest] = []
    
    var requestRef:DocumentReference!
    
    var disable = false
    
    override func download() {
        AppDelegate.startLoading()
        ref.getDocument { (snap, err) in
            AppDelegate.endLoading()
            if let err = err {
                AppDelegate.showError(title: "读取申请时错误", err: err.localizedDescription)
            } else {
                if let data = snap?.data(){
                    self.title = data["title"] as! String
                    self.sander = data["sander"] as! String
                    self.receiver = data["receiver"] as! String
                    self.text = data["text"] as! String
                    self.date = data["date"] as! Date
                    self.bageRef = data["bageRef"] as! DocumentReference
                    self.requestRef = data["requestRef"] as! DocumentReference
                    //studentApproveCourse: studentcourse
                    //trainerApproveCourse: course
                    //studentAddValue:
                    self.type = enumService.toRequestType(s: data["type"] as! String)
                    self.ready = true
                    AppDelegate.reload()
                }
            }
        }
    }
    
    override func upload() {
        
    }
    
    class func createRequest(bageRef:DocumentReference, title:String, sander:String, receiver:String, text:String, requestRef:DocumentReference, type:requestType){
        Firestore.firestore().collection("request").addDocument(data:[
            "title" : title,
            "receiver" : receiver,
            "sander" : sander,
            "text" : text,
            "requestRef" : requestRef,
            "type": enumService.toString(e: type),
            "bageRef": bageRef,
            "date": Date()]){ (err) in
                if let err = err{
                    AppDelegate.showError(title: "添加申请失败", err: err.localizedDescription)
                }
                if let vc = AppDelegate.getCurrentVC() as? refreshableVC{
                    AppDelegate.showError(title: "添加申请成功", err: "已成功添加\(enumService.toDescription(e: type))")
                    vc.endLoading()
                }
        }
    }
    
    func cancel(){
        
        if self.disable == false {
            ref.delete()
            self.bageRef.delete()
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
            }
            self.disable = true
        }
    }
    
    func approve(){
        if self.disable == false {
            ref.delete()
            self.bageRef.delete()
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
            }
            self.disable = true
        }
    }
    
    class func getRequestForCurrentUser(type:requestType?){
        EFRequest.requestList = []
        if let currentUserUID = Auth.auth().currentUser?.uid{
            Firestore.firestore().collection("request").whereField("receiver", isEqualTo: currentUserUID).getDocuments { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取申请失败", err: err.localizedDescription)
                } else {
                    for doc in snap!.documents{
                        if ((enumService.toRequestType(s: doc["type"] as! String) == type && type != nil) || type == nil) {
                            let efRequest = EFRequest(with: doc.reference)
                            efRequest.download()
                            EFRequest.requestList.append(efRequest)
                            print("EFRequest.requestList.append(efRequest)")
                        }
                    }
                    AppDelegate.load()
                }
            }
        }
    }
}
