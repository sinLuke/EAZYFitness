//
//  TimeTable.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/28.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
extension Date {
    func findDateToday() -> Int{
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let calendarUnit = NSCalendar.Unit.weekday
        let theComponents = calendar?.components(calendarUnit, from:self)
        return (theComponents?.weekday)!
    }
}
class TimeTable: NSObject {
    
    static let dateToday = 0
    
    static let VERTICALRATIO:CGFloat = 20
    static let HORZAONRATIO:CGFloat = 8
    
    class func makeTimeTable(on view:UIView, with timetable:[String: [String:[[Int]]]]){
        let timetableList = Array(timetable.values)
        
        let (timeScope, startTime) = TimeTable.findTimeScope(timetable: (timetableList))
        let MaxWidth = view.frame.width
        let MaxHeight = view.frame.height
        
        let eachTimeScopeHeight = (9*MaxHeight/10)/CGFloat(timeScope)
        
        var viewForEachDay:[UIView] = []
        var topView:UIView
        var background:UIView
        var DayLabele:[UILabel] = []
        var timeScopeLabelList:[UILabel] = []
        var CourseViewList:[UIView] = []
        
        background = UIView(frame: CGRect(x: 0, y: 0, width: MaxWidth, height: MaxHeight))
        topView = UIView(frame: CGRect(x: MaxWidth/HORZAONRATIO, y: 0, width: MaxWidth-MaxWidth/HORZAONRATIO, height: MaxHeight/VERTICALRATIO))
        topView.backgroundColor = UIColor.gray
        
        for i in 0...7{
            let _i = CGFloat(i)
            let singleDayView = UIView(frame: CGRect(x: _i*(MaxWidth/HORZAONRATIO), y: MaxHeight/VERTICALRATIO, width: MaxWidth/8, height: (VERTICALRATIO-1)*MaxHeight/VERTICALRATIO))
            let singleDayLabel = UILabel(frame: CGRect(x: (_i-1)*(MaxWidth/HORZAONRATIO) + MaxWidth*0.01, y: MaxHeight*0.005, width: MaxWidth/HORZAONRATIO-MaxWidth*0.02, height: MaxHeight/VERTICALRATIO-MaxHeight*0.01))
            singleDayLabel.numberOfLines = 1
            singleDayLabel.adjustsFontSizeToFitWidth = true
            singleDayLabel.textColor = UIColor.white
            singleDayLabel.textAlignment = .center
            
            var count = 0
            for eachTimetable in Array(timetable.keys){
                let _DicForOneStudent = timetable[eachTimetable]
                if let DicForOneStudent = _DicForOneStudent{
                    for eachDay in Array(DicForOneStudent.keys){
                        var weekDay = 1
                        switch eachDay{
                        case "mon":
                            weekDay = 2
                        case "tue":
                            weekDay = 3
                        case "wed":
                            weekDay = 4
                        case "thu":
                            weekDay = 5
                        case "fri":
                            weekDay = 6
                        case "sat":
                            weekDay = 7
                        case "sun":
                            weekDay = 1
                        default:
                            weekDay = 1
                        }
                        if let _courseTimeList = DicForOneStudent[eachDay] as? [[Int]]{
                            for courseTimeList in _courseTimeList{
                                if (weekDay == i) && (courseTimeList[1] != 0){
                                    let value1 = CGFloat(courseTimeList[0])-CGFloat(startTime*100)
                                    let height = CGFloat(courseTimeList[1])*CGFloat(eachTimeScopeHeight)/2
                                    let CourseView = UIView(frame: CGRect(x: 0, y: (value1)*eachTimeScopeHeight/100 + eachTimeScopeHeight/2, width: MaxWidth/8, height: height))
                                    CourseView.backgroundColor = HexColor.colorList[count%HexColor.colorList.count]
                                    
                                    let courseLabel = UILabel(frame: CGRect(x: 0, y: 0, width: CourseView.frame.width, height: CourseView.frame.height))
                                    courseLabel.text = "\(eachTimetable)"
                                    courseLabel.adjustsFontSizeToFitWidth = true
                                    courseLabel.textAlignment = .center
                                    courseLabel.textColor = UIColor.white
                                    CourseView.addSubview(courseLabel)
                                    singleDayView.addSubview(CourseView)
                                }
                            }
                        }
                    }
                }
                count += 1
            }
            
            switch i{
            case 0:
                singleDayLabel.text = ""
                singleDayView.backgroundColor = UIColor.gray
                
                for j in 0...timeScope-1{
                    let _j = CGFloat(j)
                    
                    let eachTimeScopeLabel = UILabel(frame: CGRect(x: MaxWidth*0.01, y: MaxHeight*0.005 + _j*eachTimeScopeHeight, width: MaxWidth/HORZAONRATIO - MaxWidth*0.02, height: eachTimeScopeHeight - MaxHeight*0.01))
                    
                    eachTimeScopeLabel.text = "\(j+startTime)"
                    eachTimeScopeLabel.textColor = UIColor.white
                    eachTimeScopeLabel.lineBreakMode = .byWordWrapping
                    eachTimeScopeLabel.numberOfLines = 1
                    eachTimeScopeLabel.adjustsFontSizeToFitWidth = true
                    eachTimeScopeLabel.textAlignment = .center
                    timeScopeLabelList.append(eachTimeScopeLabel)
                    singleDayView.addSubview(eachTimeScopeLabel)
                    
                    let hourLine = UIView(frame: CGRect(x: MaxWidth/8, y: MaxHeight/VERTICALRATIO + _j*eachTimeScopeHeight - eachTimeScopeHeight/2, width: MaxWidth, height: 1))
                    hourLine.backgroundColor = UIColor.gray
                    background.addSubview(hourLine)
                }
                
            case 2:
                singleDayLabel.text = "一"
            case 3:
                singleDayLabel.text = "二"
                singleDayView.backgroundColor = HexColor.lightColor
            case 4:
                singleDayLabel.text = "三"
            case 5:
                singleDayLabel.text = "四"
                singleDayView.backgroundColor = HexColor.lightColor
            case 6:
                singleDayLabel.text = "五"
            case 7:
                singleDayLabel.text = "六"
                singleDayView.backgroundColor = HexColor.weekEndColor
            case 1:
                singleDayLabel.text = "日"
                singleDayView.backgroundColor = HexColor.weekEndLightColor
            default:
                continue
            }
            
            if (Date().findDateToday())%7 == i{
                singleDayLabel.text = "今天"
            }
            
            viewForEachDay.append(singleDayView)
            
            view.addSubview(singleDayView)
            topView.addSubview(singleDayLabel)
            
            view.addSubview(topView)
            view.addSubview(background)
        }
    }
    
