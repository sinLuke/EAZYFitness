//
//  EFStudentCourse.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class EFStudentCourse: EFData {
    var status:courseStatus = courseStatus.other
    var note:String = ""
    var courseRef:DocumentReference!
    weak var parent:EFStudent!
    override func download() {
        AppDelegate.startLoading()
        ref.getDocument { (snap, err) in
            AppDelegate.endLoading()
            if let err = err {
                let message = MDCSnackbarMessage()
                message.text = "读取学生课程时错误: \(err.localizedDescription)"
                MDCSnackbarManager.show(message)
            } else {
                if let data = snap?.data(){
                    self.status = enumService.toCourseStatus(s: data["status"] as! String)
                    self.note = data["note"] as! String
                    self.courseRef = data["ref"] as? DocumentReference
                    self.ready = true
                }
                AppDelegate.load()
            }
        }
    }
        
    override func upload() {
        if ready{
            ref.updateData(["status" : enumService.toString(e: self.status), "note": self.note])
        }
    }
}
