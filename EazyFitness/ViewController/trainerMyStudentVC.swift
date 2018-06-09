//
//  trainerMyStudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class trainerMyStudentVC: DefaultCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var thisTrainer:EFTrainer!
    
    let _refreshControl = UIRefreshControl()

    var myStudentCollectionView:UICollectionView?
    
    var TimeTolerant:Int = 20
    
    var TotalCourseFinished:Int = 0
    var MonthCourseFinished:Int = 0
    var nextCourse:[String: EFCourse] = [:]
    var thisCourse:EFCourse? = nil
    var studentCourseForCourse:[String: [EFStudentCourse]] = [:]
    
    var goal:Int = 0
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func refresh() {
        print("refresh")
        thisTrainer.download()
        
        //获取申请
        EFRequest.getRequestForCurrentUser(type: nil)
        
        self.reload()
    }
    
    
    
    
    override func reload() {
        if let _ds = AppDelegate.AP().ds{
            self.title = "\(_ds.fname) \(_ds.lname)"
        }
        
        
        self.thisCourse = nil
        self.nextCourse = [:]
        self.studentCourseForCourse = [:]
        TotalCourseFinished = 0
        MonthCourseFinished = 0
        
        
        
        for theStudentRef in self.thisTrainer.trainee{
            if let thisStudent = DataServer.studentDic[theStudentRef.documentID]{
                for efStudentCourse in thisStudent.courseDic.values{
                    //通过课程引用取得课程
                    if let theCourse = DataServer.courseDic[efStudentCourse.courseRef.documentID]{
                        
                        if self.studentCourseForCourse[theCourse.ref.documentID] == nil {
                            self.studentCourseForCourse[theCourse.ref.documentID] = [efStudentCourse]
                        } else {
                            self.studentCourseForCourse[theCourse.ref.documentID]?.append(efStudentCourse)
                        }
                        
                        
                        
                        //如果课程发生在未来
                        if theCourse.date > Date(){
                            
                            //获取下一节课
                            //比较时间并将最接近当前时间的课程放入 self.nextCourse
                            if enumService.toMultiCourseStataus(list: theCourse.traineesStatus) != .decline{
                                self.nextCourse[theCourse.ref.documentID] = theCourse
                            }
                        } else {
                            //获取当前课程
                            //取得 theCourse 结束的时间
                            if let theCourseEndTime = Calendar.current.date(byAdding: .minute, value: 30*theCourse.amount, to: theCourse.date){
                                //如果当前时间在theCourse开始和结束之间，则放入 self.thisCourse
                                let statusList = theCourse.traineesStatus
                                let multiStatus = enumService.toMultiCourseStataus(list: statusList)
                                if theCourse.date < Date() && Date() < theCourseEndTime && enumService.ifCourseValid(s: multiStatus) {
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
        
        
        self.collectionView?.reloadData()
        self.myStudentCollectionView?.reloadData()
    }
    

    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let offset = (thisCourse == nil ? 0 : 1) + (nextCourse.count == 0 ? 0 : 1)
        
        if indexPath.section == 0 {
            if indexPath.row < offset {
                
                self.performSegue(withIdentifier: "trainerCourseVC", sender: self)
                
            }
        } else if indexPath.section == 1 {
            self.performSegue(withIdentifier: "course", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thisTrainer = (self.tabBarController as! TrainerTabBarController).thisTrainer
        
        if #available(iOS 11.0, *), UIScreen.main.bounds.height >= 330{
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            
        }
        
        self.refresh()
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.collectionView!.refreshControl = self._refreshControl
        self.collectionView!.addSubview(self._refreshControl)
        
        
        collectionView?.register(UINib.init(nibName: "EFExtentableHeaderCellWithButton", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "EFExtentableHeaderCellWithButton")
        collectionView?.register(UINib.init(nibName: "EFExtentableHeaderCellWithLabel", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "EFExtentableHeaderCellWithLabel")
        
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithProgress", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithProgress")
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithLargeNumber", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithLargeNumber")
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithNextCourse", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithNextCourse")
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithDetailDisclosure", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithDetailDisclosure")
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithButton", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithButton")
        
        if let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.estimatedItemSize = CGSize(width: (collectionView?.frame.width)! - 2*12 , height: 200)
            flowlayout.sectionHeadersPinToVisibleBounds = true
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        /*
         if collectionView.numberOfItems(inSection: section) == 0{
         return CGSize(width: 0, height: 0)
         } else {
         
         }
         */
        return CGSize(width: (collectionView.frame.width) - 2*12 , height: 52)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return EFRequest.requestList.count + (thisCourse == nil ? 0 : 1) + (nextCourse.count == 0 ? 0 : 1)
        case 1:
            return 3
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
        let numberOfNotfication = EFRequest.requestList.count + (thisCourse == nil ? 0 : 1) + (nextCourse.count == 0 ? 0 : 1)
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EFExtentableHeaderCellWithLabel", for: indexPath) as! EFExtentableHeaderCellWithLabel
        switch indexPath.section {
        case 0:
            if numberOfNotfication > 0{
                cell.TitleBarColor = HexColor.Red
                cell.TitleLabel.text = "通知"
                cell.TitleLabel.textColor = UIColor.white
                cell.BarRightLabel.text = "共有\(numberOfNotfication)条通知"
            } else {
                cell.TitleBarColor = UIColor.black.withAlphaComponent(0.3)
                cell.TitleLabel.text = "通知"
                cell.TitleLabel.textColor = UIColor.black
                cell.BarRightLabel.text = "暂时没有通知"
            }
            
            return cell
            
        default:
            
            cell.TitleLabel.textColor = UIColor.white
            cell.TitleBarColor = HexColor.Yellow
            cell.TitleLabel.text = "本月目标已完成"
            let percentageValue:Float = min(Float(MonthCourseFinished)/Float(self.thisTrainer.goal), 1)
            let percentage = String(format: "%.0f", 100 * percentageValue)
            cell.BarRightLabel.text = "\(percentage)%"
            
            return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let offset = (thisCourse == nil ? 0 : 1) + (nextCourse.count == 0 ? 0 : 1)
            if indexPath.row >= offset {
                //申请部分
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithButton", for: indexPath) as! EFCollectionViewCellWithButton
                cell.alpha = 1
                cell.waitView.isHidden = true
                
                cell.AgreeBtn.isHidden = false
                
                if EFRequest.requestList.count > indexPath.row - offset{
                    let efRequest = EFRequest.requestList[indexPath.row - offset]
                    cell.TitleLabel.text = efRequest.title
                    cell.ContentLabel.text = efRequest.text
                    cell.efRequest = efRequest
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithDetailDisclosure", for: indexPath) as! EFCollectionViewCellWithDetailDisclosure
                if indexPath.row == 0 {
                    if thisCourse != nil {
                        //当前课程
                        cell.TitleLabel.text = "现在正在上课"
                        cell.detailLabel.text = "查看详情"
                        cell.bkImg.image = #imageLiteral(resourceName: "thisCourse.jpg")
                    } else {
                        cell.TitleLabel.text = "接下来还有\(nextCourse.count)节课"
                        cell.detailLabel.text = "查看详情"
                        cell.bkImg.image = #imageLiteral(resourceName: "nextCourse.jpg")
                    }
                } else if indexPath.row == 1 {
                    cell.TitleLabel.text = "接下来还有\(nextCourse.count)节课"
                    cell.detailLabel.text = "查看详情"
                    cell.bkImg.image = #imageLiteral(resourceName: "nextCourse.jpg")
                }
                return cell
            }
        default:
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithProgress", for: indexPath) as! EFCollectionViewCellWithProgress
                
                let percentageValue:Float = min(Float(MonthCourseFinished)/Float(self.thisTrainer.goal), 1)
                
                let percentage = String(format: "%.0f", 100 * percentageValue)
                cell.TitleLabel.text = "我的目标"
                cell.ContentLabel.text = "目标已达成 \(percentage)%"
                cell.ContentFootNote.text = "本月目标为 \(prepareCourseNumber(self.thisTrainer.goal)) 节课，达成之后会有奖励哦!"
                cell.ProgressBar.progress = percentageValue
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFCollectionViewCellWithLargeNumber", for: indexPath) as! EFCollectionViewCellWithLargeNumber
                if indexPath.row == 1 {
                    cell.TitleLabel.text = "本月完成课时"
                    cell.LargeNumber.text = prepareCourseNumber(self.MonthCourseFinished)
                    cell.LargeNumber.textColor = UIColor.black
                } else {
                    cell.TitleLabel.text = "总完成课时"
                    cell.LargeNumber.text = prepareCourseNumber(self.TotalCourseFinished)
                    cell.LargeNumber.textColor = UIColor.black
                }
                return cell
            }

            /*
            if let thisCourse = thisCourse {
                let stduentRef = thisCourse.traineeRef[indexPath.row]
                if let student = DataServer.studentDic[stduentRef.documentID], let studentCourse = student.courseDic[thisCourse.ref.documentID]{
                    cell.StatusLabel.text = student.name
                    cell.StatusFootNote.text = enumService.toDescription(e: studentCourse.status)
                    cell.statusCircleColor = enumService.toColor(e: studentCourse.status)
                    if studentCourse.status == .approved {
                        cell.StatusFootNote.text = "该学生尚未扫码"
                        cell.statusCircleColor = nil
                    }
                } else {
                    cell.StatusLabel.text = "学生读取失败"
                    cell.StatusFootNote.text = "课程状态读取失败"
                    cell.statusCircleColor = nil
                }
            } else {
                cell.StatusLabel.text = "课程读取失败"
                cell.StatusFootNote.text = "课程读取失败"
            }
 */
        
        }
        
        /*
        switch indexPath.row{
            
        case ((self.thisStudentCourse.count)) + EFRequest.requestList.count:
            //下一节课
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableBoard",
                                                          for: indexPath) as! TrainerNextCell
            
            cell.titleLabel.text = "下一节课"
            if self.thisCourse != nil{
                //如果当前课程存在
                cell.noteLabel.text = self.thisCourse!.note
                cell.backgroundColor = HexColor.Blue.withAlphaComponent(0.3)
                cell.dateLabel.text = self.thisCourse!.dateOnlyString
                cell.TimeLabel.text = self.thisCourse!.timeOnlyString
                if enumService.toMultiCourseStataus(list: thisCourse!.traineesStatus) == .noTrainer {
                    cell.titleLabel.text = "你被学生出卖了"
                    cell.backgroundColor = HexColor.Red.withAlphaComponent(0.3)
                } else {
                    cell.titleLabel.text = "正在上课"
                    
                    cell.backgroundColor = HexColor.Red.withAlphaComponent(0.3)
                }
                
                cell.studentNameLabel.text = self.thisCourse!.getTraineesNames
                
            } else if self.nextCourse != nil{
                
                //如果下一节课存在
                cell.backgroundColor = UIColor.white
                cell.dateLabel.text = self.nextCourse!.dateOnlyString
                cell.TimeLabel.text = self.nextCourse!.timeOnlyString
                cell.noteLabel.text = self.nextCourse!.note
                cell.studentNameLabel.text = self.nextCourse!.getTraineesNames
                
            } else {
                cell.backgroundColor = UIColor.white
                cell.dateLabel.text = ""
                cell.TimeLabel.text = "暂无课程"
                cell.noteLabel.text = ""
            }
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
                cell.backgroundColor = UIColor.white
                cell.progress.tintColor = HexColor.Pirmary
            }
            
            return cell
        default:
            if indexPath.row < ((self.thisCourse?.traineeStudentCourseRef.count) ?? 0){
                //扫码通知
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scanBoard",
                                                              for: indexPath) as! TrainerScanCell
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
                                
                                let recorded = !(cell.thisStudentCourse.status == courseStatus.approved || cell.thisStudentCourse.status == courseStatus.noTrainer)
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
                                    if ((cell.thisStudentCourse.status == courseStatus.approved || cell.thisStudentCourse.status == courseStatus.noTrainer) && Date() > Calendar.current.date(byAdding: .minute, value: self.TimeTolerant, to: startTime)!){
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
                        }
                    }
                    
                    cell.efRequest = efRequest
                    return cell
                }
            }
        }
 */
        
    }
    
    @objc func finishedCourse(){
        performSegue(withIdentifier: "finish", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dvc = segue.destination as? trainerCourseVC{
            if let indexPath = collectionView?.indexPathsForSelectedItems?.first{
                if indexPath.row == 0 {
                    if thisCourse != nil {
                        //当前课程
                        dvc.thisMode = .thisCourse
                    } else {
                        dvc.thisMode = .nextCourse
                    }
                } else if indexPath.row == 1 {
                    dvc.thisMode = .nextCourse
                }
            }
            dvc.thisTrainer = self.thisTrainer
        }
        
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
                dvc.ref = Firestore.firestore().collection("trainer").document(cmid).collection("Finished")
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
