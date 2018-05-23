//
//  StudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/24.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class StudentVC: DefaultCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let _refreshControl = UIRefreshControl()
    
    let TimeTolerant = 0
    
    var thisStudent:EFStudent!
    
    var db:Firestore!
    var CourseRegisteredNumber:Int = 0
    var TotalCourseFinished:Int = 0
    var MonthCourseFinished:Int = 0
    var totalTime:DateInterval?
    
    var nextCourse:EFCourse!
    var thisCourse:EFCourse!
    
    var firstCourse:EFCourse!
    
    var nextStudentCourse:EFStudentCourse!
    var thisStudentCourse:EFStudentCourse!
    
    var timeTableRef:[EFCourse]!
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func refresh() {
       
        super.refresh()
        
        CourseRegisteredNumber = 0
        TotalCourseFinished = 0
        MonthCourseFinished = 0
        print("读取当前学生")
        //读取当前学生
        if let thisStudent = DataServer.studentDic[thisStudent.memberID]{
            
            print("读取当前学生的购买课程引用")
            //读取当前学生的购买课程引用
            self.CourseRegisteredNumber = 0
            for efStudentRegistered in thisStudent.registeredDic.values{
                if efStudentRegistered.approved {
                    self.CourseRegisteredNumber += efStudentRegistered.amount
                }
            }
            
            print("读取当前学生的所有课程引用")
            //读取当前学生的所有课程引用
            self.MonthCourseFinished = 0
            self.TotalCourseFinished = 0
            
            //获取申请
            print("获取申请")
            EFRequest.getRequestForCurrentUser(type: requestType.studentApproveCourse)
            
            for efStudentCourse in thisStudent.courseDic.values{
                
                //通过课程引用取得课程
                if let theCourse = DataServer.courseDic[efStudentCourse.courseRef.documentID]{
                    //如果课程发生在未来
                    if theCourse.date > Date(){
                        
                        //获取下一节课
                        //比较时间并将最接近当前时间的课程放入 self.nextCourse
                        if self.nextCourse == nil {
                            self.nextCourse = theCourse
                            self.nextStudentCourse = efStudentCourse
                        } else {
                            if theCourse.date < self.nextCourse.date{
                                self.nextCourse = theCourse
                                self.nextStudentCourse = efStudentCourse
                            }
                        }
                        
                        
                        
                        
                    } else {
                        
                        //获取当前课程
                        //取得 theCourse 结束的时间
                        if let theCourseEndTime = Calendar.current.date(byAdding: .minute, value: 30*theCourse.amount, to: theCourse.date){
                            
                            //如果当前时间在theCourse开始和结束之间，则放入 self.thisCourse
                            if theCourse.date < Date() && Date() < theCourseEndTime{
                                self.thisCourse = theCourse
                                self.thisStudentCourse = efStudentCourse
                            }
                        }
                        
                        //记录已完成的课时
                        //只有在状态为 scaned 的时候才记入总完成的课时
                        if efStudentCourse.status == .scaned {
                            self.TotalCourseFinished += theCourse.amount
                            print(self.TotalCourseFinished)
                            if theCourse.date > Date().startOfMonth(){
                                self.MonthCourseFinished += theCourse.amount
                            }
                        }
                        
                        //获取第一节课
                        //比较时间并将最接近当前时间的课程放入 self.firstCourse
                        if efStudentCourse.status != .waitForTrainer && efStudentCourse.status != .waitForStudent && efStudentCourse.status != .approved {
                            if self.firstCourse == nil {
                                self.firstCourse = theCourse
                            } else {
                                if theCourse.date < self.firstCourse.date{
                                    self.firstCourse = theCourse
                                    print("self.firstCourse")
                                    print(self.firstCourse)
                                }
                            }
                        }
                    }
                } else {
                    print("读取课程发生错误")
                }
            }
        }
        
        self.reload()
    }
    
    @objc func finishedCourse(){
        performSegue(withIdentifier: "finish", sender: self)
    }
    
    override func reload() {
        super.reload()
        self.collectionView?.reloadData()
        print("===========")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        thisStudent = (self.tabBarController as! StudentTabBarController).thisStudent
        //设置标题为大标题
        if #available(iOS 11.0, *), UIScreen.main.bounds.height >= 580 {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        db = Firestore.firestore()
        self.refresh()
        
        //设置下拉刷新
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.collectionView!.refreshControl = self._refreshControl
        self.collectionView!.addSubview(self._refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == EFRequest.requestList.count {
            
            //本月成就
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 300)
        } else if indexPath.row == EFRequest.requestList.count + 1{
            
            //下一节课/正在上课
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 200)
            
        } else {
            
            //其他板块
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3 + EFRequest.requestList.count
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
            
           //下一节课/当前课程
        case EFRequest.requestList.count + 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableBoard", for: indexPath) as! TimeTabelCell
            
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.titleLabel.text = "下一节课"
            if self.thisCourse != nil{
                //如果当前课程存在
                cell.titleLabel.text = "正在上课"
                cell.backgroundColor = HexColor.Blue.withAlphaComponent(0.3)
                cell.dateLabel.text = self.thisCourse.dateOnlyString
                cell.TimeLabel.text = self.thisCourse.timeOnlyString
                cell.noteLabel.text = self.thisCourse.note
                
                //课程开始之后才能使用举报教练未到的功能
                if (Date() > self.thisCourse.date){
                    cell.report.isHidden = false
                } else {
                    cell.report.isHidden = true
                }
                
                cell.requirChangeBtn.isHidden = true
                
            } else if self.nextCourse != nil{
                
                //如果下一节课存在
                cell.dateLabel.text = self.nextCourse.dateOnlyString
                cell.TimeLabel.text = self.nextCourse.timeOnlyString
                cell.noteLabel.text = self.nextCourse.note
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
            
        case EFRequest.requestList.count:
            //当月成就
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThisMonthCourseBoard",
                                                          for: indexPath) as! ThisMonthViewCell
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(finishedCourse))
            cell.addGestureRecognizer(gesture)
            
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            cell.allCourseFinishedLabel.text = "\(TotalCourseFinished)"
            
            if self.firstCourse == nil {
                cell.AllTimeLabel.text = "目前还没有完成的课时哦"
            } else {
                let start = Calendar.current.startOfDay(for: self.firstCourse.date)
                let end = Calendar.current.startOfDay(for: Date())
                let components = Calendar.current.dateComponents([.day, .month, .year], from: start, to: end)
                var firstCourseString = "共"
                if let years = components.year, years != 0{
                    firstCourseString = "\(years)年"
                }
                if let months = components.month, months != 0{
                    firstCourseString = "\(firstCourseString)\(months)月"
                }
                if let days = components.day{
                    firstCourseString = "\(firstCourseString)\(days)天"
                }
                
                cell.AllTimeLabel.text = firstCourseString
            }
            
            let percentageValue:Float = min(Float(MonthCourseFinished)/Float(self.thisStudent.goal), 1)
            
            let percentage = String(format: "%.0f", 100 * percentageValue)
            cell.goalLabel.text = "\(percentage)% (\(prepareCourseNumber(MonthCourseFinished))/\(prepareCourseNumber(self.thisStudent.goal)))"
            cell.thisMonthFinishedLabel.text = "\(prepareCourseNumber(MonthCourseFinished)) 课时"
            cell.progressBar.progress = percentageValue
            return cell
            //所有
        case EFRequest.requestList.count + 2:
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
            
            if EFRequest.requestList.count <= indexPath.row{
                return cell
            } else {
                let efRequest = EFRequest.requestList[indexPath.row]
                cell.requestTitleLabel.text = efRequest.title
                
                if efRequest.type == .studentApproveCourse{
                    if let theRequestStudentCourse = thisStudent.courseDic[efRequest.requestRef.documentID]{
                        if let theRequestCourse = DataServer.courseDic[theRequestStudentCourse.courseRef.documentID]{
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
                }
                
                cell.efRequest = efRequest
                return cell
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let dvc = segue.destination as? TimeTableViewController{
            dvc.title = "本周"
            dvc.startoftheweek = Date().startOfWeek()
            dvc.theStudentOrTrainer = self.thisStudent
            dvc.cMemberID = AppDelegate.AP().ds?.memberID
        }
        if let dvc = segue.destination as? PurchaseTableViewController{
            dvc.thisStudent = self.thisStudent
            dvc.title = "我"
        }
        if let dvc = segue.destination as? CourseTableViewController{
            dvc.thisStudentOrTrainer = self.thisStudent
            dvc.title = "我的课程"
        }
    }
}
