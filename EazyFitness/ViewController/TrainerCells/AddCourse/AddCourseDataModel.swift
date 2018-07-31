//
//  AddCourseDataModel.swift
//  EazyFitness
//
//  Created by Luke on 2018/7/29.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

struct courseReadyItem{
    var date: Date
    var amount: Int
    var note: String?
    var count: Int
}

extension courseReadyItem: Equatable {
    static func == (lhs: courseReadyItem, rhs: courseReadyItem) -> Bool {
        return lhs.date == rhs.date &&
            lhs.amount == rhs.amount
    }
}

extension courseReadyItem: Hashable {
    var hashValue: Int {
        return date.hashValue ^ amount.hashValue
    }
}


class AddCourseDataModel: NSObject {
    var studentList: [EFStudent]
    var trainer: EFTrainer
    var preferedCourseTimeList: [Int: courseReadyItem] = [:]
    var courseReadyList: [courseReadyItem] = []
    init(studentList: [EFStudent], trainer: EFTrainer) {
        self.studentList = studentList
        self.trainer = trainer
        for student in studentList {
            for studentCourse in student.courseDic.values {
                if let course = DataServer.courseDic[studentCourse.courseRef.documentID]{
                    let preferedCourseTimeItem = courseReadyItem(date: course.date, amount: course.amount, note: nil, count: 1)
                    if self.preferedCourseTimeList[preferedCourseTimeItem.hashValue] != nil {
                        self.preferedCourseTimeList[preferedCourseTimeItem.hashValue]?.count += 1
                    } else {
                        self.preferedCourseTimeList[preferedCourseTimeItem.hashValue] = preferedCourseTimeItem
                    }
                }
            }
        }
    }
    
    var refreshRootViewController: refreshableVC!
    
    func reload(){
        refreshRootViewController.reload()
    }
}
