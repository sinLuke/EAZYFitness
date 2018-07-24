//
//  TrainerScanCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents
class TrainerScanCell: MDCCardCollectionCell {
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        //dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var report: UIButton!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    var vc:trainerMyStudentVC!
    
    var thisStudent:EFStudent!
    var thisStudentCourse:EFStudentCourse!
    var trainer:EFTrainer!
    
    var rootViewComtroller:DefaultCollectionViewController!

    @IBAction func scaCard(_ sender: Any) {
        scan.scanCard(_vc: rootViewComtroller as! QRCodeReaderViewControllerDelegate)
    }
    
    @IBAction func report(_ sender: Any) {
        
        trainer.finishACourse(By: thisStudentCourse.courseRef)
        let alert = UIAlertController(title: "记录学生没到", message: "请选择该学生未到原因", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "生病", style: .default, handler: { (action) in
            self.thisStudentCourse.status = .ill

            self.thisStudentCourse.upload()
        }))
        alert.addAction(UIAlertAction(title: "没来", style: .default, handler: { (action) in
            self.thisStudentCourse.status = .noStudent

            self.thisStudentCourse.upload()
        }))
        alert.addAction(UIAlertAction(title: "没带卡", style: .default, handler: { (action) in
            self.thisStudentCourse.status = .noCard

            self.thisStudentCourse.upload()
        }))
        alert.addAction(UIAlertAction(title: "其他原因", style: .default, handler: { (action) in
            self.thisStudentCourse.status = .other

            let alert = UIAlertController(title: "记录学生没到", message: "请输入该学生未到原因", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "请在此处填写备注……"
            }
            alert.addAction(UIAlertAction(title: "提交", style: .default, handler: { (action) in
                for textfield in alert.textFields!{
                    self.thisStudentCourse.note = textfield.text ?? "原因未注明"
                    self.thisStudentCourse.status = .other
                    self.thisStudentCourse.upload()
                }
            }))
            self.vc.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in

        }))
        vc.present(alert, animated: true, completion: nil)
    }
}
