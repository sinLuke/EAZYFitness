//
//  EFStudentPersonal.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFStudentPersonal: EFData {
    var recordKey:String!
    var recordValue:Float!
    var date:Date!

    func getValue(with unit:String) -> String{
        switch recordKey{
        case "HEIGHT":
            switch unit {
            case "meter":
                let meter = recordValue/100
                return "\(String(format: "%.0f", meter))米\(String(format: "%.0f", meter.truncatingRemainder(dividingBy: 100)))"
            case "inch":
                let inch = recordValue*0.393700787
                return "\(String(format: "%.0f", inch/12))尺\(String(format: "%.0f", inch.truncatingRemainder(dividingBy: 12)))"
            default:
                return "\(String(format: "%.0f", recordValue))厘米"
            }
        case "WEIGHT":
            switch unit {
            case "pound":
                let pound = recordValue*2.20462262
                return "\(String(format: "%.2f", pound))英磅"
            case "jin":
                let jin = recordValue*2
                return "\(String(format: "%.2f", jin))斤"
            default:
                return "\(String(format: "%.0f", recordValue))公斤)"
            }
        default:
            return "数据错误"
        }
    }
}
