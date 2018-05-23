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
    var listedCourse:[EFCourse] = []
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
        self.listedCourse = []
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
        } else if let thisTrainer = thisStudentOrTrainer as? EFTrainer{
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
        
        self.listedCourse.sorted { (x, y) -> Bool in
            return x.date > y.date
        }
        self.courseTable.reloadData()
    }
    
    func loadInfo(efCourse:EFCourse, status:courseStatus){
        switch self.typerSelector.selectedSegmentIndex {
        case 0: //全部
            self.listedCourse.append(efCourse)
            
            self.listedCourseStatus[efCourse.ref.documentID] = [status]
        case 1: //已完成
            if AppDelegate.AP().ds?.usergroup == .student || AppDelegate.AP().ds?.usergroup == .trainer{
                if status == .scaned {
                    self.listedCourse.append(efCourse)
                    self.listedCourseStatus[efCourse.ref.documentID] = [status]
                }
            } else {
                if status == .scaned || status == .noStudent || status == .ill || status == .noCard {
                    self.listedCourse.append(efCourse)
                    self.listedCourseStatus[efCourse.ref.documentID] = [status]
                }
            }
        case 2: //未完成
            if status == .approved || status == .noTrainer {
                self.listedCourse.append(efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = [status]
            }
        case 3: //异常
            if status == .ill || status == .noTrainer || status == .noStudent || status == .noCard || status == .other {
                self.listedCourse.append(efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = [status]
            }
        default:
            break
        }
    }
    
    func loadInfo(efCourse:EFCourse){
        var statusList:[courseStatus] = efCourse.getTraineesStatus
        
        switch self.typerSelector.selectedSegmentIndex {
        case 0: //全部
            self.listedCourse.append(efCourse)
            
            self.listedCourseStatus[efCourse.ref.documentID] = statusList
        case 1: //已完成
            if enumService.toDescription(d: statusList) == "已全部扫描" || enumService.toDescription(d: statusList) == "有特殊情况" {
                self.listedCourse.append(efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = statusList
            }
        case 2: //未完成
            if enumService.toDescription(d: statusList) == "教练未到" || enumService.toDescription(d: statusList) == "所有学生已同意" {
                self.listedCourse.append(efCourse)
                self.listedCourseStatus[efCourse.ref.documentID] = statusList
            }
        case 3: //异常
            if enumService.toDescription(d: statusList) == "有特殊情况" || enumService.toDescription(d: statusList) == "等待教练同意" || enumService.toDescription(d: statusList) == "等待所有学生同意" || enumService.toDescription(d: statusList) == "有学生尚未同意" || enumService.toDescription(d: statusList) == "有人未同意但有人已扫码" || enumService.toDescription(d: statusList) == "没有全部扫码" || enumService.toDescription(d: statusList) == "未知情况" {
                self.listedCourse.append(efCourse)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listedCourse.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "有\(self.listedCourse.count)条记录"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        let efCourse = self.listedCourse[indexPath.row]
        cell.note.text = efCourse.note
        cell.date.text = efCourse.dateString
        cell.amount.text = efCourse.amountString
        if let status = self.listedCourseStatus[efCourse.ref.documentID]{
            print("status")
            print(status)
            cell.status.textColor = enumService.toColor(d: status)
            cell.status.text = enumService.toDescription(d: status)
        } else {
            cell.status.text = "未知"
        }
        
        return cell
    }
}
