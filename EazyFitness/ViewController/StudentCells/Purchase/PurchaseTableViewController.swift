//
//  PurchaseTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/5.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class PurchaseTableViewController: UITableViewController {

    let _refreshControl = UIRefreshControl()
    var CourseList:[[String:Any]] = []
    
    var dref:CollectionReference!
    
    func refresh() {
        CourseList = []
        dref.order(by: "RequiredDate").getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取购买时发生错误", err: err.localizedDescription)
            } else {
                if let documentList = snap?.documents{
                    for docDic in documentList{
                        self.CourseList.append(docDic.data())
                    }
                }
                self.reload()
            }
        }
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CourseList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "finishedCell", for: indexPath) as! PurchaseTableViewCell
        if let courseDic = CourseList[indexPath.row] as? [String:Any]{
            cell.courseLabel.text = "课时：\(prepareCourseNumber(courseDic["Amount"] as! Int))"
            cell.noteLabel.text = courseDic["Note"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            if let date = courseDic["RequiredDate"] as? Date{
                cell.timeLabel.text = "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"
                if let date = courseDic["ApprovedDate"] as? Date{
                    cell.timeLabel.text = "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"
                }
            }
            if (courseDic["Approved"] as! Bool) == true{
                cell.typeLabel.text = "有效"
                cell.typeLabel.textColor = HexColor.Green
            } else {
                cell.typeLabel.text = "尚未处理"
                cell.typeLabel.textColor = UIColor.gray
                cell.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
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