//
//  trainerMyStudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class trainerMyStudentVC: DefaultCollectionViewController, UICollectionViewDelegateFlowLayout, QRCodeReaderViewControllerDelegate {
    
    let _refreshControl = UIRefreshControl()
    let TimeTolerant = 0
    var db:Firestore!
    
    var timeTableRef:[String:CollectionReference] = [:]
    
    var myStudentCollectionView:UICollectionView?
    
    var CourseList:[String:[ClassObj]] = [:]
    var nextCourse:[String:ClassObj] = [:]
    var thisCourse:ClassObj? = nil
    
    var TotalCourseFinished:[String:Int] = [:]
    
    var monthTotal:Int = 0
    
    var 教练说学生没来前的等待时间:Int = 20
    
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
    
    override func refresh() {
        if let cMemberID = AppDelegate.AP().currentMemberID{
            for studentRef in AppDelegate.AP().studentList{
                self.getStudentsName(studentRef: studentRef)
            }
            self.getTrainerMonthTotal()
        }
    }
    
    override func reload() {
        self.collectionView?.reloadData()
        self.myStudentCollectionView?.reloadData()
    }
    
    @IBAction func myTimeTabel(_ sender: Any) {
        
    }
    
    func getStudentsName(studentRef:DocumentReference){
        studentRef.getDocument { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取学生信息时发生错误", err: err.localizedDescription)
            } else {
                if let docSnap = snap{
                    if let docData = docSnap.data(){
                        self.myStudentsName[studentRef.documentID] = "\(docData["First Name"] ?? "N2o") \(docData["Last Name"] ?? "Name")"
                    }
                } else {
                    AppDelegate.showError(title: "读取学生信息时发生错误", err: "无法读取数据")
                }
                
                self.CourseList[studentRef.documentID] = []
                self.TotalCourseFinished[studentRef.documentID] = 0
                
                self.getNextCourse(dbref: studentRef)
                self.getRequest(studentID: studentRef.documentID)
                self.reload()
            }
        }
    }
    
    func getNextCourse(dbref:DocumentReference){
        print("getNextCourse")
        
        //获取某个学生的下一节课
        
        dbref.collection("CourseRecorded").getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取下一节课时发生错误", err: err.localizedDescription)
            } else {
                self.CourseList[dbref.documentID] = []
                self.requestTextDic = [:]
                self.requestTimeDic = [:]
                self.requestTimeEndDic = [:]
                self.requestNameDic = [:]
                
                if let documentList = snap?.documents{
                    for docDic in documentList{
                        let classObj = ClassObj()
                        let courseRef = docDic["ref"] as! DocumentReference
                        classObj.courseRef = courseRef
                        classObj.trainer = docDic["trainer"] as! DocumentReference
                        classObj.status[dbref.documentID] = enumService.toCourseStatus(s: docDic["status"] as! String)
                        self.getCourseInfo(studentID:dbref.documentID, studentRef: docDic.reference, ref: courseRef, classObj: classObj)
                        self.CourseList[dbref.documentID]!.append(classObj)
                    }
                }
            }
        }
    }
    
    func getStudentStatusForThisCourse(this:ClassObj){
        for studentID in this.student{
            
        }
    }
    
    func getCourseInfo(studentID:String, studentRef: DocumentReference, ref:DocumentReference, classObj:ClassObj){
        ref.getDocument { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取课程时发生错误", err: err.localizedDescription)
            } else {
                if let dic = snap!.data(){
                    print(dic)
                    classObj.note = dic["note"] as! String
                    classObj.amount = dic["amount"] as! Int
                    classObj.date = dic["date"] as! Date
                    
                    //获取本节课
                    if let startTime = classObj.date{
                        let AmountOffset = classObj.amount
                        let calendar = Calendar.current
                        if let endTime = calendar.date(byAdding: .minute, value: AmountOffset*30 + self.TimeTolerant, to: startTime),
                            let NewStartTime = calendar.date(byAdding: .minute, value: 0 - self.TimeTolerant, to: startTime){
                            if Date() > NewStartTime && Date() < endTime{
                                self.thisCourse = classObj
                                self.getStudentStatusForThisCourse(this: classObj)
                            }
                        }
                    }
                    
                    //获取下一节课
                    if classObj.date > Date() {
                        if self.nextCourse[studentID] != nil{
                            if classObj.date < self.nextCourse[studentID]!.date{
                                self.nextCourse[studentID] = classObj
                            }
                        } else {
                            self.nextCourse[studentID] = classObj
                        }
                    }
                    
                    //获取总课时数
                    var allapproved = true
                    var allrecord = true
                    for statuses in (classObj.status.values){
                        if statuses == courseStatus.waitForStudent{
                            allapproved = false
                        }
                        if statuses == courseStatus.approved || statuses == courseStatus.noTrainer{
                            allrecord = false
                        }
                    }
                    if allapproved{
                        if allrecord{
                            self.TotalCourseFinished[studentID]! += classObj.amount
                            if classObj.date > Date().startOfMonth() && classObj.date < Date().endOfMonth(){
                                self.TotalCourseFinished[studentID]! += classObj.amount
                            }
                        }
                    } else {
                        //request
                    }
                    
                    self.getListOfStudentInCourse(ref: ref.collection("trainee"), classObj: classObj)
                    
                } else {
                    AppDelegate.showError(title: "未知错误", err: "读取课程信息时发生错误")
                    
                }
            }
        }
    }
    
    func getListOfStudentInCourse(ref:CollectionReference, classObj:ClassObj){
        ref.getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "获得上课学员时发生错误", err: err.localizedDescription)
            } else {
                for doc in snap!.documents{
                    if snap!.documents.count == 1{
                        classObj.type = courseType.general
                    } else {
                        classObj.type = courseType.multiple
                    }
                    if let studentRef = doc["ref"] as? DocumentReference{
                        
                        if let studentNameRef = studentRef.parent.parent{
                            studentNameRef.getDocument(completion: { (snap, err) in
                                if let err = err{
                                    AppDelegate.showError(title: "读取学员信息时发生错误", err: err.localizedDescription)
                                } else {
                                    if let StudentNameDic = snap!.data(){
                                        classObj.studentName[studentRef.documentID] = ("\(StudentNameDic["First Name"]!) \(StudentNameDic["Last Name"]!)")
                                        self.reload()
                                        print("getListOfStudentInCourse")
                                    } else {
                                        AppDelegate.showError(title: "未知错误", err: "读取学员姓名时出现问题")
                                    }
                                }
                            })
                        }
                        
                        classObj.student.append(studentRef)
                        studentRef.getDocument(completion: { (snap, err) in
                            if let err = err{
                                AppDelegate.showError(title: "读取学员信息时发生错误", err: err.localizedDescription)
                            } else {
                                if let StudentDic = snap!.data(){
                                    classObj.status[studentRef.documentID] = enumService.toCourseStatus(s: StudentDic["status"] as! String)
                                    self.reload()
                                    print("getListOfStudentInCourse")
                                } else {
                                    AppDelegate.showError(title: "未知错误", err: "读取学员姓名时出现问题")
                                }
                            }
                        })
                    } else {
                        AppDelegate.showError(title: "未知错误", err: "读取学员信息时发生错误")
                    }
                    
                }
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
        if let docref = self.thisCourse?.courseRef{
            if let memberID = AppDelegate.AP().currentMemberID{
                docref.getDocument { (snap, err) in
                    if let err = err {
                        AppDelegate.showError(title: "记录课程时出现问题", err: err.localizedDescription)
                    } else {
                        if let amount = snap?.data()!["Amount"] as? Int, let recorded = snap?.data()!["Record"] as? Bool{
                            if recorded == false {
                                self.db.collection("trainer").document(memberID).collection("Finished").addDocument(data: ["CourseID" : docref.documentID, "StudentID": studentID, "FinishedType": "Scaned", "CourseType": "General", "Note":"正常", "Amount":amount, "Date":Date()])
                                docref.updateData(["Record":true, "RecordDate":Date(), "trainer":memberID, "Type":"General", "notrainer":false])
                            }
                            self.refresh()
                        } else {
                            AppDelegate.showError(title: "记录课程时出现问题", err: "无法获取课时数")
                        }
                        
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
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.isTranslucent = true
        } else {
            
        }
        
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
        if indexPath.row < ((self.thisCourse?.student.count) ?? 0) {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 90)
            //扫码通知
        } else if indexPath.row >= ((self.thisCourse?.student.count) ?? 0) && indexPath.row < ((self.thisCourse?.student.count) ?? 0) + requestTextDic.keys.count{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
            //申请视图
        } else if indexPath.row == ((self.thisCourse?.student.count) ?? 0) + requestTextDic.keys.count{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 200)
            //下一节课视图
        } else if indexPath.row == ((self.thisCourse?.student.count) ?? 0) + requestTextDic.keys.count + 1{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 225)
            //我的学生视图
        } else if indexPath.row == ((self.thisCourse?.student.count) ?? 0) + requestTextDic.keys.count + 2{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
            //我的学生视图
        } else {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((self.thisCourse?.student.count) ?? 0) + 3 + requestTextDic.keys.count
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
        case ((self.thisCourse?.student.count) ?? 0) + requestTextDic.keys.count://下一节课
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableBoard",
                                                          for: indexPath) as! TrainerNextCell
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            
            var latestTime:Date? = nil
            var theNextCourse:ClassObj? = nil
            
            var theName = "unnamed"
            
            for studentID in Array(self.nextCourse.keys){
                if let thisDate = self.nextCourse[studentID]!.date{
                    if latestTime == nil{
                        latestTime = thisDate
                        theNextCourse = self.nextCourse[studentID]
                        theName = (self.nextCourse[studentID]?.allStudentName) ?? "unnamed"
                    } else if thisDate < latestTime!{
                        latestTime = thisDate
                        theNextCourse = self.nextCourse[studentID]
                        theName = (self.nextCourse[studentID]?.allStudentName) ?? "unnamed"
                    }
                }
            }
            
            
            
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.titleLabel.text = "下一节课"
            cell.studentNameLabel.text = theName
            
            if let next = theNextCourse{
                cell.dateLabel.text = "\(dateFormatter.string(from: (next.date))) \((next.date).getThisWeekDayLongName())"
                cell.TimeLabel.text = timeFormatter.string(from: (next.date))
                cell.noteLabel.text = next.note
            } else {
                cell.dateLabel.text = ""
                cell.TimeLabel.text = "暂无课程"
                cell.noteLabel.text = ""
                cell.requirChangeBtn.isHidden = true
            }
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case ((self.thisCourse?.student.count) ?? 0) + requestTextDic.keys.count + 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyStudentBoard",
                                                          for: indexPath) as! TrainerMyStudentCell
            self.myStudentCollectionView = cell.myStudentCollectionView
            cell.myStudentsName = self.myStudentsName
            cell.nextCourse = self.nextCourse
            cell.vc = self
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case ((self.thisCourse?.student.count) ?? 0) + requestTextDic.keys.count + 2:
            //当月
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthFinishedBoard",
                                                          for: indexPath) as! TrainerMonthCell
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.totalCourse.text = "总计课时数：\(prepareCourseNumber(self.allTotal))"
            cell.monthFinishedLabel.text = "\(prepareCourseNumber(self.monthTotal))"
            cell.layer.cornerRadius = 10
            return cell
        default:
            if indexPath.row < ((self.thisCourse?.student.count) ?? 0){
                //扫码通知
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scanBoard",
                                                              for: indexPath) as! TrainerScanCell
                cell.layer.cornerRadius = 10
                cell.rootViewComtroller = self
                
                cell.vc = self
                
                let studentID = thisCourse!.student[indexPath.row].documentID
                cell.studentID = studentID
                cell.studentcoursedocuentref = thisCourse!.student[indexPath.row]
                cell.trainerdocuentref = db.collection("trainer").document(AppDelegate.AP().currentMemberID!)
                cell.NameLabel.text = myStudentsName[studentID]
                if let thiscourse = thisCourse{
                    if let startTime = thiscourse.date{
                        if (Date() > Calendar.current.date(byAdding: .minute, value: self.教练说学生没来前的等待时间, to: startTime)!){
                            cell.report.isHidden = false
                        } else {
                            cell.report.isHidden = true
                        }
                    } else {
                        AppDelegate.showError(title: "获取时间时发生错误", err: "无法获取上课时间")
                    }
                    /*
                    
                    if let recorded = thisCourse!.student[indexPath.row] as? Bool{
                        if (recorded == true){
                            cell.TitleLabel.text = "课程已扫码"
                            cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
                            cell.scanButton.isHidden = true
                        } else {
                            cell.TitleLabel.text = "课程尚未扫码"
                            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
                            cell.scanButton.isHidden = false
                        }
                    }
                    */
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
                    
                    cell.requestTitleLabel.text = self.requestTextDic[keyArray[indexPath.row - ((self.thisCourse?.student.count) ?? 0)]]
                    let startTime = self.requestTimeDic[keyArray[indexPath.row - ((self.thisCourse?.student.count) ?? 0)]]
                    let endTime = self.requestTimeEndDic[keyArray[indexPath.row - ((self.thisCourse?.student.count) ?? 0)]]
                    
                    let dateFormatter1 = DateFormatter()
                    dateFormatter1.dateStyle = .medium
                    dateFormatter1.timeStyle = .none
                    
                    let dateFormatter2 = DateFormatter()
                    dateFormatter2.dateStyle = .none
                    dateFormatter2.timeStyle = .short
                    let i = indexPath.row - ((self.thisCourse?.student.count) ?? 0)
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
                for studentRef in (AppDelegate.AP().studentList){
                    timeTableRef[myStudentsName[studentRef.documentID]!] = studentRef.collection("CourseRecorded")
                }
                dvc.collectionRef = timeTableRef
                dvc.cMemberID = nil
                dvc.dref = timeTableRef
            } else if segue.identifier == "studentTimetable"{
                if let _timeTableRef = self.studentTimeTableRef{
                    if let MemberID = self.studentMemberID{
                        dvc.collectionRef = ["": _timeTableRef]
                        dvc.cMemberID = self.studentMemberID
                        dvc.dref = db.collection("student").document(MemberID).collection("CourseRecorded")
                    }
                }
            }
        } else if let dvc = segue.destination as? TrainerFinishedTableViewController{
            if let cmid = AppDelegate.AP().currentMemberID{
                dvc.ref = db.collection("trainer").document(cmid).collection("Finished")
                dvc.name = "我"
            } else {
                AppDelegate.showError(title: "未知问题", err: "无法获取卡号", handler:AppDelegate.AP().signout)
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
