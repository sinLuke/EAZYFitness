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
    
    var thisTrainer:EFTrainer!
    
    let _refreshControl = UIRefreshControl()
    var db:Firestore!

    var myStudentCollectionView:UICollectionView?
    
    var TimeTolerant:Int = 20
    
    var TotalCourseFinished:Int = 0
    var MonthCourseFinished:Int = 0
    var nextCourse:EFCourse?
    var thisCourse:EFCourse?
    var nextStudentCourse:[EFStudentCourse]!
    var thisStudentCourse:[EFStudentCourse]!
    var goal:Int = 0
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func refresh() {
        thisTrainer.download()
        
        
        
        self.reload()
    }
    
    override func reload() {
        
        self.thisCourse = nil
        self.nextCourse = nil
        self.thisStudentCourse = []
        self.nextStudentCourse = []
        TotalCourseFinished = 0
        MonthCourseFinished = 0
        
        for theStudentRef in self.thisTrainer.trainee{
            if let thisStudent = DataServer.studentDic[theStudentRef.documentID]{
                for efStudentCourse in thisStudent.courseDic.values{
                    //通过课程引用取得课程
                    if let theCourse = DataServer.courseDic[efStudentCourse.courseRef.documentID]{
                        
                        //获取申请
                        EFRequest.getRequestForCurrentUser(type: requestType.trainerApproveCourse)
                        
                        //如果课程发生在未来
                        if theCourse.date > Date(){
                            
                            //获取下一节课
                            //比较时间并将最接近当前时间的课程放入 self.nextCourse
                            if self.nextCourse == nil{
                                if efStudentCourse.status == .approved{
                                    self.nextCourse = theCourse
                                }
                            } else if theCourse.date < self.nextCourse!.date && efStudentCourse.status == .approved{
                                self.nextCourse = theCourse
                            }
                        } else {
                            //获取当前课程
                            //取得 theCourse 结束的时间
                            if let theCourseEndTime = Calendar.current.date(byAdding: .minute, value: 30*theCourse.amount, to: theCourse.date){
                                //如果当前时间在theCourse开始和结束之间，则放入 self.thisCourse
                                let statusList = theCourse.getTraineesStatus
                                if theCourse.date < Date() && Date() < theCourseEndTime && (enumService.toDescription(d: statusList) == "所有学生已同意" || enumService.toDescription(d: statusList) == "已全部扫描" || enumService.toDescription(d: statusList) == "没有全部扫码" || statusList == [courseStatus.approved] || statusList == [courseStatus.scaned]){
                                    self.thisCourse = theCourse
                                }
                            }
                        }
                    } else {
                        print("读取课程发生错误")
                    }
                }
            }
        }
        
        for finishCourseRef in self.thisTrainer.finish{
            if let efCourse = DataServer.courseDic[finishCourseRef.documentID]{
                //记录已完成的课时
                self.MonthCourseFinished += efCourse.amount
            }
        }
        
        for studentRef in self.thisTrainer.trainee{
            if let thisStudent = DataServer.studentDic[studentRef.documentID]{
                if thisCourse != nil {
                    if let thisStudentCourse = thisStudent.courseDic[thisCourse!.ref.documentID]{
                        self.thisStudentCourse.append(thisStudentCourse)
                    }
                }
                if nextCourse != nil{
                    if let nextStudentCourse = thisStudent.courseDic[nextCourse!.ref.documentID]{
                        self.nextStudentCourse.append(nextStudentCourse)
                        
                    }
                }
            }
        }
        
        self.collectionView?.reloadData()
        self.myStudentCollectionView?.reloadData()
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
                    if let doc = snap?.data(){
                        if let _numberValue = doc["MemberID"] as? Int{
                            for thisstudentcourse in self.thisStudentCourse{
                                if let efStduent = thisstudentcourse.parent{
                                    if efStduent.memberID == "\(_numberValue)"{
                                        self.recordACourse(thatStudentCourse: thisstudentcourse, thatCourseRef: thisstudentcourse.courseRef)
                                        self.endLoading()
                                        AppDelegate.showError(title: "录入成功", err: "已成功录入\(efStduent.name)的课程", of: self)
                                        self.refresh()
                                        return
                                    } else {
                                        self.endLoading()
                                        AppDelegate.showError(title: "未知错误", err: "无法找到与之对应的学生1", of: self)
                                    }
                                } else {
                                    self.endLoading()
                                    AppDelegate.showError(title: "未知错误", err: "无法找到与之对应的学生2", of: self)
                                }
                            }
                        } else {
                            self.endLoading()
                            AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0103#)", of: self)
                        }
                    }
                }
            }
        }
        
        
    }
    
    func recordACourse(thatStudentCourse:EFStudentCourse, thatCourseRef:DocumentReference){
        
        if thatStudentCourse.ready{
            thatStudentCourse.status = .scaned
            thisTrainer.finishACourse(By: thatCourseRef)
            thatStudentCourse.upload()
        } else {
            AppDelegate.showError(title: "数据错误", err: "请稍后再试")
            self.refresh()
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thisTrainer = (self.tabBarController as! TrainerTabBarController).thisTrainer
        
        if #available(iOS 11.0, *), UIScreen.main.bounds.height >= 330{
            self.navigationController?.navigationBar.prefersLargeTitles = true
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
        if indexPath.row < ((self.thisStudentCourse.count)) {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 91)
            //扫码通知
        } else if indexPath.row >= ((self.thisStudentCourse.count)) && indexPath.row < ((self.thisStudentCourse.count)) + EFRequest.requestList.count{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 110)
            //申请视图
        } else if indexPath.row == ((self.thisStudentCourse.count)) + EFRequest.requestList.count{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 224)
            //下一节课视图
        } else if indexPath.row == ((self.thisStudentCourse.count)) + EFRequest.requestList.count + 1{
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 132)
            //本月成就
        } else {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 1)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((self.thisCourse?.traineeStudentCourseRef.count) ?? 0) + 2 + EFRequest.requestList.count
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
        case ((self.thisStudentCourse.count)) + EFRequest.requestList.count:
            //下一节课
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableBoard",
                                                          for: indexPath) as! TrainerNextCell
            
            cell.titleLabel.text = "下一节课"
            if self.thisCourse != nil{
                //如果当前课程存在
                cell.titleLabel.text = "正在上课"
                cell.backgroundColor = HexColor.Blue.withAlphaComponent(0.3)
                cell.dateLabel.text = self.thisCourse!.dateOnlyString
                cell.TimeLabel.text = self.thisCourse!.timeOnlyString
                cell.noteLabel.text = self.thisCourse!.note
                cell.studentNameLabel.text = self.thisCourse!.getTraineesNames
                
            } else if self.nextCourse != nil{
                
                //如果下一节课存在
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                cell.dateLabel.text = self.nextCourse!.dateOnlyString
                cell.TimeLabel.text = self.nextCourse!.timeOnlyString
                cell.noteLabel.text = self.nextCourse!.note
                cell.studentNameLabel.text = self.nextCourse!.getTraineesNames
                
            } else {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                cell.dateLabel.text = ""
                cell.TimeLabel.text = "暂无课程"
                cell.noteLabel.text = ""
            }
            cell.layer.cornerRadius = 10
            return cell
            
        case ((self.thisCourse?.traineeStudentCourseRef.count) ?? 0) + EFRequest.requestList.count + 1:
            //当月
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthFinishedBoard",
                                                          for: indexPath) as! TrainerMonthCell
            
            cell.totalCourse.text = "共计：\(prepareCourseNumber(self.TotalCourseFinished))"
            cell.monthFinishedLabel.text = "\(prepareCourseNumber(self.MonthCourseFinished))"
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(finishedCourse))
            cell.addGestureRecognizer(gesture)
            
            let percentageValue:Float = min(Float(MonthCourseFinished)/Float(self.thisTrainer.goal), 1)
            let percentage = String(format: "%.0f", 100 * percentageValue)
            
            cell.goal.text = "\(percentage)% (\(prepareCourseNumber(MonthCourseFinished))/\(prepareCourseNumber(self.thisTrainer.goal)))"
            cell.progress.progress = percentageValue
            if percentageValue == 1 {
                cell.backgroundColor = HexColor.Green.withAlphaComponent(0.3)
                cell.backgroundColor = HexColor.Green
            } else {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                cell.progress.tintColor = HexColor.Pirmary
            }
            
            cell.layer.cornerRadius = 10
            return cell
        default:
            if indexPath.row < ((self.thisCourse?.traineeStudentCourseRef.count) ?? 0){
                //扫码通知
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scanBoard",
                                                              for: indexPath) as! TrainerScanCell
                cell.layer.cornerRadius = 10
                cell.rootViewComtroller = self
                cell.trainer = self.thisTrainer
                cell.vc = self
                
                if let thiscourse = thisCourse{
                    let efStudentCourseRef = thiscourse.traineeStudentCourseRef[indexPath.row]
                    if let efStudentRef = efStudentCourseRef.parent.parent {
                        if let efStudent = DataServer.studentDic[efStudentRef.documentID]{
                            if let thisStudentCourse = efStudent.courseDic[efStudentCourseRef.documentID]{
                                cell.thisStudent = efStudent
                                cell.thisStudentCourse = thisStudentCourse
                                cell.NameLabel.text = efStudent.name
                                
                                let recorded = !(cell.thisStudentCourse.status == courseStatus.approved)
                                if (recorded == true){
                                    cell.TitleLabel.text = "课程已扫码"
                                    cell.backgroundColor = HexColor.Green.withAlphaComponent(0.2)
                                    cell.scanButton.isHidden = true
                                    cell.report.isHidden = true
                                } else {
                                    cell.TitleLabel.text = "课程尚未扫码"
                                    cell.backgroundColor = HexColor.Yellow.withAlphaComponent(0.2)
                                    cell.scanButton.isHidden = false
                                    
                                    let startTime = thiscourse.date
                                    if (Date() > Calendar.current.date(byAdding: .minute, value: self.TimeTolerant, to: startTime)!){
                                        cell.report.isHidden = false
                                    } else {
                                        cell.report.isHidden = true
                                    }
                                }
                            }
                        } else {
                            AppDelegate.showError(title: "获取扫码信息时错误", err: "无法找到与之对应的学生，请稍后重试")
                        }
                    } else {
                        AppDelegate.showError(title: "获取扫码信息时错误", err: "无法找到与之对应的学生，请稍后重试")
                    }
                }
                return cell
            } else {
                //申请视图
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestBoard",
                                                              for: indexPath) as! RequestCell
                cell.self.alpha = 1
                cell.waitView.isHidden = true
                cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                cell.approveBtn.isHidden = false
                cell.layer.cornerRadius = 10
                
                if EFRequest.requestList.count <= indexPath.row{
                    return cell
                } else {
                    let efRequest = EFRequest.requestList[indexPath.row]
                    cell.requestTitleLabel.text = efRequest.title
                    
                    if efRequest.type == .trainerApproveCourse{
                        if let theRequestCourse = DataServer.courseDic[efRequest.requestRef.documentID]{
                            let startTime = theRequestCourse.date
                            let endTime = Calendar.current.date(byAdding: .minute, value: 30 * theRequestCourse.amount, to: startTime)
                            let dateFormatter1 = DateFormatter()
                            dateFormatter1.dateStyle = .medium
                            dateFormatter1.timeStyle = .none
                            
                            let dateFormatter2 = DateFormatter()
                            dateFormatter2.dateStyle = .none
                            dateFormatter2.timeStyle = .short
                            
                            cell.requestDiscriptionLabel.text = "添加自\(dateFormatter1.string(from: startTime)) \(startTime.getThisWeekDayLongName()) \(dateFormatter2.string(from: startTime))至\(dateFormatter2.string(from: endTime!))的课程"
                            cell.layer.cornerRadius = 10
                        }
                    }
                    
                    cell.efRequest = efRequest
                    return cell
                }
            }
        }
        
    }
    
    @objc func finishedCourse(){
        performSegue(withIdentifier: "finish", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? CourseTableViewController{
            dvc.thisStudentOrTrainer = self.thisTrainer
            dvc.title = "我的课程"
        }
        
        if let dvc = segue.destination as? TimeTableViewController{
            dvc.startoftheweek = Date().startOfWeek()
            dvc.cMemberID = nil
            dvc.theStudentOrTrainer = self.thisTrainer
            dvc.title = "本周"
        } else if let dvc = segue.destination as? TrainerFinishedTableViewController{
            if let cmid = AppDelegate.AP().ds?.memberID{
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
