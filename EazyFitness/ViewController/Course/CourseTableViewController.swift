//
//  CourseTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/17.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class CourseTableViewController: DefaultViewController, UITableViewDelegate, UITableViewDataSource {
    
    let _refreshControl = UIRefreshControl()
    var thisStudentOrTrainer:EFData!
    var listedCourse:[String:[EFCourse]] = [:]
    var listedCourseStatus:[String:[courseStatus]] = [:]
    
    @IBOutlet weak var timeSelecter: UISegmentedControl!
    
    @IBOutlet weak var typerSelector: UISegmentedControl!
    
    @IBOutlet weak var courseTable: UITableView!
    
    @IBAction func timeValueChanged(_ sender: Any) {
        self.reload()
    }
    @IBAction func typeValueChanged(_ sender: Any) {
        self.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")

        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.courseTable.refreshControl = self._refreshControl
        self.courseTable.addSubview(self._refreshControl)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func refresh() {
        thisStudentOrTrainer.download()
        self.reload()
    }
    
    override func reload() {
        self.listedCourseStatus = [:]
        self.listedCourse = [:]
        if let thisStudent = thisStudentOrTrainer as? EFStudent{
            for efStudentCourse in thisStudent.courseDic.values {
                if let efCourse = DataServer.courseDic[efStudentCourse.courseRef.documentID]{
                    switch self.timeSelecter.selectedSegmentIndex{
                    case 0: //全部
                        self.loadInfo(efCourse: efCourse, status: efStudentCourse.status)
                    case 1: //本月
                        if efCourse.date > Date().startOfMonth(){
                            self.loadInfo(efCourse: efCourse, status: efStudentCourse.status)
                        }
                    case 2: //未来
                        if efCourse.date > Date(){
                            self.loadInfo(efCourse: efCourse, status: efStudentCourse.status)
                        }
                    default: break
                    }
                }
            }
        } else if (thisStudentOrTrainer as? EFTrainer) != nil{
            
            for efCourse in DataServer.courseDic{
                switch self.timeSelecter.selectedSegmentIndex{
                case 0: //全部
                    self.loadInfo(efCourse: efCourse.value)
                case 1: //本月
                    if efCourse.value.date > Date().startOfMonth(){
                        self.loadInfo(efCourse: efCourse.value)
                    }
                case 2: //未来
                    if efCourse.value.date > Date(){
                        self.loadInfo(efCourse: efCourse.value)
                    }
                default: break
                }
            }
        }
        print(self.listedCourse)
        self.courseTable.reloadData()
    }
    
    func appendCourse(efCourse:EFCourse){
        if (thisStudentOrTrainer as? EFTrainer) != nil{
            if self.listedCourse[efCourse.getTraineesNames] == nil {
                self.listedCourse[efCourse.getTraineesNames] = [efCourse]

            } else {
                self.listedCourse[efCourse.getTraineesNames]?.append(efCourse)
                self.listedCourse[efCourse.getTraineesNames]?.sort(by: { (a, b) -> Bool in
                    a.date < b.date
                })

            }
        } else if (thisStudentOrTrainer as? EFStudent) != nil{
            if self.listedCourse["我的课程"] == nil {
                self.listedCourse["我的课程"] = [efCourse]
            } else {
                self.listedCourse["我的课程"]?.append(efCourse)
                self.listedCourse["我的课程"]?.sort(by: { (a, b) -> Bool in
                    a.date < b.date
                })
            }
        }
        
    }
    
    func loadInfo(efCourse:EFCourse, status:courseStatus){
        switch self.typerSelector.selectedSegmentIndex {
        case 0: //全部
            self.appendCourse(efCourse: efCourse)
            
            self.listedCourseStatus[efCourse.ref.documentID] = [status]
        case 1: //已完成
            if AppDelegate.AP().ds?.usergroup == .student || AppDelegate.AP().ds?.usergroup == .trainer{
                if status == .scaned {
                    self.appendCourse(efCourse: efCourse)
                    self.listedCourseStatus[efCourse.ref.documentID] = [status]
                }
            } else {
                if status == .scaned || status == .noStudent || status == .ill || status == .noCard {
                    self.appendCourse(efCourse: efCourse)
                    self.listedCourseStatus[efCourse.ref.documentID] = [status]
                }
            }
        case 2: //未完成
            if status == .approved || status == .noTrainer {
                self.appendCourse(efCourse: efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = [status]
            }
        case 3: //异常
            if status == .ill || status == .noTrainer || status == .noStudent || status == .noCard || status == .other {
                self.appendCourse(efCourse: efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = [status]
            }
        default:
            break
        }
    }
    
    func loadInfo(efCourse:EFCourse){
        let statusList:[courseStatus] = efCourse.getTraineesStatus
        let multiStatus = enumService.toMultiCourseStataus(list: statusList)
        switch self.typerSelector.selectedSegmentIndex {
        case 0: //全部
            self.appendCourse(efCourse: efCourse)
            
            self.listedCourseStatus[efCourse.ref.documentID] = statusList
        case 1: //已完成
            if enumService.FinishedAmountForAdmin(s: multiStatus) == 1{
                self.appendCourse(efCourse: efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = statusList
            }
        case 2: //未完成
            if enumService.FinishedAmountForAdmin(s: multiStatus) == 0 && multiStatus != .special && multiStatus != .other{
                self.appendCourse(efCourse: efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = statusList
            }
        case 3: //异常
            if multiStatus == .special && multiStatus == .other  {
                self.appendCourse(efCourse: efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = statusList
            }
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    func numberOfSections(in tableView: UITableView) -> Int {
        return self.listedCourse.keys.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let studentName = Array(self.listedCourse.keys.sorted())[section]
        return self.listedCourse[studentName]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let studentName = Array(self.listedCourse.keys.sorted())[section]
        return studentName
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        let studentName = Array(self.listedCourse.keys.sorted())[indexPath.section]
        let efCourse = self.listedCourse[studentName]![indexPath.row]
        cell.note.text = efCourse.note
        cell.date.text = efCourse.dateString
        cell.amount.text = efCourse.amountString
        if let status = self.listedCourseStatus[efCourse.ref.documentID]{
            let multiStatus = enumService.toMultiCourseStataus(list: status)
            cell.status.textColor = enumService.toColor(d: multiStatus)
            cell.backgroundColor = enumService.toColor(d: multiStatus).withAlphaComponent(0.02)
            cell.colorStrip.backgroundColor = enumService.toColor(d: multiStatus)
            cell.status.text = enumService.toDescription(e: multiStatus)
        } else {
            cell.status.text = "未知"
        }
        
        return cell
    }
}
