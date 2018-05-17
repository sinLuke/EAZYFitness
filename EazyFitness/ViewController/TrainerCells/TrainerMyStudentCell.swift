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
    var nextCourse:[String:ClassObj] = [:]
    var vc:trainerMyStudentVC!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppDelegate.AP().studentList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studentBoard",
                                                      for: indexPath) as! StudentCell
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)

        let studentID = AppDelegate.AP().studentList[indexPath.row].documentID
        cell.nameLabel.text = myStudentsName[studentID]
        let thisStudentNextCourseDic = nextCourse[studentID]
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .short
        dateFormatter1.timeStyle = .none
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateStyle = .none
        dateFormatter2.timeStyle = .short
        
        cell.vc = self.vc
        cell.MemberID = studentID
        
        if thisStudentNextCourseDic == nil{
            cell.DateTimeLabel.text = "暂无课程"
        } else {
            cell.DateTimeLabel.text = "\((thisStudentNextCourseDic!.date).getThisWeekDayLongName()) \(dateFormatter2.string(from: (thisStudentNextCourseDic!.date)))"
        }
        return cell
    }
    
    @IBOutlet weak var myStudentCollectionView: UICollectionView!
    
}
