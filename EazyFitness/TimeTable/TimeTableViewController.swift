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
    
    var theStudentOrTrainer:Any!
    var startoftheweek:Date!
    
    var tableHeightValue:CGFloat = 350
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var addCourseButton: UIBarButtonItem!
    var db:Firestore!
    var cMemberID:String?
    
    let _refreshControl = UIRefreshControl()
    let __refreshControl = UIRefreshControl()
    
    @IBOutlet weak var noCourseLabel: UIView!
    @IBOutlet weak var timetableView: UIScrollView!
    var allCourseList:[String:EFCourse] = [:]
    var StudentCourseList:[String:[EFCourse]] = [:]
    var studentListToManageCourse:[EFStudent] = []
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.timetableView{
            self.tableHide()
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let i = Array(StudentCourseList.keys)[indexPath.section]
            if let courseObjs = StudentCourseList[i]{
                let courseObj = courseObjs[indexPath.row]
                let ref = courseObj.ref
                ref.delete()
                for studentCourseRef in courseObj.traineeStudentCourseRef{
                    studentCourseRef.delete()
                }
                StudentCourseList[i]!.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
            let date = courseObj.date
            cell.timeLabel.text = "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"

            cell.typeLabel.textColor = UIColor.black
            cell.noteLabel.textColor = UIColor.black
            cell.timeLabel.textColor = UIColor.black
            cell.courseLabel.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
            
            let statusList = courseObj.getTraineesStatus
            cell.typeLabel.text = enumService.toDescription(d: statusList)
            cell.typeLabel.textColor = enumService.toColor(d: statusList)
        } else {
            cell.noteLabel.text = "课程读取错误"
        }
        return cell
    }
    
    override func reload() {
        
        if let existTimetable = timetable{
            existTimetable.removeFromSuperview()
        }
        
        var timeTableList : [String:[EFCourse]] = [:]
        
        for course in Array(DataServer.courseDic.values){
            var contain = true
            
            if let thisTrainer = theStudentOrTrainer as? EFTrainer{
                for traineeref in course.traineeRef{
                    if !thisTrainer.trainee.contains(traineeref){
                        contain = false
                    }
                }
            } else if let thisStudent = theStudentOrTrainer as? EFStudent{
                if course.traineeRef.contains(thisStudent.ref){
                    contain = true
                } else {
                    contain = false
                }
            }
            
            if course.date < self.startoftheweek.startOfWeek() || course.date > self.startoftheweek.endOfWeek() {
                contain = false
            }
            if contain{
                
                if timeTableList[course.getTraineesNames] == nil {
                    timeTableList[course.getTraineesNames] = [course]
                } else {
                    timeTableList[course.getTraineesNames]?.append(course)
                }
            }
        }

        if timeTableList.count == 1{
            if AppDelegate.AP().ds?.usergroup == userGroup.student{
                self.StudentCourseList = [:]
                self.StudentCourseList["我的课程"] = timeTableList.first!.value
            } else {
                self.StudentCourseList = timeTableList
            }
        } else {
            self.StudentCourseList = timeTableList
        }
        
        for key in self.StudentCourseList.keys{
            self.StudentCourseList[key]?.sort(by: { (a, b) -> Bool in
                return a.date < b.date
            })
        }

        self.timeTableCourseTable.reloadData()
        
        timetable = TimeTableView(frame: CGRect(x: 0, y: 0, width: timetableView.frame.width, height: timetableView.frame.height))
        TimeTable.makeTimeTabel(on: timetable!, with: self.StudentCourseList, startoftheweek: startoftheweek.startOfWeek(), handeler: self.resizeViews)
        timetableView.addSubview(timetable!)

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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if AppDelegate.AP().ds?.usergroup == userGroup.student{
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
        for student in self.studentListToManageCourse{
            student.download()
        }
        self.noCourseLabel.isHidden = true
        noCourseLabel.isHidden = true
        
        self.reload()
    }
    
    @IBAction func addCourseAction(_ sender: Any) {
        if let theTrainer = self.theStudentOrTrainer as? EFTrainer{
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: "selection") as! SelectionNavigationViewController
            var listOfStudent:[EFStudent] = []
            for studentRef in theTrainer.trainee{
                print(DataServer.studentDic)
                if let theStudent = DataServer.studentDic[studentRef.documentID]{
                    listOfStudent.append(theStudent)
                }
            }
            vc.listOfStudent = listOfStudent
            vc.handler = self.handleStudentSelection
            self.present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if AppDelegate.AP().ds?.usergroup == userGroup.student{
            return false
        } else {
            return true
        }
    }
    
    
    // Override to support editing the table view.
    
    
    func tableShow(){
        var offset = 350 - self.tableHeight.constant
        if offset < 0 {
            offset = -offset
        }
        self.tableHeight.constant = 350
        UIView.animate(withDuration: TimeInterval(offset/700)) {
            self.view.layoutIfNeeded()
        }
    }
    
    func tableHide(){
        var offset = 44 - self.tableHeight.constant
        if offset < 0 {
            offset = -offset
        }
        self.tableHeight.constant = 44
        UIView.animate(withDuration: TimeInterval(offset/700)) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed{
            var threshold:CGFloat = 300
            if self.tableHeight.constant >= 175{
                threshold = 300
            } else {
                threshold = 94
            }
            if self.tableHeight.constant >= threshold {
                self.tableShow()
            } else {
                self.tableHide()
            }
        } else if recognizer.state == .began{
            tableHeightValue = self.tableHeight.constant
        } else {
            let translation  = recognizer.translation(in: self.view)
            self.tableHeight.constant = tableHeightValue - translation.y
            self.view.layoutIfNeeded()
        }
    }
    @objc func detectTap(_ recognizer:UITapGestureRecognizer) {
        print(detectTap)
        if self.tableHeight.constant >= 175 {
            self.tableHide()
        } else {
            self.tableShow()
        }
    }
    
    override func viewDidLoad() {
        noCourseLabel.isHidden = true
        super.viewDidLoad()
        addCourseButton.tintColor = HexColor.Pirmary
        
        if AppDelegate.AP().ds?.usergroup == userGroup.student{
            self.addCourseButton.isEnabled = false
        } else {
            self.addCourseButton.isEnabled = true
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
        self.navBar.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detectTap))
        self.navBar.addGestureRecognizer(tapGesture)
        
        tableHeightValue = self.tableHeight.constant
        
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
        if AppDelegate.AP().ds?.usergroup == userGroup.student{
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
        if let dvc = segue.destination as? TimeTableViewController{
            dvc.StudentCourseList = self.StudentCourseList
            dvc.startoftheweek = Calendar.current.date(byAdding: .day, value: 7, to: self.startoftheweek)
            dvc.theStudentOrTrainer = self.theStudentOrTrainer
            if self.title == "本周"{
                dvc.title = "下周"
            } else {
                dvc.title = "下\(self.title!)"
            }
            
        } else if let dvc = segue.destination as? CourseInfoViewController{
            if segue.identifier == "courseDetail"{
                dvc.studentListToManageCourse = self.studentListToManageCourse
                dvc.StudentCourseList = self.StudentCourseList
                dvc.thisTrainer = self.theStudentOrTrainer as! EFTrainer
            }
        }
    }
    
    func handleStudentSelection(Student:[EFStudent]){
        if Student.count > 2 {
            AppDelegate.showError(title: "无法添加", err: "暂时只支持到双人课")
        } else if Student.count > 0 {
            self.studentListToManageCourse = Student
            self.performSegue(withIdentifier: "courseDetail", sender: self)
        }
    }
}
