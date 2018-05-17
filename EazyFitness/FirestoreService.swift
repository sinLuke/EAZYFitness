//
//  FirestoreService.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/14.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
class FirestoreService: NSObject {
    
    static var studentNameInfo:[String:String] = [:]
    static var trainerNameInfo:[String:String] = [:]
    static var trainerStudentInfo:[String:[DocumentReference]] = [:]
    var CourseList:[ClassObj] = []
    var counter = 0
    
    class func updateStudentName(){
        Firestore.firestore().collection("student").getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取学生名称时出现问题", err: err.localizedDescription, of: AppDelegate.getCurrentVC()!)
            } else {
                for doc in snap!.documents{
                    FirestoreService.studentNameInfo[doc.documentID] = "\(doc.data()["First Name"]!) \(doc.data()["Last Name"]!)"
                }
                print("updateStudentName finished")
            }
        }
    }
    
    class func updateTrainer(){
        Firestore.firestore().collection("trainer").getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取教练名称时出现问题", err: err.localizedDescription, of: AppDelegate.getCurrentVC()!)
            } else {
                for doc in snap!.documents{
                    FirestoreService.trainerNameInfo[doc.documentID] = "\(doc.data()["First Name"]!) \(doc.data()["Last Name"]!)"
                    FirestoreService.trainerStudentInfo[doc.documentID] = []
                    doc.reference.collection("trainee").getDocuments(completion: { (snap2, err) in
                        if let err = err {
                            AppDelegate.showError(title: "获取教练学生时出现问题", err: err.localizedDescription, of: AppDelegate.getCurrentVC()!)
                        } else {
                            for doc2 in snap2!.documents{
                                FirestoreService.trainerStudentInfo[doc.documentID]!.append(doc2.data()["ref"] as! DocumentReference)
                            }
                        }
                    })
                }
            }
        }
    }
    
    class func readAllCourse(){
        
    }
    
    class func deleteCourseByCourseRef(courseRef:DocumentReference, finished:@escaping ()->()){
        courseRef.collection("trainee").getDocuments { (snaps, err) in
            if let err = err {
                AppDelegate.showError(title: "删除课程时出现问题", err: err.localizedDescription, of: AppDelegate.getCurrentVC()!)
            } else {
                for doc in snaps!.documents{
                    (doc.data()["ref"] as! DocumentReference).delete()
                    doc.reference.delete()
                }
                courseRef.delete()
                finished()
            }
        }
    }
    
    class func deleteCourseByStudentCourseRef(studentCourseRef:DocumentReference, finished:@escaping ()->()){
        studentCourseRef.getDocument { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "删除课程时出现问题", err: err.localizedDescription, of: AppDelegate.getCurrentVC()!)
            } else {
                let data = snap!.data()
                if let courseRef = data!["ref"] as? DocumentReference{
                    FirestoreService.deleteCourseByCourseRef(courseRef: courseRef, finished: finished)
                } else {
                    AppDelegate.showError(title: "删除课程时出现问题", err: "无法找到课程的引用", of: AppDelegate.getCurrentVC()!)
                }
            }
        }
    }
    
    
    
    func readCourseByStudentRef(studentRef:DocumentReference, finished:@escaping ([ClassObj])->()){
        CourseList = []
        studentRef.collection("CourseRecorded").getDocuments { (snaps, err) in
            if let err = err {
                AppDelegate.showError(title: "读取课程时出现问题", err: err.localizedDescription, of: AppDelegate.getCurrentVC()!)
            } else {
                self.counter = snaps!.count
                for doc in snaps!.documents{
                    var classobj = ClassObj()
                    self.CourseList.append(classobj)
                    classobj.courseRef = doc.data()["ref"] as! DocumentReference
                    classobj.status[studentRef.documentID] = enumService.toCourseStatus(s: doc.data()["status"] as! String)
                    classobj.trainer = doc.data()["trainer"] as! DocumentReference
                    classobj.courseRef.getDocument(completion: { (snap, err) in
                        if let err = err {
                            AppDelegate.showError(title: "读取课程时出现问题", err: err.localizedDescription, of: AppDelegate.getCurrentVC()!)
                        } else {
                            classobj.date = snap!.data()!["date"] as! Date
                            classobj.amount = snap!.data()!["amount"] as! Int
                            classobj.note = snap!.data()!["note"] as! String
                            classobj.type = enumService.toCourseType(s: snap!.data()!["type"] as! String)
                            classobj.courseRef.collection("trainee").getDocuments(completion: { (snaps, err) in
                                if let err = err {
                                    AppDelegate.showError(title: "读取学生时出现问题", err: err.localizedDescription, of: AppDelegate.getCurrentVC()!)
                                } else {
                                    var studentList:[DocumentReference] = []
                                    var studentNameList:[String:String] = [:]
                                    for doc in snaps!.documents{
                                        let studentRef = doc.data()["ref"] as! DocumentReference
                                        studentList.append(studentRef)
                                        studentNameList[studentRef.documentID] = FirestoreService.studentNameInfo[studentRef.documentID]
                                    }
                                    classobj.student = studentList
                                    classobj.studentName = studentNameList
                                }
                            })
                        }
                    })
                }
            }
        }
    }
}
