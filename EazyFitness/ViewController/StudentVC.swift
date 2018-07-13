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
                        if enumService.toMultiCourseStataus(list: theCourse.traineesStatus) == multiCourseStatus.approved{
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
                            if (theCourse.date < Date() && Date() < theCourseEndTime) && (theCourse.traineesMultiStatus != multiCourseStatus.waitForStudent && theCourse.traineesMultiStatus != multiCourseStatus.waitForTrainer && theCourse.traineesMultiStatus != multiCourseStatus.decline && theCourse.traineesMultiStatus != multiCourseStatus.someApproved) {
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
            flowlayout.estimatedItemSize = CGSize(width: (collectionView?.frame.width)! - 2*12 , height: 300)
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
                print(thisCourse!.traineesStatus)
                switch enumService.toMultiCourseStataus(list: thisCourse!.traineesStatus) {
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
                        cell.StatusFootNote.text = "你离你的目标又远了，亲"
                        cell.reportBtn.isHidden = true
                    case .noCard:
                        cell.TitleBarColor = HexColor.Purple
                        cell.statusCircleColor = HexColor.Purple
                        cell.TitleLabel.text = "当前正在上课"
                        cell.BarRightLabel.text = "学生没带卡"
                        cell.StatusLabel.text = "已被教练记录为旷课"
                        cell.StatusFootNote.text = "你是不是健忘症啊，你怎么不带银行卡"
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
                        cell.StatusFootNote.text = thisStudentCourse.note
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
                            cell.AgreeBtn.isUserInteractionEnabled = true
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
                    if self.CourseRegisteredNumber - self.TotalCourseFinished < 10 {
                        cell.TitleLabel.text = "请尽快充值，剩余课时不多了！"
                        cell.LargeNumber.textColor = HexColor.Red
                    } else {
                        cell.TitleLabel.text = "剩余课时数"
                        cell.LargeNumber.text = prepareCourseNumber(self.CourseRegisteredNumber - self.TotalCourseFinished)
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
                cell.TextLabel.text = "\(enumService.toDescription(e: enumService.toMultiCourseStataus(list: theCourse.traineesStatus)))\n\(theCourse.note)"
            }
            
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithNextCourse", for: indexPath) as! EFCollectionViewCellWithNextCourse
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0, 1, 2:
                self.performSegue(withIdentifier: "course", sender: self)
            default:
                self.performSegue(withIdentifier: "purchase", sender: self)
            }
        } else if indexPath.section == 3 {
            let courseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CourseDetailInfoViewController") as! CourseDetailInfoViewController
            let listOfCourse = nextCourse.values.sorted { (a, b) -> Bool in
                return a.date < b.date
            }
            if indexPath.row < listOfCourse.count {
                let theCourse = listOfCourse[indexPath.row]
                courseVC.thisCourse = theCourse
                self.present(courseVC, animated: true, completion: nil)
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
            dvc.title = "我的购买记录"
        }
        if let dvc = segue.destination as? CourseTableViewController{
            dvc.thisStudentOrTrainer = self.thisStudent
            dvc.title = "我的课程"
        }
    }
}