    class func isValidTime(timeNumber:Int) -> Bool{
        
        return (timeNumber>=0 && timeNumber<=2400) && (timeNumber%100 < 60)
    }
    
    class func convertTimeIntoString(timeNumber:Int) -> String{
        if TimeTable.isValidTime(timeNumber: timeNumber){
            let hour = timeNumber/100
            let min = (timeNumber%100)
            var am = "AM"
            var returnHour = 0
            if (hour/12 == 0) {
                am = "AM"
                returnHour = hour%12
            } else {
                am = "PM"
                if hour%12 == 0{
                    returnHour = 12
                } else {
                    returnHour = hour%12
                }
            }
            
            return "\(returnHour):\(String(format: "%02d", min)) \(am)"
        } else {
            return "ERRRO"
        }
    }
    
    class func convertHourIntoString(timeNumber:Int) -> String{
        if TimeTable.isValidTime(timeNumber: timeNumber){
            let hour = timeNumber/100
            let min = (timeNumber%100)
            var am = "AM"
            var returnHour = 0
            if (hour/12 == 0) {
                am = "AM"
                returnHour = hour%12
            } else {
                am = "PM"
                if hour%12 == 0{
                    returnHour = 12
                } else {
                    returnHour = hour%12
                }
            }
            
            return "\(returnHour) \(am)"
        } else {
            return "ERRRO"
        }
    }

    class func findTimeScope(timetable:[[String:[[Int]]]]) -> (Int, Int){

        var minTime = 2400
        var maxTime = 0
        
        for eachTimetable in timetable{
            for eachDay in Array(eachTimetable.keys){
                if let timelist = eachTimetable[eachDay] as? [[Int]]{
                    for eachCourse in timelist{
                        if eachCourse[1] == 0{
                        } else {
                            if minTime > eachCourse[0]{
                                minTime = eachCourse[0]
                            }
                            if maxTime < eachCourse[0]{
                                maxTime = eachCourse[0]+((eachCourse[1])/2)*100 + ((eachCourse[1]%2)*30)
                            }
                        }
                    }
                }
            }
        }
        if maxTime < minTime{
            return (0,0)
        }
        let minTableTime = minTime/100
        let maxTableTime = (maxTime+1)/100
        return ((maxTableTime - minTableTime + 1), minTableTime)
    }
}
