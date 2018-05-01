//
//  TrainerMyStudentCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class TrainerMyStudentCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var myStudentsName:[String:String] = [:]
    var nextCourse:[String:[String:Any]] = [:]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppDelegate.AP().myStudentListGeneral.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studentBoard",
                                                      for: indexPath) as! StudentCell
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)

        let studentList = AppDelegate.AP().myStudentListGeneral
        let studentID = studentList[indexPath.row]
        cell.nameLabel.text = myStudentsName[studentID]
        let thisStudentNextCourseDic = nextCourse[studentID]
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .short
        dateFormatter1.timeStyle = .none
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateStyle = .none
        dateFormatter2.timeStyle = .short
        
        if thisStudentNextCourseDic == nil{
            cell.DateTimeLabel.text = "暂无课程"
        } else {
            cell.DateTimeLabel.text = "\((thisStudentNextCourseDic!["Date"] as! Date).getThisWeekDayLongName()) \(dateFormatter2.string(from: (thisStudentNextCourseDic!["Date"] as! Date)))"
        }
        
        
        
        return cell
        
    }
    
    @IBOutlet weak var myStudentCollectionView: UICollectionView!
    
}
