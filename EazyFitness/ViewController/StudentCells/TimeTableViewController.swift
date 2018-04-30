//
//  TimeTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

extension Date {
    func startOfWeek() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfWeek() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 7), to: self.startOfWeek())!
    }
}

class TimeTableViewController: UIViewController {
    
    var timetableDic: [String:[[Int]]] = ["mon":[[]], "tue":[[]], "wed":[[]], "thu":[[]], "fri":[[]], "sat":[[]], "sun":[[]]]
    var collectionRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionRef.whereField("Data", isGreaterThan: Date().startOfWeek).whereField("Data", isLessThan: Date().endOfWeek()).getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取课程表时出错", err: err.localizedDescription)
            } else {
                for doc in snap!.documents{
                    if let startTime = doc.data()["Date"] as? Date, let duration = doc.data()["Amount"] as? Int{
                        let numberHour:Int = Calendar.current.component(.hour, from: startTime)*100 + Calendar.current.component(.minute, from: startTime)
                        
                        self.ListOfCourse.append([numberHour, duration])
                    }
                }
                
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
