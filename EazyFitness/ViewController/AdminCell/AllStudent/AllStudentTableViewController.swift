//
//  AllStudentTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class AllStudentTableViewController: DefaultTableViewController ,refreshableVC {
    
    var db:Firestore!
    var studentList:[String:[String:Any]] = [:]
    var studentEmptyList:[String:[String:Any]] = [:]
    var studentRefList:[String:DocumentReference] = [:]
    let _refreshControl = UIRefreshControl()
    
    func refresh() {
        for i in 1001...2000{
            db.collection("student").document("\(i)").getDocument { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取学生列表时发生问题", err: err.localizedDescription)
                } else {
                    if let doc = snap{
                        if doc.data() == nil{
                            self.studentEmptyList["\(i)"] = ["First Name": "未注册", "Last Name": " ", "region": "未设定地区", "Registered": 0, "MemberID": "\(i)", "usergroup":"student"]
                        } else {
                            self.studentList["\(i)"] = doc.data()
                            self.studentRefList["\(i)"] = doc.reference
                        }
                        
                    } else {
                        self.studentEmptyList["\(i)"] = ["First Name": "未注册", "Last Name": " ", "region": "未设定地区", "Registered": 0, "MemberID": "\(i)", "usergroup":"student"]
                    }
                }
                self.reload()
            }
        }
    }
    
    func reload() {
        self.tableView.reloadData()
        
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
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
        switch section {
        case 0:
            return self.studentList.count
        default:
            return self.studentEmptyList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "已占用"
        } else {
            return "未占用"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! AllStudentTableViewCell
        if indexPath.section == 0{
            if let dic = self.studentList[Array(self.studentList.keys).sorted()[indexPath.row]]{
                cell.nameLabel.text = "\(dic["First Name"] ?? "未注册") \(dic["Last Name"] ?? " ")"
                cell.IDLabel.text = dic["MemberID"] as? String ?? "未知"
                cell.regionLabel.text = dic["region"] as? String ?? "未设定"
                switch dic["Registered"] as! Int{
                case 0:
                    cell.statusLabel.text = "不可用"
                case 1:
                    cell.statusLabel.text = "待注册"
                case 2:
                    cell.statusLabel.text = "已注册"
                default:
                    cell.statusLabel.text = "状态：\(dic["Registered"] ?? "未知")"
                }
            }
            return cell
        } else {
            if let dic = self.studentEmptyList[Array(self.studentEmptyList.keys).sorted()[indexPath.row]]{
                cell.nameLabel.text = "\(dic["First Name"] ?? "未注册") \(dic["Last Name"] ?? " ")"
                cell.IDLabel.text = dic["MemberID"] as? String ?? "未知"
                cell.regionLabel.text = dic["region"] as? String ?? "未设定"
                switch dic["Registered"] as! Int{
                case 0:
                    cell.statusLabel.text = "不可用"
                case 1:
                    cell.statusLabel.text = "待注册"
                case 2:
                    cell.statusLabel.text = "已注册"
                default:
                    cell.statusLabel.text = "状态：\(dic["Registered"] ?? "未知")"
                }
            }
            return cell
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
