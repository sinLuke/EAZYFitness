//
//  EFViewCellWithTrainerCourseStudentStatus.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFViewCellWithTrainerCourseStudentStatus: UICollectionViewCell {

    @IBOutlet weak var StatusLabel: UILabel!
    
    @IBOutlet weak var StatusView: UIView!
    @IBOutlet weak var reportBtn: UIButton!
    
    @IBOutlet weak var StatusFootNote: UILabel!
    @IBOutlet weak var widthOdCell: NSLayoutConstraint!
    
    var vc:trainerCourseVC!
    
    var studentCourse: EFStudentCourse!
    
    var statusCircleColor: HexColor? {
        set (color) {
            if color == nil {
                StatusView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
                StatusView.backgroundColor = UIColor.white
            } else {
                StatusView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
                StatusView.backgroundColor = color!
            }
        } get {
            return HexColor.Blue
        }
    }
    
    @IBAction func reportStudent(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "请选择\(StatusLabel.text ?? "该学生")的情况", preferredStyle: .actionSheet)
        
        let illAction = UIAlertAction(title: "生病", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.studentCourse.status = .ill
            self.studentCourse.upload()
            self.vc.refresh()
        })
        
        let noCardAction = UIAlertAction(title: "没带卡", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.studentCourse.status = .noCard
            self.studentCourse.upload()
            self.vc.refresh()
        })
        
        let noStudentAction = UIAlertAction(title: "没来", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.studentCourse.status = .noStudent
            self.studentCourse.upload()
            self.vc.refresh()
        })
        
        let otherAction = UIAlertAction(title: "其他情况……", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let alertField = UIAlertController(title: "为\(self.StatusLabel.text ?? "该学生")", message: "记录特殊情况", preferredStyle: .alert)
        
            alertField.addTextField { (textField) in
                textField.placeholder = "请在这里输入具体的情况"
            }
            
            alertField.addAction(UIAlertAction(title: "提交", style: .default, handler: { [weak alertField] (_) in
                let textField = alertField?.textFields![0]
                self.studentCourse.status = .other
                self.studentCourse.note = textField?.text ?? "未知情况"
                self.studentCourse.upload()
                self.vc.refresh()
            }))
            
            alertField.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { [weak alertField] (_) in
                self.vc.present(optionMenu, animated: true, completion: nil)
                self.vc.refresh()
            }))
            
            self.vc.present(alertField, animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(illAction)
        optionMenu.addAction(noCardAction)
        optionMenu.addAction(noStudentAction)
        optionMenu.addAction(otherAction)
        
        optionMenu.addAction(cancelAction)
        
        self.vc.present(optionMenu, animated: true, completion: nil)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.reportBtn.layer.cornerRadius = 5
        self.reportBtn.clipsToBounds = true
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthOdCell.constant = screenWidth - (2 * 12)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        StatusView.layer.cornerRadius = 8
        StatusView.layer.borderWidth = 1
        
    }
}
