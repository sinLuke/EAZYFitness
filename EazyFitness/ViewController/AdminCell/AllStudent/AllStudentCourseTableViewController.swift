//
//  AllStudentCourseTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
class AllStudentCourseTableViewController: DefaultTableViewController {
    
    let _refreshControl = UIRefreshControl()
    var courseList:[String:[String:Any]] = [:]
    var FinishedcourseList:[String:[String:Any]] = [:]
    var thisStudent:EFStudent!
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
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
        
        self.tableView.refreshControl = self._refreshControl
        self.tableView.addSubview(self._refreshControl)
        self.refresh()
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
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return FinishedcourseList.keys.count
        } else {
            return courseList.keys.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "已完成的课"
        } else {
            return "未完成的课"
        }
    }
    
    override func refresh() {
        
        thisStudent.ref.collection("course").order(by: "Date").getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取课程时发生错误", err: err.localizedDescription, of: self)
            } else {
                for doc in snap!.documents{
                    var docdic = doc.data()
                    docdic["ref"] = doc.reference
                    let coursID = doc.documentID
                    self.courseList[coursID] = docdic
                    self.getTrainerInfo(coursID: coursID)
                }
            }
            self.reload()
        }
 
    }
    
    func getTrainerInfo(coursID:String){
        Firestore.firestore().collection("trainer").getDocuments(completion: { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取课程教练时发生错误", err: err.localizedDescription, of: self)
            } else {
                for doc in snap!.documents{
                    doc.reference.collection("Finished").whereField("CourseID", isEqualTo: coursID).getDocuments(completion: { (snap, err) in
                        if let err = err{
                            AppDelegate.showError(title: "读取课程教练时发生错误", err: err.localizedDescription, of: self)
                        } else {
                            if snap!.documents.count >= 1{
                                var trainerDocs = snap!.documents[0].data()
                                trainerDocs["ref"] = snap!.documents[0].reference
                                trainerDocs["Name"] = "\(doc.data()["First Name"]!) \(doc.data()["Last Name"]!)"
                                self.FinishedcourseList[coursID] = self.courseList[coursID]
                                self.courseList.removeValue(forKey: coursID)
                                self.FinishedcourseList[coursID]!["trainerDoc"] = trainerDocs
                            }
                        }
                        self.reload()
                    })
                }
            }
        })
    }
    
    override func reload() {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AllStudentCourseTableTableViewCell
        
        let dateformater = DateFormatter()
        dateformater.dateStyle = .short
        dateformater.timeStyle = .short
        print(self.FinishedcourseList)
        print(self.courseList)
        if indexPath.section == 0{
            if let dic = self.FinishedcourseList[Array(self.FinishedcourseList.keys)[indexPath.row]]{
                cell.trainerLabel.text = "\(indexPath.section)--"
                cell.timeLabel.text = dateformater.string(from: dic["Date"] as! Date)
                cell.AmountLabel.text = "课时数：\(prepareCourseNumber(dic["Amount"] as! Int))"
                if dic["Approved"] as! Bool == false{
                    cell.RecordLabel.text = "学生未同意"
                } else {
                    if dic["Record"] as! Bool == false{
                        cell.RecordLabel.text = "学生显示未记录"
                    } else {
                        cell.RecordLabel.text = "已记录"
                    }
                }
                cell.noteLabel.text = dic["Note"] as! String
                print(dic["trainerDoc"])
                if let tdic = dic["trainerDoc"] as? [String:Any]{
                    cell.trainerLabel.text = tdic["Name"] as? String ?? ""
                    cell.noteLabel.text = "\(cell.noteLabel.text ?? "")\n\(tdic["Note"] as? String ?? "")"
                    if tdic["FinishedType"] as? String == "Exception"{
                        cell.exceptionLabel.text = "异常"
                    }else if tdic["FinishedType"] as? String == "Scaned"{
                        cell.exceptionLabel.text = "已刷卡"
                    }
                }
            }
        } else if indexPath.section == 1 {
            if let dic = self.courseList[Array(self.courseList.keys)[indexPath.row]]{
                cell.timeLabel.text = dateformater.string(from: dic["Date"] as! Date)
                cell.AmountLabel.text = "课时数：\(prepareCourseNumber(dic["Amount"] as! Int))"
                if dic["Approved"] as! Bool == false{
                    cell.RecordLabel.text = "学生未同意"
                } else {
                    if dic["Record"] as! Bool == false{
                        cell.RecordLabel.text = "未记录"
                    } else {
                        cell.RecordLabel.text = "学生显示已记录"
                    }
                }
                cell.noteLabel.text = dic["Note"] as! String
                cell.trainerLabel.text = "课程未完成"
                if dic["notrainer"] as! Bool {
                    cell.exceptionLabel.text = "教练没来"
                }
                if dic["nostudent"] as! Bool {
                    cell.exceptionLabel.text = "学生没来"
                }
                
            }
        }
        return cell
    }
    
    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
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
