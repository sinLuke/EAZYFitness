//
//  TimeTable.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/28.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

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
    static let HORZAONRATIO:CGFloat = 7
    static let LEFTWIDTH:CGFloat = 47
    static let TOPHEIGHT:CGFloat = 34
    
    var numberOfStudent:Int!
    var finishedStudent:Int = 0
    
    static var currentTimeTabel:TimeTable?
    
    func LoadFinished(view:TimeTableView, timetable:[String: [String:[[Int]]]], handeler:(_:CGFloat)->()){
        finishedStudent += 1
        if finishedStudent >= numberOfStudent{
            handeler(TimeTable.makeTimeTable(on: view, with: timetable))
        }
    }
    
    class func makeTimeTable(on view:TimeTableView, withRef _collectionRef:[String:CollectionReference], handeler: @escaping (_:CGFloat)->()){
        
        print("makeTimeTable")
        
        currentTimeTabel = TimeTable()
        currentTimeTabel!.numberOfStudent = _collectionRef.keys.count
        view.backgroundColor = UIColor.white
        var timetableDicWithName: [String: [String:[[Int]]]] = [:]
        for names in Array(_collectionRef.keys){
            if let collectionRef = _collectionRef[names]{
                var timetableDic: [String:[[Int]]] = ["mon":[[]], "tue":[[]], "wed":[[]], "thu":[[]], "fri":[[]], "sat":[[]], "sun":[[]]]
                collectionRef.whereField("Date", isGreaterThan: Date().startOfWeek()).whereField("Date", isLessThan: Date().endOfWeek()).whereField("Approved", isEqualTo: true).getDocuments { (snap, err) in
                    if let err = err{
                        AppDelegate.showError(title: "读取课程表时出错", err: err.localizedDescription)
                    } else {
                        for doc in snap!.documents{
                            if let startTime = doc.data()["Date"] as? Date, let duration = doc.data()["Amount"] as? Int{
                                
                                let numberHour:Int = Calendar.current.component(.hour, from: startTime)*100 + Calendar.current.component(.minute, from: startTime)
                                let weekDayName = Date.weekName[Calendar.current.component(.weekday, from: startTime)]
                                if var oldList = timetableDic[weekDayName]{
                                    oldList.append([numberHour, duration])
                                    timetableDic.updateValue(oldList, forKey: weekDayName)
                                }
                            }
                        }
                        timetableDicWithName.updateValue(timetableDic, forKey: names)
                        currentTimeTabel?.LoadFinished(view: view, timetable: timetableDicWithName, handeler:handeler)
                    }
                }
            } else {
            }
        }
    }
    
    class func makeTimeTable(on view:TimeTableView, with timetable:[String: [String:[[Int]]]], colorList:[UIColor]? = HexColor.colorList) -> CGFloat{
        let timetableList = Array(timetable.values)
        
        let (timeScope, startTime) = TimeTable.findTimeScope(timetable: (timetableList))
        
        if timeScope == 0 {
            return 0
        }
        
        view.background = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.topView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: TOPHEIGHT))
        view.topView!.backgroundColor = UIColor.gray
        
        for i in 0...7{
            let _i = CGFloat(i)
            let singleDayView = UIView(frame: CGRect(x: LEFTWIDTH+(_i-1)*((view.frame.width-LEFTWIDTH)/HORZAONRATIO), y: TOPHEIGHT, width: (view.frame.width-LEFTWIDTH)/HORZAONRATIO, height: (VERTICALRATIO-1)*TOPHEIGHT))
            let singleDayLabel = UILabel(frame: CGRect(x: LEFTWIDTH + (_i-1)*((view.frame.width-LEFTWIDTH)/HORZAONRATIO) + 375*0.01, y: 667*0.005, width: (view.frame.width-LEFTWIDTH)/HORZAONRATIO-375*0.02, height: TOPHEIGHT-667*0.01))
            singleDayLabel.numberOfLines = 1
            singleDayLabel.adjustsFontSizeToFitWidth = true
            singleDayLabel.textColor = UIColor.white
            singleDayLabel.textAlignment = .center
            
            var count = 0
            for eachTimetable in Array(timetable.keys){
                let _DicForOneStudent = timetable[eachTimetable]
                if let DicForOneStudent = _DicForOneStudent{
                    for eachDay in Array(DicForOneStudent.keys){
                        var weekDay = Date.getWeekDayNumber(str: eachDay)
                        if let _courseTimeList = DicForOneStudent[eachDay]{
                            for courseTimeList in _courseTimeList{
                                if courseTimeList.count >= 2{
                                    if (weekDay == i) && (courseTimeList[1] != 0){
                                        
                                        let value1 = CGFloat((courseTimeList[0]/100)*100 + (courseTimeList[0]%100)*100/60)-CGFloat(startTime*100)
                                        let height = CGFloat(courseTimeList[1])*CGFloat(view.eachTimeScopeHeight)/2
                                        let CourseView = UIView(frame: CGRect(x: 0, y: (value1)*view.eachTimeScopeHeight/100 + view.eachTimeScopeHeight/2, width: (view.frame.width-LEFTWIDTH)/7, height: height))
                                        CourseView.backgroundColor = colorList![count%HexColor.colorList.count]
                                        
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
                }
                count += 1
            }
            if i == 0{
                singleDayLabel.text = ""
                singleDayView.backgroundColor = UIColor.gray
                
                singleDayView.frame = CGRect(x: 0, y: TOPHEIGHT, width: LEFTWIDTH, height: singleDayView.frame.height)
                
                for j in 0...timeScope - 1{
                    let _j = CGFloat(j)
                    
                    let eachTimeScopeLabel = UILabel(frame: CGRect(x: 375*0.01, y: _j*view.eachTimeScopeHeight, width: LEFTWIDTH - 375*0.02, height: view.eachTimeScopeHeight))
                    
                    eachTimeScopeLabel.text = "\(j+startTime)"
                    if j+startTime == 12{
                        eachTimeScopeLabel.text = "上午\n下午"
                    }
                    eachTimeScopeLabel.textColor = UIColor.white
                    eachTimeScopeLabel.lineBreakMode = .byWordWrapping
                    eachTimeScopeLabel.numberOfLines = 0
                    eachTimeScopeLabel.adjustsFontSizeToFitWidth = true
                    eachTimeScopeLabel.textAlignment = .center
                    view.timeScopeLabelList.append(eachTimeScopeLabel)
                    singleDayView.addSubview(eachTimeScopeLabel)
                    
                    let hourLine = UIView(frame: CGRect(x: LEFTWIDTH, y: TOPHEIGHT + (_j+1)*view.eachTimeScopeHeight - view.eachTimeScopeHeight/2, width: view.frame.width-LEFTWIDTH, height: 1))
                    hourLine.backgroundColor = UIColor.gray
                    view.background.addSubview(hourLine)
                    
                    let hourLine2 = UIView(frame: CGRect(x: LEFTWIDTH, y: TOPHEIGHT + (_j+1)*view.eachTimeScopeHeight - view.eachTimeScopeHeight, width: view.frame.width-LEFTWIDTH, height: 1))
                    hourLine2.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
                    view.background.addSubview(hourLine2)
                    
                    let hourLine3 = UIView(frame: CGRect(x: LEFTWIDTH, y: TOPHEIGHT + (_j+1)*view.eachTimeScopeHeight - view.eachTimeScopeHeight/4, width: view.frame.width-LEFTWIDTH, height: 1))
                    hourLine3.backgroundColor = UIColor.gray.withAlphaComponent(0.05)
                    view.background.addSubview(hourLine3)
                    
                    let hourLine4 = UIView(frame: CGRect(x: LEFTWIDTH, y: TOPHEIGHT + (_j+1)*view.eachTimeScopeHeight - view.eachTimeScopeHeight*3/4, width: view.frame.width-LEFTWIDTH, height: 1))
                    hourLine4.backgroundColor = UIColor.gray.withAlphaComponent(0.05)
                    view.background.addSubview(hourLine4)
                }
            }
            
            singleDayLabel.text = Date.weekLongName[i]
            if (i%2 == 0) && (i != 0){
                singleDayView.backgroundColor = HexColor.lightColor
            }
            if (Date().findDateToday())%7 == i{
                singleDayLabel.text = "今天"
                singleDayView.backgroundColor = HexColor.Blue.withAlphaComponent(0.15)
            }
            
            view.viewForEachDay.append(singleDayView)
            
            view.addSubview(singleDayView)
            view.topView!.addSubview(singleDayLabel)
            
            view.addSubview(view.topView!)
            view.addSubview(view.background)
        }
        
        let maxHeight = CGFloat(view.eachTimeScopeHeight) * CGFloat(timeScope) + CGFloat(TOPHEIGHT)
        
        for views in view.viewForEachDay{
            views.frame =  CGRect(x: views.frame.minX, y: views.frame.minY, width: views.frame.width, height: maxHeight)
        }
        
        return maxHeight
        
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
                if let timelist = eachTimetable[eachDay]{
                    for eachCourse in timelist{
                        if eachCourse.count >= 2{
                            if eachCourse[1] == 0{
                            } else {
                                if minTime > eachCourse[0]{
                                    minTime = eachCourse[0]
                                }
                                if maxTime < eachCourse[0]+((eachCourse[1])/2)*100 + ((eachCourse[1]%2)*30){
                                    maxTime = eachCourse[0]+((eachCourse[1])/2)*100 + ((eachCourse[1]%2)*30)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        if maxTime < minTime{
            return (0,0)
        }
        let minTableTime = max(minTime/100, 0)
        let maxTableTime = min((maxTime+100)/100, 24)
        return ((maxTableTime - minTableTime + 1), minTableTime)
    }
}
