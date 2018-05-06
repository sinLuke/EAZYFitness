//
//  TrainerScanCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class TrainerScanCell: UICollectionViewCell {
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        //dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var report: UIButton!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    var vc:trainerMyStudentVC!
    var studentcoursedocuentref:DocumentReference!
    var trainerdocuentref:DocumentReference!
    var studentID:String!
    
    var rootViewComtroller:DefaultCollectionViewController!

    @IBAction func scaCard(_ sender: Any) {
        scan.scanCard(_vc: rootViewComtroller as! QRCodeReaderViewControllerDelegate)
    }
    
    @IBAction func report(_ sender: Any) {
        vc.startLoading()
        studentcoursedocuentref.getDocument { (snap2, err) in
            if let err = err {
                self.vc.endLoading()
                AppDelegate.showError(title: "记录异常时发生错误", err: err.localizedDescription)
            } else{
                self.trainerdocuentref.collection("Finished").whereField("CourseID", isEqualTo: self.studentcoursedocuentref.documentID).getDocuments { (snap, err) in
                    if let err = err {
                        self.vc.endLoading()
                        AppDelegate.showError(title: "记录异常时发生错误", err: err.localizedDescription)
                    } else{
                        if let amount = snap2?.data()!["Amount"] as? Int, let recorded = snap2?.data()!["Record"] as? Bool{
                            if snap?.documents.count == 0 && recorded == false{
                                
                                let alert = UIAlertController(title: "记录学生没到", message: "请输入该学生未到原因", preferredStyle: .alert)

                                alert.addTextField { (textField) in
                                    textField.placeholder = "请在此处填写原因……"
                                }
                                
                                alert.addAction(UIAlertAction(title: "提交", style: .default, handler: { [weak alert] (_) in
                                    let textField = alert!.textFields![0]
                                    
                                    self.trainerdocuentref.collection("Finished").addDocument(data: ["CourseID" : self.studentcoursedocuentref.documentID, "StudentID": self.studentID, "FinishedType": "Exception", "Note":"学生没来", "Amount":amount, "Date":Date()])
                                    self.studentcoursedocuentref.updateData(["Record" : true])
                                    self.studentcoursedocuentref.updateData(["Type" : "Exception"])
                                    self.studentcoursedocuentref.updateData(["Note" : textField.text])
                                    self.studentcoursedocuentref.updateData(["notrainer" : false])
                                    self.studentcoursedocuentref.updateData(["nostudent" : true])
                                    self.vc.endLoading()
                                }))

                                self.vc.endLoading()
                                AppDelegate.getCurrentVC()?.present(alert, animated: true, completion: nil)
                                
                            } else {
                                self.vc.endLoading()
                                AppDelegate.showError(title: "记录课程时出现问题", err: "该课程已经被记录")
                            }
                        } else {
                            self.vc.endLoading()
                            AppDelegate.showError(title: "记录课程时出现问题", err: "无法获取课时数")
                        }
                    }
                }
            }
        }
    }
}
