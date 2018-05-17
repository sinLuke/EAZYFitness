//
//  AllTrainerStudentTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
class AllTrainerStudentTableViewController: DefaultTableViewController {
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
        print(studentlist.count)
        return studentlist.count
    }
    
    override func refresh() {
        ref.getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取学生时发生问题", err: err.localizedDescription)
            } else {
                self.studentlist = []
                for doc in snap!.documents{
                    AppDelegate.refHandler(dic: doc.data()).getDocument(completion: { (snap, err) in
                        if let err = err {
                            AppDelegate.showError(title: "获取学生时发生问题", err: err.localizedDescription)
                        } else {
                            var dicPrepare = doc.data()
                            dicPrepare["Name"] = "\(snap!.data()!["First Name"] ?? "未命名") \(snap!.data()!["Last Name"] ?? "")"
                            dicPrepare["id"] = doc.documentID
                            self.studentlist.append(dicPrepare)
                            self.studentlist.sort(by: { (a, b) -> Bool in
                                if let m = Int(a["id"] as! String), let n = Int(b["id"] as! String){
                                    return m < n
                                } else {
                                    return true
                                }
                            })
                            print(self.studentlist.count)
                            self.reload()
                        }
                    })
                }
            }
        }
    }
    
    override func reload() {
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(studentlist.count)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AllTrainerStudentTableViewCell
        
        if studentlist.count >= indexPath.row + 1 {
            cell.nameLabel.text = "\(self.studentlist[indexPath.row]["Name"] as? String ?? "未命名") - \(self.studentlist[indexPath.row]["id"] as? String ?? "")"
            let thetype = self.studentlist[indexPath.row]["Type"] as? String ?? "未知"
            switch thetype{
            case "General":
                cell.typeLabel.text = "一般"
            default:
                cell.typeLabel.text = "未知"
            }
        }
        return cell
    }
    
    @IBAction func addStudent(_ sender: Any) {
        var listOfStudent:[String] = []
        Firestore.firestore().collection("student").getDocuments { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取学生列表时发生错误", err: err.localizedDescription)
            } else {
                for doc in snap!.documents{
                    if AppDelegate.AP().region == userRegion.All{
                        listOfStudent.append(doc.documentID)
                    } else {
                        let studentRegion = enumService.toRegion(s: doc.data()["region"] as! String)
                        if studentRegion == AppDelegate.AP().region{
                            listOfStudent.append(doc.documentID)
                        }
                    }
                }
                print(listOfStudent)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "selection") as! tableStudentSelectionTableViewController
                vc.listOfStudent = listOfStudent
                vc.handler = self.handleStudentSelection
                self.present(vc, animated: true)
            }
        }
    }
    
    func handleStudentSelection(StudentID:[String]){
        for studentID in StudentID{
            var abletoadd = true
            for items in self.studentlist{
                if (items ["id"] as! String) == studentID{
                    AppDelegate.showError(title: "无法添加", err: "该学生已经被添加", of: self)
                    abletoadd = false
                }
            }
            if abletoadd {
                self.ref.document(studentID).setData(["ref" : Firestore.firestore().collection("student").document(studentID)])
            }
        }
        self.refresh()
    }
 
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.ref.document(studentlist[indexPath.row]["id"] as! String).delete()
            self.studentlist.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            // self.refresh()
        }
    }
    

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
