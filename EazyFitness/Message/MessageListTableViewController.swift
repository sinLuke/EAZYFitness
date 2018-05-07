//
//  MessageListTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class MessageListTableViewController: UITableViewController, refreshableVC {
    
    var myStudentsName:[String:String] = [:]
    var lastMessageForStudent:[String] = ["a","b"]
    var prepareRef:CollectionReference?
    var db:Firestore!
    
    func refresh() {
        if let cMemberID = AppDelegate.AP().currentMemberID{
            for eachStudentID in AppDelegate.AP().myStudentListGeneral{
                self.getStudentsName(studentID: eachStudentID)
            }
            if AppDelegate.AP().usergroup == "student"{
                Firestore.firestore().collection("student").document(cMemberID).collection("Message").document("Last").getDocument { (snap, err) in
                    if let err = err{
                        AppDelegate.showError(title: "获取最新消息时发生错误", err: err.localizedDescription)
                    } else {
                        if let snapData = snap!.data(){
                            self.lastMessageForStudent[0] = snapData["Text"] as! String
                            self.reload()
                        }
                    }
                }
                Firestore.firestore().collection("student").document(cMemberID).collection("AdminMessage").document("Last").getDocument { (snap, err) in
                    if let err = err{
                        AppDelegate.showError(title: "获取最新消息时发生错误", err: err.localizedDescription)
                    } else {
                        if let snapData = snap!.data(){
                            self.lastMessageForStudent[1] = snapData["Text"] as! String
                            self.reload()
                        }
                    }
                }
            }
        }
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refresh()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if AppDelegate.AP().usergroup! == "student"{
            return 2
        } else if AppDelegate.AP().usergroup! == "trainer"{
            return myStudentsName.count
        } else {
            return AppDelegate.AP().myStudentListGeneral.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath)
        if AppDelegate.AP().usergroup! == "student"{
            switch indexPath.row{
            case 0:
                cell.textLabel?.text = "我的教练"
                cell.detailTextLabel?.text = lastMessageForStudent[0]
            default:
                cell.textLabel?.text = "小助手"
                cell.detailTextLabel?.text = lastMessageForStudent[1]
            }
        } else if AppDelegate.AP().usergroup! == "trainer"{
            if AppDelegate.AP().myStudentListGeneral.count != 0{
                cell.textLabel?.text = myStudentsName[AppDelegate.AP().myStudentListGeneral[indexPath.row]]
            } else {
                cell.textLabel?.text = "正在载入……"
            }
            
        }

        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppDelegate.AP().usergroup! == "student"{
            switch indexPath.row{
            case 0:
                self.prepareRef = Firestore.firestore().collection("student").document(AppDelegate.AP().currentMemberID!).collection("Message")
                performSegue(withIdentifier: "message", sender: self)
            default:
                self.prepareRef = Firestore.firestore().collection("student").document(AppDelegate.AP().currentMemberID!).collection("AdminMessage")
                performSegue(withIdentifier: "message", sender: self)
            }
        } else if AppDelegate.AP().usergroup! == "trainer"{
            self.prepareRef = Firestore.firestore().collection("student").document(AppDelegate.AP().myStudentListGeneral[indexPath.row]).collection("Message")
            performSegue(withIdentifier: "message", sender: self)
        } else {
            
        }
    }
    
    func getStudentsName(studentID:String){
        let dbref = db.collection("student").document(studentID)
        
        //获取某个学生的信息
        dbref.getDocument { (snap, err) in
            if let err = err{
                AppDelegate.showError(title: "读取学生信息时发生错误", err: err.localizedDescription)
            } else {
                if let docSnap = snap{
                    if let docData = docSnap.data(){
                        self.myStudentsName[studentID] = "\(docData["First Name"] ?? "N2o") \(docData["Last Name"] ?? "Name")"
                    }
                } else {
                    AppDelegate.showError(title: "读取学生信息时发生错误", err: "无法读取数据")
                }
                self.reload()
            }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? MessageCollectionViewController{
            if let currentMemberID = AppDelegate.AP().currentMemberID{
                dvc.colRef = self.prepareRef
            }
        }
    }
}
