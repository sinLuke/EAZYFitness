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
            ref.updateData(["type" : enumService.toString(e: self.type), "amount": self.amount, "date":self.date, "note":self.note, "trainerRef":self.trainerRef!, "traineeRef":self.traineeRef, "traineeStudentCourseRef":self.traineeStudentCourseRef])
        }
    }
}
