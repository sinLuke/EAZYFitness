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
}
