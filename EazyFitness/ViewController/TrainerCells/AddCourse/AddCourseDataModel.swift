//
//  AddCourseDataModel.swift
//  EazyFitness
//
//  Created by Luke on 2018/7/29.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

struct preferedCourseTime{
    var date: Date
    var amount: Int
    var count: Int
}

extension preferedCourseTime: Equatable {
    static func == (lhs: preferedCourseTime, rhs: preferedCourseTime) -> Bool {
        return lhs.date == rhs.date &&
            lhs.amount == rhs.amount
    }
}

extension preferedCourseTime: Hashable {
    var hashValue: Int {
        return date.hashValue ^ amount.hashValue
    }
}

struct courseReadyItem{
    var date: Date
    var amount: Int
    var note: String
}


class AddCourseDataModel: NSObject {
    var studentList: [EFStudent]
    var trainer: EFTrainer
    var preferedCourseTimeList: [Int: preferedCourseTime] = [:]
    var courseReadyList: [courseReadyItem] = []
    init(studentList: [EFStudent], trainer: EFTrainer) {
        self.studentList = studentList
        self.trainer = trainer
        for student in studentList {
            for studentCourse in student.courseDic.values {
                if let course = DataServer.courseDic[studentCourse.courseRef.documentID]{
                    let preferedCourseTimeItem = preferedCourseTime(date: course.date, amount: course.amount, count: 1)
                    if self.preferedCourseTimeList[preferedCourseTimeItem.hashValue] != nil {
                        self.preferedCourseTimeList[preferedCourseTimeItem.hashValue]?.count += 1
                    } else {
                        self.preferedCourseTimeList[preferedCourseTimeItem.hashValue] = preferedCourseTimeItem
                    }
                }
            }
        }
    }
}
