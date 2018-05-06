//
//  StudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/24.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class StudentVC: UICollectionViewController, refreshableVC, UICollectionViewDelegateFlowLayout {
    
    let _refreshControl = UIRefreshControl()
    
    let TimeTolerant = 30
    
    var cMemberID:String?
    
    var db:Firestore!
    var CourseRegisteredNumber:Int = 0
    var TotalCourseFinished:Int = 0
    var MonthCourseFinished:Int = 0
    
    var requestTextDic:[String:String] = [:]
    var requestTimeDic:[String:Date] = [:]
    var requestTimeEndDic:[String:Date] = [:]
    var requestDBREFDic:[String:DocumentReference] = [:]
    
    var nextCourse:[String:Any] = [:]
    var thisCourse:[String:Any] = [:]
    var thisCourseRef:DocumentReference?
    
    var timeTableRef:CollectionReference!
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    func refresh() {
       
        if let _MemberID = AppDelegate.AP().currentMemberID{
            
            self.cMemberID = _MemberID
            
            let dbref = db.collection("student").document(_MemberID)
            timeTableRef = dbref.collection("CourseRecorded")
            
            //获取下一节课
            dbref.collection("CourseRecorded").whereField("Approved", isEqualTo: true).whereField("Date", isGreaterThan: Date()).order(by: "Date").getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取下一节课时发生错误", err: err.localizedDescription)
                } else {
                    
                    if snap!.documents.count >= 1{
                        self.nextCourse = snap!.documents[0].data()
                    } else {
                        self.nextCourse = [:]
                    }
                    self.reload()
                }
            }
            
            //是否正在上课
            dbref.collection("CourseRecorded").whereField("Approved", isEqualTo: true).whereField("Date", isGreaterThan: Date().startOfTheDay()).order(by: "Date").getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取正在上课时发生错误", err: err.localizedDescription)
                } else {
                    self.thisCourse = [:]
                    self.thisCourseRef = nil
                    print(snap!.documents)
                    if snap!.documents.count >= 1{
                        for allDocs in snap!.documents{
                            if let startTime = allDocs.data()["Date"] as? Date, let AmountOffset = allDocs.data()["Amount"] as? Int{
                                let calendar = Calendar.current
                                if let endTime = calendar.date(byAdding: .minute, value: AmountOffset*30 + self.TimeTolerant, to: startTime),
                                    let NewStartTime = calendar.date(byAdding: .minute, value: 0 - self.TimeTolerant, to: startTime){
                                    if Date() > NewStartTime && Date() < endTime{
                                        self.thisCourse = allDocs.data()
                                        self.thisCourseRef = allDocs.reference
                                    }
                                }
                            }
                        }
                    } else {
                        self.thisCourse = [:]
                        self.thisCourseRef = nil
                    }
                    self.reload()
                }
            }
            
            //读取总课时
            dbref.collection("CourseRegistered").whereField("Approved", isEqualTo: true).getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取总课时时发生错误", err: err.localizedDescription)
                } else {
                    self.CourseRegisteredNumber = 0
                    for allDocs in snap!.documents{
                        self.CourseRegisteredNumber += allDocs.data()["Amount"] as! Int
                    }
                    self.reload()
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
                    self.reload()
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
                    self.reload()
                }
            }
            
            //获取申请
            dbref.collection("CourseRecorded").whereField("Approved", isEqualTo: false).getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取申请信息时发生错误", err: err.localizedDescription)
                } else {
                    print(snap!.documents)
                    print(_MemberID)
                    self.requestTextDic = [:]
                    self.requestTimeDic = [:]
                    self.requestTimeEndDic = [:]
                    
                    for allDocs in snap!.documents{
                        
                        if let Notetext = allDocs.data()["Note"] as? String, let startTime = allDocs.data()["Date"] as? Date, let AmountOffset = allDocs.data()["Amount"] as? Int{
                            let calendar = Calendar.current
                            if let endTime = calendar.date(byAdding: .minute, value: AmountOffset*30, to: startTime), startTime > Date(){
                                self.requestTextDic.updateValue(Notetext, forKey: allDocs.documentID)
                                self.requestTimeDic.updateValue(startTime, forKey: allDocs.documentID)
                                self.requestTimeEndDic.updateValue(endTime, forKey: allDocs.documentID)
                                self.requestDBREFDic.updateValue(allDocs.reference, forKey: allDocs.documentID)
                            }
                        }
                    }
                    self.reload()
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
            //课程表
        case requestTextDic.keys.count:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableBoard", for: indexPath) as! TimeTabelCell
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            
            
            
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.titleLabel.text = "下一节课"
            if self.thisCourse.keys.count != 0{
                cell.titleLabel.text = "正在上课"
                cell.backgroundColor = HexColor.Blue.withAlphaComponent(0.3)
                cell.dateLabel.text = "\(dateFormatter.string(from: (self.thisCourse["Date"] as! Date))) \((self.thisCourse["Date"] as! Date).getThisWeekDayLongName())"
                cell.TimeLabel.text = timeFormatter.string(from: (self.thisCourse["Date"] as! Date))
                cell.noteLabel.text = self.thisCourse["Note"] as? String ?? ""
                if let _thisCourseRef = self.thisCourseRef{
                    cell.thisCourseRef = _thisCourseRef
                    if let startTime = thisCourse["Date"] as? Date{
                        if (Date() > startTime){
                            cell.report.isHidden = false
                        } else {
                            cell.report.isHidden = true
                        }
                    } else {
                        AppDelegate.showError(title: "获取时间时发生错误", err: "无法获取上课时间")
                    }
                } else {
                    cell.report.isHidden = true
                }
                
                cell.requirChangeBtn.isHidden = true
            } else if self.nextCourse.keys.count != 0{
                cell.dateLabel.text = "\(dateFormatter.string(from: (self.nextCourse["Date"] as! Date))) \((self.nextCourse["Date"] as! Date).getThisWeekDayLongName())"
                cell.TimeLabel.text = timeFormatter.string(from: (self.nextCourse["Date"] as! Date))
                cell.noteLabel.text = self.nextCourse["Note"] as? String ?? ""
                cell.report.isHidden = true
            } else {
                cell.dateLabel.text = ""
                cell.TimeLabel.text = "暂无课程"
                cell.noteLabel.text = ""
                cell.report.isHidden = true
                cell.requirChangeBtn.isHidden = true
            }
            cell.layer.cornerRadius = 10
            return cell
        case requestTextDic.keys.count+1:
            //当月
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThisMonthCourseBoard",
                                                          for: indexPath) as! ThisMonthViewCell
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.monthFinishedLabel.text = "\(prepareCourseNumber(self.MonthCourseFinished))"
            cell.layer.cornerRadius = 10
            return cell
            //所有
        case requestTextDic.keys.count+2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllCourseBoard",
                                                          for: indexPath) as! AllCourseCell
            if self.CourseRegisteredNumber - self.TotalCourseFinished < 10{
                cell.backgroundColor = HexColor.yellow.withAlphaComponent(0.3)
                cell.title.text = "请及时充值"
            } else {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                cell.title.text = "剩余课程"
            }
            cell.totalCourseLabel.text = "/\(prepareCourseNumber(self.CourseRegisteredNumber))"
            cell.remainCourseLabel.text = "\(prepareCourseNumber(self.CourseRegisteredNumber - self.TotalCourseFinished))"
            cell.layer.cornerRadius = 10
            return cell
            //申请
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestBoard",
                                                          for: indexPath) as! RequestCell
            cell.self.alpha = 1
            cell.waitView.isHidden = true
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            cell.approveBtn.isHidden = false
            let keyArray = Array(self.requestTextDic.keys)
            cell.requestTitleLabel.text = self.requestTextDic[keyArray[indexPath.row]]
            let startTime = self.requestTimeDic[keyArray[indexPath.row]]
            let endTime = self.requestTimeEndDic[keyArray[indexPath.row]]
            
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateStyle = .medium
            dateFormatter1.timeStyle = .none
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateStyle = .none
            dateFormatter2.timeStyle = .short
            
            cell.requestDiscriptionLabel.text = "添加自\(dateFormatter1.string(from: startTime!)) \(startTime!.getThisWeekDayLongName()) \(dateFormatter2.string(from: startTime!))至\(dateFormatter2.string(from: endTime!))的课程"
            cell.layer.cornerRadius = 10
            cell.docRef = self.requestDBREFDic[keyArray[indexPath.row]]
            return cell
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? TimeTableViewController{
            if let _timeTableRef = self.timeTableRef{
                if let MemberID = self.cMemberID{
                    dvc.collectionRef = ["": _timeTableRef]
                    dvc.cMemberID = self.cMemberID
                    dvc.dref = db.collection("student").document(MemberID).collection("CourseRecorded")
                }
            }
        }
        if let dvc = segue.destination as? PurchaseTableViewController{
            if let MemberID = self.cMemberID{
                dvc.dref = db.collection("student").document(MemberID).collection("CourseRegistered")
            }
        }
        if let dvc = segue.destination as? StudentAllCoursesTableViewController{
            if let MemberID = self.cMemberID{
                dvc.dref = db.collection("student").document(MemberID).collection("CourseRecorded")
            }
        }
        if let dvc = segue.destination as? StudentFinishedTableViewController{
            if let MemberID = self.cMemberID{
                dvc.dref = db.collection("student").document(MemberID).collection("CourseRecorded")
            }
        }
        
    }

}
