//
//  StudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/24.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

class StudentVC: UICollectionViewController, refreshableVC, UICollectionViewDelegateFlowLayout {
    
    let _refreshControl = UIRefreshControl()
    
    var db:Firestore!
    var CourseRegisteredNumber:Int = 0
    var TotalCourseFinished:Int = 0
    var MonthCourseFinished:Int = 0
    var requestTextDic:[String:String] = [:]
    var requestTimeDic:[String:Date] = [:]
    var requestTimeEndDic:[String:Date] = [:]
    var requestDBREFDic:[String:DocumentReference] = [:]
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    func refresh() {
        print("refresh")
        if let cMemberID = AppDelegate.AP().currentMemberID{
            let dbref = db.collection("student").document(cMemberID)
            
            //读取总课时
            dbref.collection("CourseRegistered").whereField("Approved", isEqualTo: true).getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取总课时时发生错误", err: err.localizedDescription)
                } else {
                    self.CourseRegisteredNumber = 0
                    for allDocs in snap!.documents{
                        self.CourseRegisteredNumber += allDocs.data()["Amount"] as! Int
                    }
                    self.collectionView?.reloadData()
                }
            }
            
            //读取完成课时
            dbref.collection("CourseRecorded").whereField("Record", isEqualTo: true).getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取已完成课时时发生错误", err: err.localizedDescription)
                } else {
                    self.TotalCourseFinished = 0
                    for allDocs in snap!.documents{
                        self.TotalCourseFinished += allDocs.data()["Amount"] as! Int
                    }
                    self.collectionView?.reloadData()
                }
            }
            
            //读取当月完成
            dbref.collection("CourseRecorded").whereField("Record", isEqualTo: true).whereField("Date", isGreaterThan: Date().startOfMonth()).getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取当月已完成课时时发生错误", err: err.localizedDescription)
                } else {
                    self.MonthCourseFinished = 0
                    for allDocs in snap!.documents{
                        self.MonthCourseFinished += allDocs.data()["Amount"] as! Int
                    }
                    self.collectionView?.reloadData()
                }
            }
            
            //获取申请
            dbref.collection("CourseRecorded").whereField("Approved", isEqualTo: false).getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取申请信息时发生错误", err: err.localizedDescription)
                } else {
                    self.requestTextDic = [:]
                    self.requestTimeDic = [:]
                    self.requestTimeEndDic = [:]
                    
                    for allDocs in snap!.documents{
                        
                        if let Notetext = allDocs.data()["Note"] as? String, let startTime = allDocs.data()["Date"] as? Date, let AmountOffset = allDocs.data()["Amount"] as? Int{
                            let calendar = Calendar.current
                            if let endTime = calendar.date(byAdding: .minute, value: AmountOffset*30, to: startTime){
                                self.requestTextDic.updateValue(Notetext, forKey: allDocs.documentID)
                                self.requestTimeDic.updateValue(startTime, forKey: allDocs.documentID)
                                self.requestTimeEndDic.updateValue(endTime, forKey: allDocs.documentID)
                                self.requestDBREFDic.updateValue(allDocs.reference, forKey: allDocs.documentID)
                            }
                        }
                    }
                    self.collectionView?.reloadData()
                }
            }
        }
        
    }
    
    func reload() {
        self.collectionView?.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        self.refresh()
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.collectionView!.refreshControl = self._refreshControl
        self.collectionView!.addSubview(self._refreshControl)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var studentInfo: NSDictionary?
    var MemberID: Int!
    var ref: DatabaseReference!
    
    var firstName = ""
    var lastName = ""
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == requestTextDic.keys.count {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 200)
        } else {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3 + requestTextDic.keys.count
    }

    
    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row{
        case requestTextDic.keys.count:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableBoard",
                                                          for: indexPath) as! TimeTabelCell
            cell.backgroundColor = HexColor.lightColor
            cell.layer.cornerRadius = 10
            return cell
        case requestTextDic.keys.count+1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThisMonthCourseBoard",
                                                          for: indexPath) as! ThisMonthViewCell
            cell.backgroundColor = HexColor.lightColor
            cell.monthFinishedLabel.text = "\(prepareCourseNumber(self.MonthCourseFinished))"
            cell.layer.cornerRadius = 10
            return cell
        case requestTextDic.keys.count+2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllCourseBoard",
                                                          for: indexPath) as! AllCourseCell
            if self.CourseRegisteredNumber - self.TotalCourseFinished < 10{
                cell.backgroundColor = HexColor.init(displayP3Red: 250/255, green: 232/255, blue: 210/255, alpha: 1)

            } else {
                cell.backgroundColor = HexColor.lightColor
            }
            cell.totalCourseLabel.text = "/\(prepareCourseNumber(self.CourseRegisteredNumber))"
            cell.remainCourseLabel.text = "\(prepareCourseNumber(self.CourseRegisteredNumber - self.TotalCourseFinished))"
            cell.layer.cornerRadius = 10
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestBoard",
                                                          for: indexPath) as! RequestCell
            cell.waitView.isHidden = true
            cell.backgroundColor = HexColor.init(displayP3Red: 250/255, green: 232/255, blue: 210/255, alpha: 1)
            cell.approveBtn.isHidden = false
            let keyArray = Array(self.requestTextDic.keys)
            cell.requestTitleLabel.text = self.requestTextDic[keyArray[indexPath.row]]
            let startTime = self.requestTimeDic[keyArray[indexPath.row]]
            let endTime = self.requestTimeEndDic[keyArray[indexPath.row]]
            
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateStyle = .medium
            dateFormatter1.timeStyle = .medium
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateStyle = .none
            dateFormatter2.timeStyle = .medium
            
            cell.requestDiscriptionLabel.text = "添加自\(dateFormatter1.string(from: startTime!))至\(dateFormatter2.string(from: endTime!))的课程"
            cell.layer.cornerRadius = 10
            cell.docRef = self.requestDBREFDic[keyArray[indexPath.row]]
            return cell
        }
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
