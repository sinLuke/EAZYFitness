//
//  trainerMyStudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class trainerMyStudentVC: UICollectionViewController, refreshableVC, UICollectionViewDelegateFlowLayout {
    
    let _refreshControl = UIRefreshControl()
    let TimeTolerant = 30
    var db:Firestore!
    
    var myStudentCollectionView:UICollectionView?
    
    var nextCourse:[String:[String:Any]] = [:]
    var thisCourse:[String:[String:Any]] = [:]
    var thisCourseStudentName:String = ""
    
    var requestTextDic:[String:String] = [:]
    var requestTimeDic:[String:Date] = [:]
    var requestTimeEndDic:[String:Date] = [:]
    var requestDBREFDic:[String:DocumentReference] = [:]
    var requestNameDic:[String:String] = [:]
    
    var myStudentsName:[String:String] = [:]
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    func refresh() {
        if let cMemberID = AppDelegate.AP().currentMemberID{
            for eachStudentID in AppDelegate.AP().myStudentListGeneral{
                self.getStudentsName(studentID: eachStudentID)
                self.getNextCourse(studentID: eachStudentID)
                self.checkIfDuringCourse(studentID: eachStudentID)
                self.getRequest(studentID: eachStudentID)
            }
        }
    }
    
    func reload() {
        self.collectionView?.reloadData()
        self.myStudentCollectionView?.reloadData()
    }
    
    
    
    func getStudentsName(studentID:String){
        let dbref = db.collection("student").document(studentID)
        
        //获取某个学生的信息
        dbref.getDocument { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取学生信息时发生错误", err: err.localizedDescription)
            } else {
                if let docSnap = snap{
                    if let docData = docSnap.data(){
                        self.myStudentsName[studentID] = "\(docData["First Name"] ?? "No") \(docData["Last Name"] ?? "Name")"
                    }
                } else {
                    AppDelegate.showError(title: "读取学生信息时发生错误", err: "无法读取数据")
                }
                self.reload()
            }
        }
    }
    
    func getNextCourse(studentID:String){
        let dbref = db.collection("student").document(studentID)
        print("getNextCourse")
        //获取某个学生的下一节课
        dbref.collection("CourseRecorded").whereField("Approved", isEqualTo: true).whereField("Date", isGreaterThan: Date()).order(by: "Date").getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取下一节课时发生错误", err: err.localizedDescription)
            } else {
                print("=====")
                print(snap?.documents.count)
                if snap!.documents.count >= 1{
                    self.nextCourse[studentID] = snap!.documents[0].data()
                } else {
                    self.nextCourse[studentID] = [:]
                }
                self.reload()
            }
        }
    }
    
    func checkIfDuringCourse(studentID:String){
        //检查某一学生是否在上课
        let dbref = db.collection("student").document(studentID)
        
        dbref.collection("CourseRecorded").whereField("Approved", isEqualTo: true).whereField("Date", isGreaterThan: Date().startOfTheDay()).order(by: "Date").getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取正在上课时发生错误", err: err.localizedDescription)
            } else {
                print(snap!.documents)
                if snap!.documents.count >= 1{
                    for allDocs in snap!.documents{
                        if let startTime = allDocs.data()["Date"] as? Date, let AmountOffset = allDocs.data()["Amount"] as? Int{
                            let calendar = Calendar.current
                            if let endTime = calendar.date(byAdding: .minute, value: AmountOffset*30 + self.TimeTolerant, to: startTime),
                                let NewStartTime = calendar.date(byAdding: .minute, value: 0 - self.TimeTolerant, to: startTime){
                                if Date() > startTime && Date() < endTime{
                                    self.thisCourse[studentID] = allDocs.data()
                                }
                            }
                        }
                    }
                } else {
                    self.thisCourse = [:]
                }
                self.reload()
            }
        }
    }
    
    func getRequest(studentID:String){
        //检查某一学生的申请
        let dbref = db.collection("student").document(studentID)
        dbref.collection("CourseRecorded").whereField("TrainerApproved", isEqualTo: false).getDocuments { (snap, err) in
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
                            self.requestNameDic.updateValue(studentID, forKey: allDocs.documentID)
                        }
                    }
                }
                self.reload()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(AppDelegate.AP().myStudentListGeneral)
        
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < self.thisCourse.count {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 90)
            //扫码通知
        } else if indexPath.row >= self.thisCourse.count && indexPath.row < self.thisCourse.count + requestTextDic.keys.count{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
            //申请视图
        } else if indexPath.row == self.thisCourse.count + requestTextDic.keys.count{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 200)
            //下一节课视图
        } else if indexPath.row == self.thisCourse.count + requestTextDic.keys.count + 1{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 225)
            //我的学生视图
        } else if indexPath.row == self.thisCourse.count + requestTextDic.keys.count + 2{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
            //我的学生视图
        } else {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thisCourse.count + 3 + requestTextDic.keys.count
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
        case self.thisCourse.count + requestTextDic.keys.count://当前课程
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableBoard",
                                                          for: indexPath) as! TrainerNextCell
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            
            var latestTime:Date? = nil
            var theNextCourse:[String:Any]? = [:]
            for upcomingCourses in Array(self.nextCourse.keys){
                if let thisDate = self.nextCourse[upcomingCourses]!["Date"] as? Date{
                    if latestTime == nil{
                        latestTime = thisDate as? Date
                        theNextCourse = self.nextCourse[upcomingCourses]
                    } else {
                        latestTime = min(thisDate, latestTime!)
                        theNextCourse = self.nextCourse[upcomingCourses]
                    }
                }
            }
            
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.titleLabel.text = "下一节课"
            
            if self.nextCourse.keys.count != 0{
                cell.dateLabel.text = "\(dateFormatter.string(from: (theNextCourse!["Date"] as! Date))) \((theNextCourse!["Date"] as! Date).getThisWeekDayLongName())"
                cell.TimeLabel.text = timeFormatter.string(from: (theNextCourse!["Date"] as! Date))
                cell.noteLabel.text = theNextCourse!["Note"] as? String ?? ""
                cell.report.isHidden = true
            } else {
                cell.dateLabel.text = ""
                cell.TimeLabel.text = "暂无课程"
                cell.noteLabel.text = ""
                cell.report.isHidden = true
                cell.requirChangeBtn.isHidden = true
            }
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case self.thisCourse.count + requestTextDic.keys.count + 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyStudentBoard",
                                                          for: indexPath) as! TrainerMyStudentCell
            self.myStudentCollectionView = cell.myStudentCollectionView
            cell.myStudentsName = self.myStudentsName
            cell.nextCourse = self.nextCourse
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case self.thisCourse.count + requestTextDic.keys.count + 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthFinishedBoard",
                                                          for: indexPath) as! TrainerMonthCell
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        default:
            if indexPath.row < self.thisCourse.count{
                //扫码通知
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scanBoard",
                                                              for: indexPath) as! TrainerScanCell
                cell.layer.cornerRadius = 10
                cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
                return cell
            } else {
                //申请视图
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestBoard",
                                                              for: indexPath) as! TrainerRequestCell
                cell.self.alpha = 1
                cell.waitView.isHidden = true
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                cell.approveBtn.isHidden = false
                cell.layer.cornerRadius = 10
                let keyArray = Array(self.requestTextDic.keys)
                print(self.myStudentsName)
                print(self.requestTextDic)
                print(self.thisCourse)
                cell.requestTitleLabel.text = self.requestTextDic[keyArray[indexPath.row - self.thisCourse.count]]
                let startTime = self.requestTimeDic[keyArray[indexPath.row - self.thisCourse.count]]
                let endTime = self.requestTimeEndDic[keyArray[indexPath.row - self.thisCourse.count]]
                
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateStyle = .medium
                dateFormatter1.timeStyle = .none
                
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateStyle = .none
                dateFormatter2.timeStyle = .short
                
                cell.requestDiscriptionLabel.text = "由\(self.myStudentsName[self.requestNameDic[keyArray[indexPath.row]]!])更改为自\(dateFormatter1.string(from: startTime!)) \(startTime!.getThisWeekDayLongName()) \(dateFormatter2.string(from: startTime!))至\(dateFormatter2.string(from: endTime!))的课程"
                cell.layer.cornerRadius = 10
                cell.docRef = self.requestDBREFDic[keyArray[indexPath.row]]
                return cell
            }
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
