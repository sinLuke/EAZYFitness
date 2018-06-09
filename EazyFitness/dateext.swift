import UIKit
import Foundation

extension Date {
    static let weekName = ["err", "sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    static let weekLongName = [" ", "周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    
    func startOfTheDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func startOfWeek() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfWeek() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 7), to: self.startOfWeek())!
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func getThisWeekDayName()->String{
        return Date.weekName[Calendar.current.component(.weekday, from: self)]
    }
    
    func getThisWeekDayLongName()->String{
        return Date.weekLongName[Calendar.current.component(.weekday, from: self)]
    }
    
    func getThisWeekDayNumber()->Int{
        return Calendar.current.component(.weekday, from: self)
    }
    
    static func getWeekDayNumber(str:String) -> Int?{
        for i in 1...7{
            if Date.weekName[i] == str {
                return i
            }
        }
        return nil
    }
    
    var TimeString:String {
        get {
            let df = DateFormatter()
            df.timeStyle = .short
            df.dateStyle = .none
            return df.string(from: self)
        }
    }
    
    var DateString:String {
        get {
            let thisComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)
            let nowComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
            if thisComponents.year != nowComponents.year {
                return "\(thisComponents.year!)年\(thisComponents.month!)月\(thisComponents.day!)日 \(self.getThisWeekDayLongName())"
            } else {
                return "\(thisComponents.month!)月\(thisComponents.day!)日 \(self.getThisWeekDayLongName())"
            }
        }
    }
    
    func descriptDate() -> String {
        let now = Date()
        let thisComponents = Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: self)
        let nowComponents = Calendar.current.dateComponents([.day, .month, .weekOfYear, .year], from: now)
        let df = DateFormatter()
        let min:TimeInterval = 1000/16
        let hour:TimeInterval = min*60
        let day:TimeInterval = hour*24
        df.timeStyle = .short
        df.dateStyle = .none
        if self > now{
            let components = Calendar.current.dateComponents([.minute, .hour, .day, .year], from: now, to: self)
            
            if thisComponents.year! - nowComponents.year! > 0 && self.timeIntervalSinceNow >= day*6 {
                return "\(thisComponents.year!)年\(thisComponents.month!)月\(thisComponents.day!)日"
            } else if thisComponents.weekOfYear! - nowComponents.weekOfYear! > 1  && self.timeIntervalSinceNow >= day*6{
                return "\(thisComponents.month!)月\(thisComponents.day!)日 \(df.string(from: self))"
            } else if thisComponents.weekOfYear! - nowComponents.weekOfYear! == 1 {
                return "下\(self.getThisWeekDayLongName()) \(df.string(from: self))"
            } else if thisComponents.day! - nowComponents.day! > 1{
                return "\(self.getThisWeekDayLongName()) \(df.string(from: self))"
            } else if thisComponents.day! - nowComponents.day! == 1{
                return "明天 \(df.string(from: self))"
            } else if components.hour! > 3{
                return "今天 \(df.string(from: self))"
            } else if components.hour! != 0{
                return "\(components.hour!)小时 \(components.minute!) 分钟后"
            } else if components.minute! >= 2{
                return "\(components.minute!) 分钟后"
            } else {
                return "马上"
            }
        } else if self < now {
            let components = Calendar.current.dateComponents([.minute, .hour, .day, .year], from: self, to: now)
            if nowComponents.year! - thisComponents.year! > 0 && Date().timeIntervalSince(self) >= day*6 {
                return "\(thisComponents.year!)年\(thisComponents.month!)月"
            } else if nowComponents.weekOfYear! - thisComponents.weekOfYear! > 1 && Date().timeIntervalSince(self) >= day*6{
                return "\(thisComponents.month!)月\(thisComponents.day!)日"
            } else if nowComponents.weekOfYear! - thisComponents.weekOfYear! == 1 {
                return "上\(self.getThisWeekDayLongName())"
            } else if nowComponents.day! - thisComponents.day! > 1{
                return "\(self.getThisWeekDayLongName())"
            } else if nowComponents.day! - thisComponents.day! == 1 && Date().timeIntervalSince(self) >= hour*3 {
                return "昨天 \(df.string(from: self))"
            } else if components.hour! > 3{
                return "今天 \(df.string(from: self))"
            } else if components.hour! != 0{
                return "\(components.hour!)小时前"
            } else if components.minute! >= 2{
                return "\(components.minute!) 分钟前"
            } else {
                return "刚刚"
            }
        } else {
            return "现在"
        }
    }
}
