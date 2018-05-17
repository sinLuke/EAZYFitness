//
//  TimeTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class TimeTableViewController: DefaultViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var addCourseButton: UIBarButtonItem!
    var db:Firestore!
    var cMemberID:String?
    var collectionRef: [String: CollectionReference]!
    let _refreshControl = UIRefreshControl()
    let __refreshControl = UIRefreshControl()
    
    @IBOutlet weak var noCourseLabel: UIView!
    @IBOutlet weak var timetableView: UIScrollView!
    var allCourseList:[String:ClassObj] = [:]
    var StudentCourseList:[String:[ClassObj]] = [:]
    var dref:Any!
    var sdref:[CollectionReference] = []
    @IBOutlet weak var timeTableCourseTable: UITableView!
    
    
    
    var timetable:TimeTableView?
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return StudentCourseList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentCourseList[Array(StudentCourseList.keys)[section]]!.count
    }
    
    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let i = Array(StudentCourseList.keys)[indexPath.section]
            if let courseObjs = StudentCourseList[i]{
                let courseObj = courseObjs[indexPath.row]
                if let ref = courseObj.courseRef{
                    ref.delete()
                    for studentRef in courseObj.student{
                        studentRef.delete()
                    }
                    StudentCourseList[i]!.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    AppDelegate.showError(title: "无法删除", err: "找不到对应的文档", of: self)
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timetablecell", for: indexPath) as! TimeTableViewTableCell
        if let courseObjs = StudentCourseList[Array(StudentCourseList.keys)[indexPath.section]]{
            let courseObj = courseObjs[indexPath.row]
            cell.courseLabel.text = "课时：\(prepareCourseNumber(courseObj.amount))"
            cell.noteLabel.text = courseObj.note
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            if let date = courseObj.date{
                cell.timeLabel.text = "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"
            }
            
            
            cell.typeLabel.textColor = UIColor.black
            cell.noteLabel.textColor = UIColor.black
            cell.timeLabel.textColor = UIColor.black
            cell.courseLabel.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
            
            var allapproved = true
            var allScaned = true
            var exception = false
            var notrainer = false
            for statu in courseObj.status.values{
                if statu == courseStatus.waitForStudent{
                    allapproved = false
                }
                if statu == courseStatus.ill || statu == courseStatus.noStudent || statu == courseStatus.noTrainer || statu == courseStatus.noCard{
                    exception = true
                }
                if statu != courseStatus.scaned{
                    allScaned = false
                }
                if statu == courseStatus.noTrainer{
                    notrainer = true
                }
            }
            cell.typeLabel.text = "复杂情况"
            if !allapproved{
                cell.typeLabel.text = "等待所有学生同意"
                cell.typeLabel.textColor = HexColor.gray
                cell.noteLabel.textColor = HexColor.gray
                cell.timeLabel.textColor = HexColor.gray
                cell.courseLabel.textColor = HexColor.gray
                cell.backgroundColor = HexColor.lightColor
            }
            if exception{
                cell.typeLabel.text = "有异常情况"
                cell.typeLabel.textColor = HexColor.Red
            }
            if notrainer{
                cell.typeLabel.text = "教练没来"
                cell.typeLabel.textColor = HexColor.Red
            }
            if allScaned{
                cell.typeLabel.text = "全部扫码通过"
                cell.backgroundColor = HexColor.Green.withAlphaComponent(0.2)
            }
            if courseObj.status.count == 1 {
                
                let status = Array(courseObj.status.values)[0]
                cell.typeLabel.text = enumService.toDescription(e: status)
                switch status {
                case .waitForStudent:
                    cell.typeLabel.textColor = HexColor.gray
                    cell.noteLabel.textColor = HexColor.gray
                    cell.timeLabel.textColor = HexColor.gray
                    cell.courseLabel.textColor = HexColor.gray
                    cell.backgroundColor = HexColor.lightColor
                case .ill, .noStudent, .noCard, .noTrainer:
                    cell.typeLabel.textColor = HexColor.Red
                case .scaned:
                    cell.backgroundColor = HexColor.Green.withAlphaComponent(0.2)
                default:
                    cell.typeLabel.textColor = UIColor.black
                }
            }
        }
        return cell
    }
    
    override func reload() {
        print("allCourseList")
        print(allCourseList)
        for courseObj in Array(self.allCourseList.values){
            self.StudentCourseList = [:]
            print("courseObj")
            print(courseObj.student)
            print(courseObj.allStudentName)
            if self.StudentCourseList[courseObj.allStudentName] == nil {
                self.StudentCourseList[courseObj.allStudentName] = [courseObj]
            } else {
                self.StudentCourseList[courseObj.allStudentName]?.append(courseObj)
            }
        }
        
        for key in self.StudentCourseList.keys{
            self.StudentCourseList[key]?.sort(by: { (a, b) -> Bool in
                return a.date < b.date
            })
        }
        timetable = TimeTableView(frame: CGRect(x: 0, y: 0, width: timetableView.frame.width, height: timetableView.frame.height))
        TimeTable.makeTimeTabel(on: timetable!, with: self.StudentCourseList, startoftheweek: Date().startOfWeek(), handeler: self.resizeViews)
        timetableView.addSubview(timetable!)

        self.timeTableCourseTable.reloadData()
    }
    
    @objc func courseTapped(_ gesture:UITapGestureRecognizer){
        if let block = gesture.view as? CourseBlock{
            AppDelegate.showError(title: "Tapped", err: block.courseRef.path)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.timetableView{
            if let theTop = timetable?.topView{
                timetable?.bringSubview(toFront: theTop)
                if scrollView.contentOffset.y >= 0{
                    theTop.layer.shadowColor = UIColor.black.cgColor
                    theTop.layer.shadowOpacity = 0.15
                    theTop.layer.shadowOffset = CGSize(width: 0, height: 1)
                    theTop.layer.shadowRadius = 3
                    if scrollView.contentOffset.y != 0{
                        theTop.clipsToBounds = false
                    } else {
                        theTop.clipsToBounds = true
                    }
                    theTop.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: theTop.frame.width, height: theTop.frame.height)
                    
                }else {
                    theTop.clipsToBounds = true
                    theTop.frame = CGRect(x: 0, y: 0, width: theTop.frame.width, height: theTop.frame.height)
                }
            }
        }
    }
    
    @IBAction func fullscreen(_ sender: Any) {
        performSegue(withIdentifier: "full", sender: self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if AppDelegate.AP().group == userGroup.student{
            return nil
        } else {
            if self.StudentCourseList[Array(self.StudentCourseList.keys)[section]]?.count == 0{
                return nil
            } else {
                return Array(self.StudentCourseList.keys)[section]
            }
        }
    }
    
    override func refresh() {
        self.noCourseLabel.isHidden = true
        self.startLoading()
        noCourseLabel.isHidden = true
        if let existTimetable = timetable{
            existTimetable.removeFromSuperview()
        }
        
        if let _dref = dref as? CollectionReference{
            _dref.getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "读取购买时发生错误", err: err.localizedDescription)
                    self.endLoading()
                } else {
                    if let documentList = snap?.documents{
                        var CourseList:[ClassObj] = []
                        for docDic in documentList{
                            let classObj = ClassObj()
                            let courseRef = docDic["ref"] as! DocumentReference
                            classObj.courseRef = courseRef
                            classObj.trainer = docDic["trainer"] as! DocumentReference
                            self.getCourseInfo(ref: courseRef, classObj: classObj)
                            print(CourseList)
                            CourseList.append(classObj)
                        }
                        if documentList.count == 0{
                            self.noCourseLabel.isHidden = false
                            self.endLoading()
                        }
                        if AppDelegate.AP().group == userGroup.student{
                            self.StudentCourseList["我的课程"] = CourseList
                        } else {
                            self.StudentCourseList["该学员的课程"] = CourseList
                        }
                    } else {
                        self.noCourseLabel.isHidden = false
                        self.endLoading()
                    }
                }
            }
        } else if let _dref = dref as? [String: CollectionReference] {
            self.allCourseList = [:]
            for refs in Array(_dref.keys){
                _dref[refs]!.getDocuments { (snap, err) in
                    if let err = err{
                        AppDelegate.showError(title: "读取购买时发生错误", err: err.localizedDescription)
                        self.endLoading()
                    } else {
                        if let documentList = snap?.documents{
                            for docDic in documentList{
                                let classObj = ClassObj()
                                let courseRef = docDic["ref"] as! DocumentReference
                                classObj.courseRef = courseRef
                                classObj.trainer = docDic["trainer"] as! DocumentReference
                                self.getCourseInfo(ref: courseRef, classObj: classObj)
                                self.allCourseList[classObj.courseRef.documentID] = classObj
                            }
                            if documentList.count == 0{
                                self.noCourseLabel.isHidden = false
                                self.endLoading()
                            }
                            self.endLoading()
                        } else {
                            self.noCourseLabel.isHidden = false
                            self.endLoading()
                        }
                    }
                }
                
            }
            if Array(_dref.keys).count == 0{
                self.noCourseLabel.isHidden = false
                self.endLoading()
            }
        }
    }
    
    func getCourseInfo(ref:DocumentReference, classObj:ClassObj){
        ref.getDocument { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取课程时发生错误", err: err.localizedDescription)
                self.endLoading()
            } else {
                if let dic = snap!.data(){
                    print(dic)
                    classObj.note = dic["note"] as! String
                    classObj.amount = dic["amount"] as! Int
                    classObj.date = dic["date"] as! Date
                    self.getListOfStudentInCourse(ref: ref.collection("trainee"), classObj: classObj)
                    print("getCourseInfo")
                } else {
                    AppDelegate.showError(title: "未知错误", err: "读取课程信息时发生错误")
                    self.endLoading()
                    
                }
            }
        }
    }
    
    func getListOfStudentInCourse(ref:CollectionReference, classObj:ClassObj){
        ref.getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "获得上课学员时发生错误", err: err.localizedDescription)
                self.endLoading()
            } else {
                print("getListOfStudentInCourse1")
                print(snap?.count)
                for doc in snap!.documents{
                    if snap!.documents.count == 1{
                        classObj.type = courseType.general
                    } else {
                        classObj.type = courseType.multiple
                    }
                    if let studentRef = doc["ref"] as? DocumentReference{
                        classObj.student.append(studentRef)
                        studentRef.getDocument(completion: { (snap, err) in
                            if let err = err{
                                AppDelegate.showError(title: "读取学员信息时发生错误", err: err.localizedDescription)
                            } else {
                                if let StudentDic = snap!.data(){
                                    print("StudentDic")
                                    print(StudentDic)
                                    classObj.studentName[studentRef.parent.parent!.documentID] = FirestoreService.studentNameInfo[studentRef.parent.parent!.documentID]
                                    classObj.status[studentRef.parent.parent!.documentID] = enumService.toCourseStatus(s: StudentDic["status"] as! String)
                                    print("studentName")
                                    print(classObj.studentName)
                                    self.reload()
                                    self.endLoading()
                                } else {
                                    AppDelegate.showError(title: "未知错误", err: "读取学员姓名时出现问题")
                                    self.endLoading()
                                }
                            }
                        })
                    } else {
                        AppDelegate.showError(title: "未知错误", err: "读取学员信息时发生错误")
                        self.endLoading()
                    }
                }
            }
        }
        self.endLoading()
    }
    
    @IBAction func addCourseAction(_ sender: Any) {
        
        
        if let _ = self.dref as? CollectionReference{
            self.performSegue(withIdentifier: "courseDetail", sender: self)
        } else if let _ = self.dref as? [String: CollectionReference]{
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: "selection") as! SelectionNavigationViewController
            if let dref = dref as? [String:CollectionReference]{
                var listOfStudent:[String] = []
                for student in FirestoreService.trainerStudentInfo[AppDelegate.AP().currentMemberID!]!{
                    listOfStudent.append(student.documentID)
                }
                vc.listOfStudent = listOfStudent
                vc.listOnlyContainNames = false
                vc.handler = self.handleStudentSelection
                self.present(vc, animated: true)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if AppDelegate.AP().group == userGroup.student{
            return false
        } else {
            return true
        }
    }
    
    
    // Override to support editing the table view.
    
    
    
    override func viewDidLoad() {
        noCourseLabel.isHidden = true
        super.viewDidLoad()
        addCourseButton.tintColor = HexColor.Pirmary
        
        if AppDelegate.AP().group == userGroup.student{
            self.addCourseButton.isEnabled = false
        } else {
            self.addCourseButton.isEnabled = true
        }
        
        db = Firestore.firestore()
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        __refreshControl.attributedTitle = NSAttributedString(string: title)
        __refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        __refreshControl.tintColor = HexColor.Pirmary
        
        self.timetableView.refreshControl = self._refreshControl
        self.timeTableCourseTable.refreshControl = self.__refreshControl
        self.timetableView.addSubview(self._refreshControl)
        self.timeTableCourseTable.addSubview(self.__refreshControl)
        
        tableViewContainer.layer.shadowColor = UIColor.black.cgColor
        tableViewContainer.layer.shadowOpacity = 0.15
        tableViewContainer.layer.shadowOffset = CGSize(width: 0, height: -1)
        tableViewContainer.layer.shadowRadius = 3
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
        if AppDelegate.AP().group == userGroup.student{
            self.addCourseButton.isEnabled = false
        } else {
            self.addCourseButton.isEnabled = true
        }
    }

    
    func resizeViews(maxHeight:CGFloat)->(){
        if maxHeight == 0{
            self.endLoading()
            noCourseLabel.isHidden = false
        } else {
            noCourseLabel.isHidden = true
            self.endLoading()
            self.timetableView.contentSize = CGSize(width: self.view.frame.width, height: maxHeight)
            self.timetable?.frame = CGRect(x: (self.timetable?.frame.minX)!, y: (self.timetable?.frame.minY)!, width: self.view.frame.width, height: maxHeight)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? TimeTableFullScreenViewController{
            if AppDelegate.AP().group == userGroup.student{
                if let MemberID = self.cMemberID{
                    dvc.StudentCourseList = self.StudentCourseList
                }
            } else {
                dvc.StudentCourseList = self.StudentCourseList
            }
            dvc.showDate = Date()
            dvc.title = "本周"
        } else if let dvc = segue.destination as? CourseInfoViewController{
            if segue.identifier == "courseDetail"{
                dvc.collectionRef = self.collectionRef
                if let _dref = dref as? CollectionReference{
                    dvc.用来加课的refrence = [_dref]
                    dvc.StudentCourseList = self.StudentCourseList
                }
            } else if segue.identifier == "courseDetailList"{
                dvc.collectionRef = self.collectionRef
                if let _dref = dref as? [String: CollectionReference]{
                    dvc.StudentCourseList = self.StudentCourseList
                    dvc.用来加课的refrence = self.sdref
                }
            }
        }
    }
    
    func handleStudentSelection(StudentID:[String]){
        if let _dref = dref as? [String: CollectionReference], StudentID.count > 0{
            self.sdref = []
            for student in StudentID{
                if let studentName = FirestoreService.studentNameInfo[student]{
                    self.sdref.append(_dref[studentName]!)
                }
            }
            self.performSegue(withIdentifier: "courseDetailList", sender: self)
        }
    }
}
