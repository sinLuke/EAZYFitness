//
//  TimeTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class TimeTableViewController: DefaultViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, refreshableVC {
    
    
    
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var addCourseButton: UIBarButtonItem!
    var db:Firestore!
    var cMemberID:String?
    var collectionRef: [String: CollectionReference]!
    let _refreshControl = UIRefreshControl()
    let __refreshControl = UIRefreshControl()
    
    @IBOutlet weak var noCourseLabel: UIView!
    @IBOutlet weak var timetableView: UIScrollView!
    
    var StudentCourseList:[String:[[String:Any]]] = [:]
    var dref:Any!
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timetablecell", for: indexPath) as! TimeTableViewTableCell
        if let courseDic = StudentCourseList[Array(StudentCourseList.keys)[indexPath.section]]![indexPath.row] as? [String:Any]{
            cell.courseLabel.text = "课时：\(prepareCourseNumber(courseDic["Amount"] as! Int))"
            cell.noteLabel.text = courseDic["Note"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            if let date = courseDic["Date"] as? Date{
                cell.timeLabel.text = "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"
            }
            if (courseDic["Record"] as! Bool) == true{
                if (courseDic["Type"] as! String) == "General"{
                    cell.typeLabel.text = "状态：正常"
                    cell.typeLabel.textColor = HexColor.Green
                } else if (courseDic["Type"] as! String) == "Exception" {
                    cell.typeLabel.text = "状态：异常"
                    cell.typeLabel.textColor = HexColor.Red
                }
            } else {
                cell.typeLabel.text = "状态：尚未完成"
                cell.typeLabel.textColor = UIColor.gray
            }
            if (courseDic["Approved"] as! Bool) == false{
                cell.typeLabel.text = "学生尚未确定"
                cell.typeLabel.textColor = UIColor.lightGray
                cell.noteLabel.textColor = UIColor.lightGray
                cell.timeLabel.textColor = UIColor.lightGray
                cell.courseLabel.textColor = UIColor.lightGray
                cell.backgroundColor = HexColor.lightColor
            } else {
                cell.noteLabel.textColor = UIColor.black
                cell.timeLabel.textColor = UIColor.black
                cell.courseLabel.textColor = UIColor.black
                cell.backgroundColor = UIColor.white
            }
        }
        return cell
    }
    
    func reload() {
        self.timeTableCourseTable.reloadData()
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
        if AppDelegate.AP().usergroup == "student"{
            return nil
        } else {
            if self.StudentCourseList[Array(self.StudentCourseList.keys)[section]]?.count == 0{
                return nil
            } else {
                return Array(self.StudentCourseList.keys)[section]
            }
        }
    }
    
    func refresh() {
        
        self.startLoading()
        noCourseLabel.isHidden = true
        if let existTimetable = timetable{
            existTimetable.removeFromSuperview()
        }
        timetable = TimeTableView(frame: CGRect(x: 0, y: 0, width: timetableView.frame.width, height: timetableView.frame.height))
        TimeTable.makeTimeTable(on: timetable!, withRef: collectionRef, startoftheweek: Date().startOfWeek(), handeler: self.resizeViews)
        timetableView.addSubview(timetable!)
        
        
        if let _dref = dref as? CollectionReference{
            _dref.whereField("Record", isEqualTo: false).order(by: "Date").getDocuments { (snap, err) in
                var CourseList:[[String : Any]] = []
                if let err = err{
                    AppDelegate.showError(title: "读取购买时发生错误", err: err.localizedDescription)
                } else {
                    if let documentList = snap?.documents{
                        for docDic in documentList{
                            CourseList.append(docDic.data())
                        }
                        if AppDelegate.AP().usergroup == "student"{
                            self.StudentCourseList["我的课程"] = CourseList
                        } else {
                            self.StudentCourseList["该学员的课程"] = CourseList
                        }
                    }
                    self.reload()
                }
            }
        } else if let _dref = dref as? [String: CollectionReference] {
            for refs in Array(_dref.keys){
                _dref[refs]!.whereField("Record", isEqualTo: false).order(by: "Date").getDocuments { (snap, err) in
                    var CourseList:[[String : Any]] = []
                    if let err = err{
                        AppDelegate.showError(title: "读取购买时发生错误", err: err.localizedDescription)
                    } else {
                        if let documentList = snap?.documents{
                            for docDic in documentList{
                                var docdic = docDic.data()
                                docdic["student"] = docDic.documentID
                                CourseList.append(docdic)
                            }
                            self.StudentCourseList[refs] = CourseList
                        }
                        self.reload()
                    }
                }
            }
        }
    }
    
    @IBAction func addCourseAction(_ sender: Any) {
        self.performSegue(withIdentifier: "courseDetail", sender: self)
    }
    
    
    override func viewDidLoad() {
        noCourseLabel.isHidden = true
        super.viewDidLoad()
        addCourseButton.tintColor = HexColor.Pirmary
        
        if cMemberID == nil || AppDelegate.AP().usergroup == "student" {
            addCourseButton.isEnabled = false
        } else{
            addCourseButton.isEnabled = true
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
            if AppDelegate.AP().usergroup == "student"{
                if let MemberID = self.cMemberID{
                    dvc.collectionRef = [" ": db.collection("student").document(MemberID).collection("CourseRecorded")]
                }
            } else {
                dvc.collectionRef = self.collectionRef
            }
        } else if let dvc = segue.destination as? CourseInfoViewController{
            dvc.collectionRef = self.collectionRef
            dvc.用来加课的refrence = dref as! CollectionReference
        }
    }
}
