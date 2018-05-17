//
//  ClassObj.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/11.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class ClassObj: NSObject {
    
    var courseRef:DocumentReference!
    var note:String = ""
    var amount:Int = 0
    var student:[DocumentReference] = []
    var trainer:DocumentReference!
    var date:Date!
    var status:[String:courseStatus] = [:]
    var type:courseType!
    
    var studentName:[String:String] = [:]
    var trainerName:String?
    
    var statusDescription:String{
        get {
            if student.count == 1{
                return enumService.toDescription(e: status[student[0].documentID]!)
            } else if studentName.count > 1 {
                var returnValue = ""
                for i in 0...studentName.count-1{
                    returnValue = "\(returnValue)\(studentName[student[i].parent.parent!.documentID]!):\(status[student[i].documentID]!)"
                    if i != studentName.count-1{
                        returnValue = "\(returnValue), "
                    }
                }
                return returnValue
            }
            return "err"
        }
    }
    
    var allStudentName:String{
        get {
            if student.count == 1{
                return studentName[student[0].documentID] ?? "unnamed"
            } else if studentName.count > 1{
                var returnValue = ""
                for i in 0...studentName.count-1{
                    returnValue = "\(returnValue)\(studentName[student[i].parent.parent!.documentID]!)"
                    if i != studentName.count-1{
                        returnValue = "\(returnValue), "
                    }
                }
                return returnValue
            }
            return "err"
        }
    }
}
