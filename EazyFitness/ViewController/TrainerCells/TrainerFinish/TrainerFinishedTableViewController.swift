//
//  TrainerFinishedTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class TrainerFinishedTableViewController: UITableViewController, refreshableVC {

    var ref:CollectionReference!
    var name:String!
    var thismonth:[[String:Any]] = []
    var othermonth:[[String:Any]] = []
    
    let _refreshControl = UIRefreshControl()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "\(name!)完成的课程"
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        self.tableView.addSubview(self._refreshControl)
        self.tableView.refreshControl = self._refreshControl
        
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
            return self.thismonth.count
        } else {
            return self.othermonth.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "本月"
        } else {
            return "其他月份"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TrainerFinishedTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        if indexPath.section == 0{
            let dic = self.thismonth[indexPath.row]
            if dic["FinishedType"] as! String == "Scaned"{
                cell.AmountStatus.text = "（正常）\n课时数：\(prepareCourseNumber(dic["Amount"]! as! Int))"
            } else {
                cell.AmountStatus.text = "（\(dic["Note"]!)）\n课时数：\(prepareCourseNumber(dic["Amount"]! as! Int))"
            }
            cell.nameTime.text = "\(dic["Name"]!)\n\(dateFormatter.string(from: (dic["Date"] as! Date))) \((dic["Date"] as! Date).getThisWeekDayLongName()) \(timeFormatter.string(from: (dic["Date"] as! Date)))"
        } else {
            let dic = self.othermonth[indexPath.row]
            if dic["FinishedType"] as! String == "Scaned"{
                cell.AmountStatus.text = "（正常）\n课时数：\(prepareCourseNumber(dic["Amount"]! as! Int))"
            } else {
                cell.AmountStatus.text = "（\(dic["Note"]!)）\n课时数：\(prepareCourseNumber(dic["Amount"]! as! Int))"
            }
            cell.nameTime.text = "\(dic["Name"]!)\n\(dateFormatter.string(from: (dic["Date"] as! Date))) \((dic["Date"] as! Date).getThisWeekDayLongName()) \(timeFormatter.string(from: (dic["Date"] as! Date)))"
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func refresh() {
        ref.getDocuments { (snap, err) in
            self.thismonth = []
            self.othermonth = []
            if let err = err {
                AppDelegate.showError(title: "获取完成课时时发生错误", err: err.localizedDescription)
            } else {
                for doc in snap!.documents{
                    if let dateOfDoc = doc.data()["Date"] as? Date{
                        if dateOfDoc > Date().startOfMonth(){
                            var readyToUpdateDic = doc.data()
                            Firestore.firestore().collection("student").document(doc.data()["StudentID"] as! String).getDocument(completion: { (snap, err) in
                                if let err = err {
                                    AppDelegate.showError(title: "获取完成课时时发生错误", err: err.localizedDescription)
                                } else {
                                    if let studentData = snap!.data(){
                                        readyToUpdateDic["Name"] = "\(studentData["First Name"]!) \(studentData["Last Name"]!)"
                                        self.thismonth.append(readyToUpdateDic)
                                    } else {
                                        readyToUpdateDic["Name"] = "未知"
                                        self.thismonth.append(readyToUpdateDic)
                                    }
                                }
                                self.reload()
                            })
                        } else {
                            var readyToUpdateDic = doc.data()
                            Firestore.firestore().collection("student").document(doc.data()["StudentID"] as! String).getDocument(completion: { (snap, err) in
                                if let err = err {
                                    AppDelegate.showError(title: "获取完成课时时发生错误", err: err.localizedDescription)
                                } else {
                                    if let studentData = snap!.data(){
                                        readyToUpdateDic["Name"] = "\(studentData["First Name"]!) \(studentData["Last Name"]!)"
                                        self.thismonth.append(readyToUpdateDic)
                                    } else {
                                        readyToUpdateDic["Name"] = "未知"
                                        self.othermonth.append(readyToUpdateDic)
                                    }
                                }
                                self.reload()
                            })
                        }
                    }
                }
                
                self.reload()
            }
        }
        
    }
    
    func reload() {
        self.tableView.reloadData()
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
