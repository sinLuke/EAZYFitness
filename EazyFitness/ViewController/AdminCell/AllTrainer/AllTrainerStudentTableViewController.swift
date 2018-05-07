//
//  AllTrainerStudentTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
class AllTrainerStudentTableViewController: DefaultTableViewController, refreshableVC {
    var ref:CollectionReference!
    var studentlist:[[String:Any]] = []
    let _refreshControl = UIRefreshControl()
    
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentlist.count
    }
    
    func refresh() {
        ref.getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取学生时发生问题", err: err.localizedDescription)
            } else {
                self.studentlist = []
                for doc in snap!.documents{
                    Firestore.firestore().collection("student").document(doc.documentID).getDocument(completion: { (snap, err) in
                        if let err = err {
                            AppDelegate.showError(title: "获取学生时发生问题", err: err.localizedDescription)
                        } else {
                            var dicPrepare = doc.data()
                            dicPrepare["Name"] = "\(snap!.data()!["First Name"] ?? "未命名") \(snap!.data()!["Last Name"] ?? "")"
                            dicPrepare["id"] = doc.documentID
                            self.studentlist.append(dicPrepare)
                            self.reload()
                        }
                    })
                    
                }
            }
        }
    }
    
    func reload() {
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AllTrainerStudentTableViewCell
        
        cell.nameLabel.text = "\(self.studentlist[indexPath.row]["Name"] as? String ?? "未命名") - \(self.studentlist[indexPath.row]["id"] as? String ?? "")"
        let thetype = self.studentlist[indexPath.row]["Type"] as? String ?? "未知"
        switch thetype{
        case "General":
            cell.typeLabel.text = "一般"
        default:
            cell.typeLabel.text = "未知"
        }
        
        return cell
    }
    
    @IBAction func addStudent(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "selection") as! tableStudentSelectionTableViewController
        self.present(vc, animated: true) {
            <#code#>
        }
    }
    
    func handleStudentSelection(StudentID:String?){
        if let studentID = StudentID{
            for items in self.studentlist{
                if (items ["Name"] as! String) == studentID{
                    AppDelegate.showError(title: "无法添加", err: "该学生已经被添加")
                    return
                }
            }
            self.ref.document(studentID).setData(["Type" : "General"])
            self.refresh()
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
