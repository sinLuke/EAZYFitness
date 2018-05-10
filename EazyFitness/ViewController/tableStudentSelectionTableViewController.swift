//
//  tableStudentSelectionTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/7.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
class tableStudentSelectionTableViewController: DefaultTableViewController, refreshableVC {
    
    
    var handler:((String?) -> ())!
    var listOfStudent:[String] = []
    var listOnlyContainNames = false
    var NameOfStudent:[String:String] = [:]
    let _refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
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
        return listOfStudent.count
    }
    
    func refresh() {
        if listOfStudent.count == 0{
            self.dismiss(animated: true)
        } else {
            if listOnlyContainNames == false {
                for ids in listOfStudent{
                    Firestore.firestore().collection("student").document(ids).getDocument { (snap, err) in
                        if let err = err {
                            AppDelegate.showError(title: "未知错误", err: "获取学生列表时发生错误")
                        } else {
                            if let snapData = snap!.data(){
                                if let fname = snapData["First Name"], let lname = snapData["Last Name"]{
                                    self.NameOfStudent[ids] = "\(fname) \(lname)"
                                    print(self.NameOfStudent)
                                    self.reload()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func reload() {
        self.tableView.reloadData()
        if listOfStudent.count == 0{
            self.dismiss(animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "选择一个学生……"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selection", for: indexPath) as! selectionTableViewCell

        if listOnlyContainNames{
            cell.nameLabel.text = listOfStudent[indexPath.row]
            cell.idLabel.text = ""
        } else {
            cell.nameLabel.text = NameOfStudent[listOfStudent[indexPath.row]] ?? "未知"
            cell.idLabel.text = listOfStudent[indexPath.row]
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
        if let f = self.handler{
            f(listOfStudent[indexPath.row])
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
