//
//  StudentFinishedTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/1.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class StudentFinishedTableViewController: DefaultTableViewController {
    
    let _refreshControl = UIRefreshControl()
    var CourseList:[ClassObj] = []
    
    var studentCourseRef:CollectionReference!
    
    override func refresh() {
        CourseList = []
        ActivityViewController.callStart += 1
        studentCourseRef.getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取课程时发生错误", err: err.localizedDescription)
            } else {
                if let documentList = snap?.documents{
                    for docDic in documentList{
                        let classObj = ClassObj()
                        let courseRef = docDic["ref"] as! DocumentReference
                        classObj.courseRef = courseRef
                        
                        classObj.trainer = docDic["trainer"] as! DocumentReference
                        self.getCourseInfo(ref: courseRef, classObj: classObj)
                        self.CourseList.append(classObj)
                    }
                }
                self.reload()
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    func getCourseInfo(ref:DocumentReference, classObj:ClassObj){
        ActivityViewController.callStart += 1
        ref.getDocument { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取课程时发生错误", err: err.localizedDescription)
            } else {
                if let dic = snap!.data(){
                    classObj.note = dic["note"] as! String
                    classObj.amount = dic["amount"] as! Int
                    classObj.date = dic["date"] as! Date
                    self.getListOfStudentInCourse(ref: ref.collection("trainee"), classObj: classObj)
                    self.reload()
                } else {
                    AppDelegate.showError(title: "未知错误", err: "读取课程信息时发生错误")
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    func getListOfStudentInCourse(ref:CollectionReference, classObj:ClassObj){
        ActivityViewController.callStart += 1
        ref.getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "获得上课学员时发生错误", err: err.localizedDescription)
            } else {
                for doc in snap!.documents{
                    if snap!.documents.count == 1{
                        classObj.type = courseType.general
                    } else {
                        classObj.type = courseType.multiple
                    }
                    if let studentRef = doc["ref"] as? DocumentReference{
                        classObj.student.append(studentRef)
                        ActivityViewController.callStart += 1
                        studentRef.getDocument(completion: { (snap, err) in
                            if let err = err{
                                AppDelegate.showError(title: "读取学员信息时发生错误", err: err.localizedDescription)
                            } else {
                                if let StudentDic = snap!.data(){
                                    classObj.studentName[studentRef.documentID] = ("\(StudentDic["First Name"]) \(StudentDic["Last Name"])")
                                    classObj.status[studentRef.documentID] = enumService.toCourseStatus(s: StudentDic["status"] as! String)
                                    self.reload()
                                }
                            }
                            ActivityViewController.callEnd += 1
                        })
                    } else {
                        AppDelegate.showError(title: "未知错误", err: "读取学员信息时发生错误")
                    }
                }
            }
            ActivityViewController.callEnd += 1
        }
    }
    
    override func reload() {
        print("reload")
        tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        print("handleRefresh")
        refreshControl.endRefreshing()
        self.refresh()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        print("viewDidLoad")
        
        self.refresh()
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.tableView.refreshControl = self._refreshControl
        self.tableView.addSubview(self._refreshControl)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections")
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableView")
        // #warning Incomplete implementation, return the number of rows
        return CourseList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "finishedCell", for: indexPath) as! FinishedTableViewCell
        let courseObj = CourseList[indexPath.row]
        
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
        print("courseObj.status.count")
        print(courseObj.status.count)
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
        return cell
    }

    func prepareCourseNumber(_ int:Int) -> String{
        print("prepareCourseNumber")
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
