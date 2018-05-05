//
//  trainerMyStudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class trainerMyStudentVC: DefaultCollectionViewController, refreshableVC, UICollectionViewDelegateFlowLayout, QRCodeReaderViewControllerDelegate {
    
    let _refreshControl = UIRefreshControl()
    let TimeTolerant = 30
    var db:Firestore!
    
    var timeTableRef:[String:CollectionReference] = [:]
    
    var myStudentCollectionView:UICollectionView?
    
    var nextCourse:[String:[String:Any]] = [:]
    var thisCourse:[String:[String:Any]] = [:]
    var thisCourseDBREFDic:[String:DocumentReference] = [:]
    
    var monthTotal:Int = 0
    var allTotal:Int = 0
    
    var requestTextDic:[String:String] = [:]
    var requestTimeDic:[String:Date] = [:]
    var requestTimeEndDic:[String:Date] = [:]
    var requestDBREFDic:[String:DocumentReference] = [:]
    var requestNameDic:[String:String] = [:]
    
    var myStudentsName:[String:String] = [:]
    
    
    var studentTimeTableRef:CollectionReference!
    var studentMemberID:String!
    
    
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
            
            self.getTrainerMonthTotal()
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
                        self.myStudentsName[studentID] = "\(docData["First Name"] ?? "N2o") \(docData["Last Name"] ?? "Name")"
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
                                if Date() > NewStartTime && Date() < endTime{
                                    self.thisCourse[studentID] = allDocs.data()
                                    self.thisCourseDBREFDic[studentID] = allDocs.reference
                                }
                            }
                        }
                    }
                } else {
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
    
    func getTrainerMonthTotal(){
        //获取总课数
        if let memberID = AppDelegate.AP().currentMemberID{
            
            self.allTotal = 0
            self.monthTotal = 0
            
            let dbref = db.collection("trainer").document(memberID).collection("Finished")
            dbref.getDocuments { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
                } else {
                    for allDocs in snap!.documents{
                        print(allDocs.data())
                        if let courseDate = allDocs.data()["Date"] as? Date{
                            if courseDate > Date().startOfMonth(){
                                self.monthTotal += (allDocs.data()["Amount"] as? Int) ?? 0
                            }
                            self.allTotal += (allDocs.data()["Amount"] as? Int) ?? 0
                        }
                    }
                    self.reload()
                }
            }
        } else {
            AppDelegate.showError(title: "未知错误", err: "获取当前用户失败，请重新登录", handler: AppDelegate.AP().signout)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
        
        print(thisCourseDBREFDic)
        print(result.value)
        
        let charset = CharacterSet(charactersIn: ".#$[]")
        if result.value.rangeOfCharacter(from: charset) != nil {
            self.endLoading()
            AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0101#)", of: self)
        } else{
            db.collection("QRCODE").document(result.value).getDocument { (snap, err) in
                if let err = err{
                    self.endLoading()
                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription, of: self)
                } else {
                    if let document = snap?.data() as? NSDictionary{
                        if let _numberValue = document.value(forKey: "MemberID") as? Int{
                            print(_numberValue)
                            self.recordACourse(studentID: "\(_numberValue)")
                        } else {
                            self.endLoading()
                            AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0103#)", of: self)
                        }
                    }
                }
            }
        }
        
        
    }
    
    func recordACourse(studentID:String){
        if let docref = self.thisCourseDBREFDic[studentID]{
            if let memberID = AppDelegate.AP().currentMemberID{
                docref.getDocument { (snap, err) in
                    if let err = err {
                        AppDelegate.showError(title: "记录课程时出现问题", err: err.localizedDescription)
                    } else {
                        let amount = snap!.data()!["Amount"]
                        self.db.collection("trainer").document(memberID).collection("Finished").addDocument(data: ["CourseID" : docref.documentID, "StudentID": studentID, "FinishedType": "Scaned", "Note":"正常", "Amount":amount, "Date":Date()])
                        docref.updateData(["Record":true, "RecordDate":Date(), "Traier":memberID, "Type":"General"])
                        self.refresh()
                    }
                }
            } else {
                AppDelegate.showError(title: "未知错误", err: "获取当前用户失败，请重新登录", handler: AppDelegate.AP().signout)
            }
            self.refresh()
        } else {
            AppDelegate.showError(title: "扫码错误", err: "未找到该学生", of: self)
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        dismiss(animated: true, completion: nil)
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
        print(self.thisCourse.count)
        print(requestTextDic.keys.count)
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
        case self.thisCourse.count + requestTextDic.keys.count://下一节课
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
            
            var theName = "unnamed"
            
            for upcomingCourses in Array(self.nextCourse.keys){
                if let thisDate = self.nextCourse[upcomingCourses]!["Date"] as? Date{
                    if latestTime == nil{
                        latestTime = thisDate as? Date
                        theNextCourse = self.nextCourse[upcomingCourses]
                        theName = self.myStudentsName[upcomingCourses]!
                    } else if thisDate < latestTime!{
                        latestTime = thisDate
                        theNextCourse = self.nextCourse[upcomingCourses]
                        theName = self.myStudentsName[upcomingCourses]!
                    }
                }
            }
            
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.titleLabel.text = "下一节课"
            cell.studentNameLabel.text = theName
            
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
            cell.vc = self
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case self.thisCourse.count + requestTextDic.keys.count + 2:
            //当月
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthFinishedBoard",
                                                          for: indexPath) as! TrainerMonthCell
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.totalCourse.text = "总计课时数：\(prepareCourseNumber(self.allTotal))"
            cell.monthFinishedLabel.text = "\(prepareCourseNumber(self.monthTotal))"
            cell.layer.cornerRadius = 10
            return cell
        default:
            if indexPath.row < self.thisCourse.count{
                //扫码通知
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scanBoard",
                                                              for: indexPath) as! TrainerScanCell
                cell.layer.cornerRadius = 10
                cell.rootViewComtroller = self
                
                
                let studentIDs = Array(thisCourse.keys)
                let studentID = studentIDs[indexPath.row]
                cell.studentID = studentID
                
                cell.NameLabel.text = myStudentsName[studentID]
                
                if (thisCourse[studentID]!["Record"] as! Bool == true){
                    cell.TitleLabel.text = "课程已扫码"
                    cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
                    cell.scanButton.isHidden = true
                } else {
                    cell.TitleLabel.text = "课程尚未扫码"
                    cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
                    cell.scanButton.isHidden = false
                }
                
                
                return cell
            } else {
                //申请视图
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestBoard",
                                                              for: indexPath) as! TrainerRequestCell
                if self.requestTextDic.keys.count != 0{
                    cell.self.alpha = 1
                    cell.waitView.isHidden = true
                    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                    cell.approveBtn.isHidden = false
                    cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                    cell.layer.cornerRadius = 10
                    let keyArray = Array(self.requestTextDic.keys)
                    
                    cell.requestTitleLabel.text = self.requestTextDic[keyArray[indexPath.row - self.thisCourse.count]]
                    let startTime = self.requestTimeDic[keyArray[indexPath.row - self.thisCourse.count]]
                    let endTime = self.requestTimeEndDic[keyArray[indexPath.row - self.thisCourse.count]]
                    
                    let dateFormatter1 = DateFormatter()
                    dateFormatter1.dateStyle = .medium
                    dateFormatter1.timeStyle = .none
                    
                    let dateFormatter2 = DateFormatter()
                    dateFormatter2.dateStyle = .none
                    dateFormatter2.timeStyle = .short
                    let i = indexPath.row-self.thisCourse.count
                    cell.requestDiscriptionLabel.text = "由\(self.myStudentsName[self.requestNameDic[keyArray[i]]!]!)更改为自\(dateFormatter1.string(from: startTime!)) \(startTime!.getThisWeekDayLongName()) \(dateFormatter2.string(from: startTime!))至\(dateFormatter2.string(from: endTime!))的课程"
                    cell.layer.cornerRadius = 10
                    cell.docRef = self.requestDBREFDic[keyArray[i]]
                }
                
                return cell
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? TimeTableViewController{
            if segue.identifier == "trainerTimeTable"{
                for allID in (AppDelegate.AP().myStudentListGeneral){
                    timeTableRef["\(myStudentsName[allID]!)"] = db.collection("student").document(allID).collection("CourseRecorded")
                }
                dvc.collectionRef = timeTableRef
                var refList:[String:CollectionReference] = [:]
                for eachStudentID in AppDelegate.AP().myStudentListGeneral{
                    refList[myStudentsName[eachStudentID]!] = (db.collection("student").document(eachStudentID).collection("CourseRecorded"))
                }
                dvc.cMemberID = nil
                dvc.dref = refList
            } else if segue.identifier == "studentTimetable"{
                if let _timeTableRef = self.studentTimeTableRef{
                    if let MemberID = self.studentMemberID{
                        dvc.collectionRef = ["": _timeTableRef]
                        dvc.cMemberID = self.studentMemberID
                        dvc.dref = db.collection("student").document(MemberID).collection("CourseRecorded")
                    }
                }
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
