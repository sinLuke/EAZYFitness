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
        var value: String
        var region: userRegion
    }
    
    static var DataDic: [String: resultData] = [:]
    
    static var generalDataTypeOfData = GeneralDataTypeOfData.coursePurchase
    static var generalDataScope = GeneralDataScope.all
    static var generalDataTime = GeneralDataTime.all
    static var generalRegion = userRegion.All
    
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
            print("\(AdminDataModel.callEnd)/\(AdminDataModel.callStart)")
            let vc = AdminDataModel.managedVC as? UIViewController
            vc?.navigationController?.title = "\(AdminDataModel.callEnd)/\(AdminDataModel.callStart)"
            if callStart == callEnd {
                AdminDataModel.managedVC?.reload()
            }
        }
    }
    static var callEnd = 0 {
        didSet {
            print("\(AdminDataModel.callEnd)/\(AdminDataModel.callStart)")
            let vc = AdminDataModel.managedVC as? UIViewController
            vc?.navigationController?.title = "\(AdminDataModel.callEnd)/\(AdminDataModel.callStart)"
            if callStart == callEnd {
                AdminDataModel.managedVC?.reload()
            }
        }
    }
    
    class func refreshData(){
        AdminDataModel.callEnd = 0
        AdminDataModel.callStart = 0
        AdminDataModel.DataDic = [:]
        managedVC?.startLoading()
        AdminDataModel.funcForEach()
    }
    
    static func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    
    class func funcForEach(){
        switch AdminDataModel.generalDataScope {
        case .all:
            AdminDataModel.callStart += 1
            Firestore.firestore().collection("student").getDocuments { (snap, err) in
                if let snap = snap {
                    for doc in snap.documents {
                        AdminDataModel.handleStudentRef(ref: doc.reference)
                    }
                }
                AdminDataModel.callEnd += 1
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
            AdminDataModel.callStart += 1
            ref.collection("registered").getDocuments { (snaps, err) in
                if let snaps = snaps {
                    for doc in snaps.documents {
                        if let amount = doc.data()["amount"] as? Int,
                            let date = doc.data()["date"] as? Date,
                            let note = doc.data()["note"] as? String{
                            
                            let regionOfStudent = DataServer.studentDic[ref.documentID]?.region ?? .Mississauga
                            let studentName = DataServer.studentDic[ref.documentID]?.name ?? ref.documentID
                            
                            if regionOfStudent == generalRegion || generalRegion == .All{
                                let dataItem = resultData(title: note, time: date, trainerName: "", studentName: studentName, value: prepareCourseNumber(amount), region: regionOfStudent)
                                AdminDataModel.DataDic[ref.documentID] = dataItem
                            }
                        }
                    }
                }
                AdminDataModel.callEnd += 1
            }
        } else {
            AdminDataModel.callStart += 1
            ref.collection("course").getDocuments { (snaps, err) in
                if let snaps = snaps {
                    for doc in snaps.documents {
                        if let courseRef = doc.data()["ref"] as? DocumentReference {
                            AdminDataModel.handleCourseDataFromRef(ref: courseRef)
                        }
                    }
                }
                AdminDataModel.callEnd += 1
            }
        }
    }
    
    class func handleCourseDataFromRef(ref: DocumentReference) {
        AdminDataModel.callStart += 1
        ref.getDocument { (snap, err) in
            if let snap = snap {
                if let amount = snap.data()?["amount"] as? Int,
                    let note = snap.data()?["note"] as? String,
                    let date = snap.data()?["date"] as? Date,
                    let traineeRef = snap.data()?["traineeRef"] as? [DocumentReference],
                    let traineeStudentCourseRef = snap.data()?["traineeStudentCourseRef"] as? [DocumentReference],
                    let trainerRef = snap.data()?["trainerRef"] as? DocumentReference {
                    var nameOfTrainee = ""
                    for item in traineeRef {
                        if nameOfTrainee == "" {
                            nameOfTrainee = (DataServer.studentDic[item.documentID]?.name) ?? item.documentID
                        } else {
                            nameOfTrainee = "\(nameOfTrainee), \((DataServer.studentDic[item.documentID]?.name) ?? item.documentID)"
                        }
                    }
                    
                    let trainerName = (DataServer.trainerDic[trainerRef.documentID]?.name) ?? trainerRef.documentID
                    let trainerRegion = (DataServer.trainerDic[trainerRef.documentID]?.region) ?? .Mississauga
                    
                    if trainerRegion == generalRegion || generalRegion == .All{
                        let dataItem = resultData(title: note, time: date, trainerName: trainerName, studentName: nameOfTrainee, value: prepareCourseNumber(amount), region: trainerRegion)
                        AdminDataModel.DataDic[ref.documentID] = dataItem
                    }
                }
            }
            AdminDataModel.callEnd += 1
        }
    }
}
