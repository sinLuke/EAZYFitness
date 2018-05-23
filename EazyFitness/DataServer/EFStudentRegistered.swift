//
//  EFStudentRegistered.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFStudentRegistered: EFData {
    var amount:Int!
    var date:Date!
    var approved:Bool!
    var note:String!
    var amountString:String{
        get {
            let float = Float(amount)/2.0
            if amount%2 == 0{
                return String(format: "%.0f", float)
            } else {
                return String(float)
            }
        }
    }
    var dateString:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        return "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"
    }
}
