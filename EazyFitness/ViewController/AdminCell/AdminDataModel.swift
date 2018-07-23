//
//  AdminDataModel.swift
//  EazyFitness
//
//  Created by Luke on 2018-07-23.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase

class AdminDataModel: NSObject {
    
    struct resultData {
        var title: String
        var time: Date
        var trainerName: String
        var studentName: String
    }
    
    static var DataDic: [String: resultData] = [:]
    
    
    
    static var generalDataTypeOfData = GeneralDataTypeOfData.coursePurchase
    static var generalDataScope = GeneralDataScope.all
    static var generalDataTime = GeneralDataTime.all
    
    static var managedVC: refreshableVC?
    
    static var scopeStudent: EFStudent?
    static var scopeTrainer: EFTrainer?
    
    enum GeneralDataTypeOfData {
        case coursePurchase
        case courseInfo
        case noStudent
        case notrainer
        case nocard
        case ill
    }
    
    var nameForCollection = ""
    
    enum GeneralDataScope {
        case all
        case byTrainer
        case byStudent
    }
    
    enum GeneralDataTime {
        case today
        case thisMonth
        case all
    }
    
    static var callStart = 0 {
        didSet {
            let vc = AdminDataModel.managedVC as? UIViewController
            vc?.navigationController?.title = "\(AdminDataModel.callStart)/\(AdminDataModel.callEnd)"
        }
    }
    static var callEnd = 0 {
        didSet {
            let vc = AdminDataModel.managedVC as? UIViewController
            vc?.navigationController?.title = "\(AdminDataModel.callStart)/\(AdminDataModel.callEnd)"
        }
    }
    
    class func refreshData(){
        managedVC?.startLoading()
        
        
    }
    
    class func funcForEach(handler: ()->()){
        switch AdminDataModel.generalDataScope {
        case .all:
            Firestore.firestore().collection("student").getDocuments { (snap, err) in
                if let snap = snap {
                    for doc in snap.documents {
                        AdminDataModel.handleStudentRef(ref: doc.reference)
                    }
                }
            }
        case .byTrainer:
            if let scopeTrainer = AdminDataModel.scopeTrainer{
                for ref in scopeTrainer.trainee {
                    AdminDataModel.handleStudentRef(ref: ref)
                }
            }
        case .byStudent:
            if let scopeStudent = AdminDataModel.scopeStudent{
                AdminDataModel.handleStudentRef(ref: scopeStudent.ref)
            }
        }
    }
    
    class func handleStudentRef(ref: DocumentReference) {
        if AdminDataModel.generalDataTypeOfData == .coursePurchase {
            ref.collection("registered").getDocuments { (snaps, err) in
                if let snaps = snaps {
                    for doc in snaps.documents {
                        if let amount = doc.data()["amount"] as? Int,
                            let date = doc.data()["date"] as? Date,
                            let note = doc.data()["note"] as? String{
                            let dataItem = resultData(title: "\(note), \(amount)", time: date, trainerName: "", studentName: ref.documentID)
                            AdminDataModel.DataDic[ref.documentID] = dataItem
                        }
                    }
                }
            }
        } else {
            ref.collection("course").getDocuments { (snaps, err) in
                if let snaps = snaps {
                    for doc in snaps.documents {
                        if let courseRef = doc.data()["ref"] as? DocumentReference {
                            AdminDataModel.handleCourseDataFromRef(ref: courseRef)
                        }
                    }
                }
            }
        }
    }
    
    class func handleCourseDataFromRef(ref: DocumentReference) {
        ref.getDocument { (snap, err) in
            if let snap = snap {
                if let amount = snap.data()?["amount"] as? Int,
                    let note = snap.data()?["note"] as? String,
                    let date = snap.data()?["date"] as? Date,
                    let traineeRef = snap.data()?["traineeRef"] as? [DocumentReference],
                    let traineeStudentCourseRef = snap.data()?["traineeStudentCourseRef"] as? [DocumentReference],
                    let trainerRef = snap.data()?["trainerRef"] as? DocumentReference {
                    var memberIDOfTrainee = ""
                    for item in traineeRef {
                        memberIDOfTrainee = "\(memberIDOfTrainee) \(item.documentID)"
                    }
                    let dataItem = resultData(title: "\(note), \(amount)", time: date, trainerName: trainerRef.documentID, studentName: memberIDOfTrainee)
                    AdminDataModel.DataDic[ref.documentID] = dataItem
                }
            }
        }
    }

}
