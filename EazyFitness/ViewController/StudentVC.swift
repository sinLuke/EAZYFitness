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
    
    var nextCourse:[String: EFCourse] = [:]
    var thisCourse:EFCourse!
    
    var firstCourse:EFCourse!
    
    var nextStudentCourse:[String: EFStudentCourse] = [:]
    var thisStudentCourse:EFStudentCourse!
    
    var timeTableRef:[EFCourse]!
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func refresh() {
       
        super.refresh()
        thisStudent.download()
        
        thisCourse = nil
        nextCourse = [:]
        
        CourseRegisteredNumber = 0
        TotalCourseFinished = 0
        MonthCourseFinished = 0
        
        //获取申请
        EFRequest.getRequestForCurrentUser(type: requestType.studentApproveCourse)
        
        //self.reload()
    }
    
    @objc func finishedCourse(){
        performSegue(withIdentifier: "finish", sender: self)
    }
    
    override func reload() {
        super.reload()
        
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
            
            
            
            for efStudentCourse in thisStudent.courseDic.values{
                
                //通过课程引用取得课程
                if let theCourse = DataServer.courseDic[efStudentCourse.courseRef.documentID]{
                    
                    
                    //如果课程发生在未来
                    if theCourse.date > Date(){
                        if enumService.toMultiCourseStataus(list: theCourse.getTraineesStatus) == multiCourseStatus.approved{
                            //获取下一节课
                            //比较时间并将最接近当前时间的课程放入 self.nextCourse
                            self.nextCourse[theCourse.ref.documentID] = theCourse
                            self.nextStudentCourse[theCourse.ref.documentID] = efStudentCourse
                        }
                    } else {
                        
                        //获取当前课程
                        //取得 theCourse 结束的时间
                        if let theCourseEndTime = Calendar.current.date(byAdding: .minute, value: 30*theCourse.amount, to: theCourse.date){
                            
                            //如果当前时间在theCourse开始和结束之间，则放入 self.thisCourse
                            if theCourse.date < Date() && Date() < theCourseEndTime || efStudentCourse.status == .scaned || efStudentCourse.status == .approved || efStudentCourse.status == .noTrainer || efStudentCourse.status == .noStudent || efStudentCourse.status == .ill{
                                self.thisCourse = theCourse
                                self.thisStudentCourse = efStudentCourse
                            }
                        }
                        
                        //记录已完成的课时
                        //只有在状态为 scaned 的时候才记入总完成的课时
                        if efStudentCourse.status == .scaned {
                            self.TotalCourseFinished += theCourse.amount
                            if theCourse.date > Date().startOfMonth(){
                                self.MonthCourseFinished += theCourse.amount
                            }
                        }
                        
                        //获取第一节课
                        //比较时间并将最早的课程放入 self.firstCourse
                        if efStudentCourse.status != .waitForTrainer && efStudentCourse.status != .waitForStudent && efStudentCourse.status != .approved {
                            if self.firstCourse == nil {
                                self.firstCourse = theCourse
                            } else {
                                if theCourse.date < self.firstCourse.date{
                                    self.firstCourse = theCourse
                                }
                            }
                        }
                    }
                } else {
                }
            }
        }
        self.collectionView?.reloadData()
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
        //EFCollectionViewCellWithNextCourse
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithNextCourse", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithNextCourse")
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithButton", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithButton")
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithProgress", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithProgress")
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithLargeNumber", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithLargeNumber")
        
        collectionView?.register(UINib.init(nibName: "EFExtentableHeaderCellWithButton", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "EFExtentableHeaderCellWithButton")
        collectionView?.register(UINib.init(nibName: "EFExtentableHeaderCellWithLabel", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "EFExtentableHeaderCellWithLabel")
        collectionView?.register(UINib.init(nibName: "EFViewHeaderCellWithStudentCourse", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "EFViewHeaderCellWithStudentCourse")

        if let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.estimatedItemSize = CGSize(width: (collectionView?.frame.width)! - 2*12 , height: 200)
            flowlayout.sectionHeadersPinToVisibleBounds = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        /*
        if collectionView.numberOfItems(inSection: section) == 0{
            return CGSize(width: 0, height: 0)
        } else {
            
        }
        */
        if section == 2{
            if thisCourse == nil {
                return CGSize(width: (collectionView.frame.width) - 2*12 , height: 52)
            } else {
                return CGSize(width: (collectionView.frame.width) - 2*12 , height: 222)
            }
        } else {
            return CGSize(width: (collectionView.frame.width) - 2*12 , height: 52)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return EFRequest.requestList.count
        case 1:
            return 4
        case 2:
            return 0
        case 3:
            return self.nextCourse.count
        default:
            return 0
        }
    }

    
    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EFExtentableHeaderCellWithButton", for: indexPath) as! EFExtentableHeaderCellWithButton
            if EFRequest.requestList.count == 0 {
                cell.TitleBarColor = HexColor.black.withAlphaComponent(0.2)
                cell.TitleLabel.textColor = UIColor.black
                cell.TitleLabel.text = "暂时没有申请记录"
            } else {
                cell.TitleBarColor = HexColor.Red
                cell.TitleLabel.textColor = UIColor.white
                cell.TitleLabel.text = "共有\(EFRequest.requestList.count)则申请"
            }
            
            if EFRequest.requestList.count > 1 {
                cell.BarButton.isHidden = false
            } else {
                cell.BarButton.isHidden = true
            }
            
            cell.BarButtonFunction = { () in
                for cells in self.collectionView!.visibleCells {
                    if let cell = cells as? EFCollectionViewCellWithButton {
                        if !cell.AgreeBtn.isHidden {
                            cell.function()
                        }
                    }
                }
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EFExtentableHeaderCellWithLabel", for: indexPath) as! EFExtentableHeaderCellWithLabel
            cell.TitleLabel.textColor = UIColor.white
            cell.TitleBarColor = HexColor.Yellow
            cell.TitleLabel.text = "本月目标已完成"
            let percentageValue:Float = min(Float(MonthCourseFinished)/Float(self.thisStudent.goal), 1)
            let percentage = String(format: "%.0f", 100 * percentageValue)
            cell.BarRightLabel.text = "\(percentage)%"
            return cell
        case 2:
            if thisCourse == nil {
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EFExtentableHeaderCellWithLabel", for: indexPath) as! EFExtentableHeaderCellWithLabel
                cell.TitleBarColor = HexColor.black.withAlphaComponent(0.2)
                cell.TitleLabel.text = "现在没有在上课"
                cell.TitleLabel.textColor = UIColor.black
                cell.BarRightLabel.text = ""
                return cell
            } else {
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EFViewHeaderCellWithStudentCourse", for: indexPath) as! EFViewHeaderCellWithStudentCourse
                
                
                cell.DateLabel.text = thisCourse!.date.DateString
                cell.TimeLabel.text = "\(thisCourse!.date.TimeString) 开始的课程"
                
                switch enumService.toMultiCourseStataus(list: thisCourse!.getTraineesStatus) {
                case .approved:
                    cell.TitleBarColor = HexColor.Blue
                    cell.statusCircleColor = nil
                    cell.TitleLabel.text = "当前正在上课"
                    cell.BarRightLabel.text = "尚未扫码"
                    cell.StatusLabel.text = "教练尚未扫码"
                    cell.StatusFootNote.text = "要及时找教练扫码哟！"
                    cell.reportBtn.isHidden = false
                case .scaned:
                    cell.TitleBarColor = HexColor.Green
                    cell.statusCircleColor = HexColor.Green
                    cell.TitleLabel.text = "当前正在上课"
                    cell.BarRightLabel.text = "已扫码"
                    cell.StatusLabel.text = "教练已扫码完成"
                    cell.StatusFootNote.text = "本课程已记录，加油锻炼！"
                    cell.reportBtn.isHidden = true
                default:
                    switch thisStudentCourse.status {
                    case .ill:
                        cell.TitleBarColor = HexColor.Purple
                        cell.statusCircleColor = HexColor.Purple
                        cell.TitleLabel.text = "当前正在上课"
                        cell.BarRightLabel.text = "学生生病"
                        cell.StatusLabel.text = "已被教练记录为生病"
                        cell.StatusFootNote.text = "祝早日康复"
                        cell.reportBtn.isHidden = true
                    case .noStudent:
                        cell.TitleBarColor = HexColor.Red
                        cell.statusCircleColor = HexColor.Red
                        cell.TitleLabel.text = "当前正在上课"
                        cell.BarRightLabel.text = "学生生病"
                        cell.StatusLabel.text = "已被教练记录为旷课"
                        cell.StatusFootNote.text = "以后别再别旷课了"
                        cell.reportBtn.isHidden = true
                    case .noCard:
                        cell.TitleBarColor = HexColor.Purple
                        cell.statusCircleColor = HexColor.Purple
                        cell.TitleLabel.text = "当前正在上课"
                        cell.BarRightLabel.text = "学生没带卡"
                        cell.StatusLabel.text = "已被教练记录为旷课"
                        cell.StatusFootNote.text = "下次记得带"
                        cell.reportBtn.isHidden = true
                    case .noTrainer:
                        cell.TitleBarColor = HexColor.Yellow
                        cell.statusCircleColor = HexColor.Yellow
                        cell.TitleLabel.text = "当前正在上课"
                        cell.BarRightLabel.text = "教练未到"
                        cell.StatusLabel.text = "已举报教练没来"
                        cell.StatusFootNote.text = "如果教练扫码则举报无效"
                        cell.reportBtn.isHidden = true
                    default:
                        cell.TitleBarColor = HexColor.Purple
                        cell.statusCircleColor = HexColor.Purple
                        cell.TitleLabel.text = "当前正在上课"
                        cell.BarRightLabel.text = "未知情况"
                        cell.StatusLabel.text = "未知情况"
                        cell.StatusFootNote.text = "未知情况"
                        cell.reportBtn.isHidden = true
                    }
                }
                return cell
            }
        default:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EFExtentableHeaderCellWithLabel", for: indexPath) as! EFExtentableHeaderCellWithLabel
            
            if nextCourse.count == 0{
                cell.TitleBarColor = HexColor.black.withAlphaComponent(0.2)
                cell.TitleLabel.textColor = UIColor.black
                cell.TitleLabel.text = "之后暂无课程"
                cell.BarRightLabel.text = ""
            } else {
                cell.TitleLabel.textColor = UIColor.white
                cell.TitleBarColor = HexColor.Blue
                cell.TitleLabel.text = "之后的课程"
                cell.BarRightLabel.text = "共\(nextCourse.count)项记录"
            }
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithButton", for: indexPath) as! EFCollectionViewCellWithButton
            cell.alpha = 1
            cell.waitView.isHidden = true
            
            cell.AgreeBtn.isHidden = false
            
            if EFRequest.requestList.count <= indexPath.row{
                return cell
            } else {
                let efRequest = EFRequest.requestList[indexPath.row]
                cell.TitleLabel.text = efRequest.title
                
                if efRequest.type == .studentApproveCourse{
                    if let theRequestStudentCourse = thisStudent.courseDic[efRequest.requestRef.documentID]{
                        if let theRequestCourse = DataServer.courseDic[theRequestStudentCourse.courseRef.documentID]{
                            let startTime = theRequestCourse.date
                            cell.startTime = startTime
                            if startTime < Date(){
                                cell.AgreeBtn.isHidden = true
                                cell.ContentLabel.text = "该申请已过期，\(startTime.descriptDate())"
                            } else if CourseRegisteredNumber - TotalCourseFinished - theRequestCourse.amount <= 1{
                                cell.AgreeBtn.isHidden = true
                                cell.ContentLabel.text = "无法接受申请，余课不足，请尽快充值"
                            } else {
                                cell.AgreeBtn.isHidden = false
                                cell.ContentLabel.text = "添加 \(startTime.descriptDate()) 长度为 \(prepareCourseNumber(theRequestCourse.amount)) 小时的课程"
                            }
                        }
                    }
                }
                cell.efRequest = efRequest
                return cell
            }
        case 1:
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithProgress", for: indexPath) as! EFCollectionViewCellWithProgress
                
                let percentageValue:Float = min(Float(MonthCourseFinished)/Float(self.thisStudent.goal), 1)
                
                let percentage = String(format: "%.0f", 100 * percentageValue)
                cell.TitleLabel.text = "我的目标"
                cell.ContentLabel.text = "目标已达成 \(percentage)%"
                cell.ContentFootNote.text = "本月目标为 \(prepareCourseNumber(self.thisStudent.goal)) 节课，达成之后会有奖励哦!"
                cell.ProgressBar.progress = percentageValue
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithLargeNumber", for: indexPath) as! EFCollectionViewCellWithLargeNumber
                if indexPath.row == 1 {
                    cell.TitleLabel.text = "本月完成课时"
                    cell.LargeNumber.text = prepareCourseNumber(self.MonthCourseFinished)
                    cell.LargeNumber.textColor = UIColor.black
                } else if indexPath.row == 2 {
                    cell.TitleLabel.text = "总完成课时"
                    cell.LargeNumber.text = prepareCourseNumber(self.TotalCourseFinished)
                    cell.LargeNumber.textColor = UIColor.black
                } else {
                    cell.TitleLabel.text = "剩余课时数"
                    cell.LargeNumber.text = prepareCourseNumber(self.CourseRegisteredNumber - self.TotalCourseFinished)
                    if self.CourseRegisteredNumber - self.TotalCourseFinished < 10 {
                        cell.TitleLabel.text = "请尽快充值，剩余课时不多了！"
                        cell.LargeNumber.textColor = HexColor.Red
                    }
                    
                }
                return cell
            }
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithNextCourse", for: indexPath) as! EFCollectionViewCellWithNextCourse
            let listOfCourse = nextCourse.values.sorted { (a, b) -> Bool in
                return a.date < b.date
            }
            if indexPath.row < listOfCourse.count {
                let theCourse = listOfCourse[indexPath.row]
                cell.TitleLabel.text = "\(theCourse.date.descriptDate()) 开始的课程"
                cell.DateLabel.text = theCourse.date.DateString
                cell.TimeLabel.text = "\(theCourse.date.TimeString) 开始的课程"
                cell.TextLabel.text = theCourse.note
            }
            
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithNextCourse", for: indexPath) as! EFCollectionViewCellWithNextCourse
            return cell
        }
        
        /*
        switch indexPath.row{
            
           //下一节课/当前课程
        case EFRequest.requestList.count + 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableBoard", for: indexPath) as! TimeTabelCell
            
            cell.backgroundColor = UIColor.white
            cell.titleLabel.text = "下一节课"
            
            
            
            //课程开始之后才能使用举报教练未到的功能
            if let thisCourse = self.thisCourse, let thisStudentCourse = self.thisStudentCourse{
                cell.thisStudentCourseRef = thisStudentCourse.ref
                if (Date() > thisCourse.date && thisStudentCourse.status == .approved){
                    cell.report.isHidden = false
                } else {
                    cell.report.isHidden = true
                }
            }
            
            
            cell.requirChangeBtn.isHidden = true
            
            
            
            if self.thisCourse != nil{
                //如果当前课程存在
                
                if let currentStudentCouser = thisStudent.courseDic[thisCourse.ref.documentID]{
                    print(enumService.toString(e: currentStudentCouser.status))
                    print(self.thisCourse.note)
                    switch currentStudentCouser.status {
                    case courseStatus.scaned:
                        cell.titleLabel.text = "正在上课（已成功扫码）"
                        cell.backgroundColor = HexColor.Green.withAlphaComponent(0.3)
                        cell.dateLabel.text = self.thisCourse.dateOnlyString
                        cell.TimeLabel.text = self.thisCourse.timeOnlyString
                        cell.noteLabel.text = self.thisCourse.note
                        cell.report.isHidden = false
                    case courseStatus.noTrainer:
                        cell.titleLabel.text = "正在上课（已举报教练未到）"
                        cell.backgroundColor = HexColor.red.withAlphaComponent(0.3)
                        cell.dateLabel.text = self.thisCourse.dateOnlyString
                        cell.TimeLabel.text = self.thisCourse.timeOnlyString
                        cell.noteLabel.text = "如果教练未及时扫码，则记为教练未到"
                        cell.report.isHidden = false
                    case courseStatus.ill:
                        cell.titleLabel.text = "祝早日康复"
                        cell.backgroundColor = HexColor.red.withAlphaComponent(0.3)
                        cell.dateLabel.text = ""
                        cell.TimeLabel.text = ""
                        cell.noteLabel.text = self.thisCourse.note
                        cell.report.isHidden = false
                    case courseStatus.noCard, .noCardFirst:
                        cell.titleLabel.text = "你是不是健忘症啊，你怎么不带银行卡"
                        cell.backgroundColor = HexColor.red.withAlphaComponent(0.3)
                        cell.dateLabel.text = ""
                        cell.TimeLabel.text = ""
                        cell.noteLabel.text = self.thisCourse.note
                        cell.report.isHidden = false
                    case courseStatus.noStudent, .noStudentFirst:
                        cell.titleLabel.text = "你离你的目标又远了，亲"
                        cell.backgroundColor = HexColor.red.withAlphaComponent(0.3)
                        cell.dateLabel.text = ""
                        cell.TimeLabel.text = ""
                        cell.noteLabel.text = self.thisCourse.note
                        cell.report.isHidden = false
                    case courseStatus.other:
                        cell.titleLabel.text = self.thisCourse.note
                        cell.backgroundColor = HexColor.red.withAlphaComponent(0.3)
                        cell.dateLabel.text = ""
                        cell.TimeLabel.text = ""
                        cell.noteLabel.text = ""
                        cell.report.isHidden = false
                    default:
                        cell.titleLabel.text = "正在上课"
                        cell.backgroundColor = HexColor.blue.withAlphaComponent(0.3)
                        cell.dateLabel.text = self.thisCourse.dateOnlyString
                        cell.TimeLabel.text = self.thisCourse.timeOnlyString
                        cell.noteLabel.text = self.thisCourse.note
                        cell.report.isHidden = false
                    }
                } else {
                    cell.titleLabel.text = "正在读取……"
                    cell.backgroundColor = HexColor.Purple.withAlphaComponent(0.3)
                    cell.dateLabel.text = ""
                    cell.TimeLabel.text = ""
                    cell.noteLabel.text = ""
                    cell.report.isHidden = true
                }
                
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
            return cell
            
        case EFRequest.requestList.count:
            //当月成就
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThisMonthCourseBoard",
                                                          for: indexPath) as! ThisMonthViewCell
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(finishedCourse))
            cell.addGestureRecognizer(gesture)
            
            cell.backgroundColor = UIColor.white
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
                cell.backgroundColor = UIColor.white
                cell.title.text = "剩余课程"
            }
            cell.totalCourseLabel.text = "/\(prepareCourseNumber(self.CourseRegisteredNumber))"
            cell.remainCourseLabel.text = "\(prepareCourseNumber(self.CourseRegisteredNumber - self.TotalCourseFinished))"
            return cell
            //申请
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestBoard",
                                                          for: indexPath) as! RequestCell
            cell.self.alpha = 1
            cell.waitView.isHidden = true
            
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
                            cell.startTime = startTime
                            if startTime < Date(){
                                cell.approveBtn.isHidden = true
                                cell.requestDiscriptionLabel.text = "该申请已过期，\(startTime.descriptDate())"
                                cell.backgroundColor = UIColor.red.withAlphaComponent(0.1)
                            } else {
                                cell.approveBtn.isHidden = false
                                cell.requestDiscriptionLabel.text = "添加 \(startTime.descriptDate()) 长度为 \(prepareCourseNumber(theRequestCourse.amount)) 小时的课程"
                                cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                            }
                        }
                    }
                }
                
                cell.efRequest = efRequest
                return cell
            }
        }
 */
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
