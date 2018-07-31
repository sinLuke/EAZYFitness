//
//  AddCourseMasterCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/7/29.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

class AddCourseMasterCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var model: AddCourseDataModel!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.preferedCourseTimeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < self.model.preferedCourseTimeList.count {
            let theCourse = self.model.preferedCourseTimeList.sorted(by: { (arg0, arg1) -> Bool in
                return arg0.value.count > arg1.value.count
            }) [indexPath.row]
            let newCourse = courseReadyItem(date: theCourse.value.date.createDateFromWeekAndTime(), amount: theCourse.value.amount, note: "标准课程", count: 0)
            self.model.courseReadyList.insert(newCourse, at: 0)
            self.model.reload()
            AppDelegate.showWarning(title: "添加成功", err: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCoureseCourseCell", for: indexPath) as! AddCoureseCourseCell
        if indexPath.row < self.model.preferedCourseTimeList.count {
            let theCourse = self.model.preferedCourseTimeList.sorted(by: { (arg0, arg1) -> Bool in
                return arg0.value.count > arg1.value.count
            }) [indexPath.row]
            cell.theCourse = theCourse.value
            
        }
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.reload()
        return cell
    }
}
