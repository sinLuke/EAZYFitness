//
//  MessageListTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class MessageListTableViewController: UITableViewController {
    
    var thisUser:EFData!
    var thisUsergroup:userGroup!
    var thisRegion:userRegion!
    var isAdmin:Bool!
    
    var lastMessageForStudent:[[String:Any]?] = [nil,nil]
    var lastMessageForTrainer:[String:[String:Any]] = [:]
    
    var prepareRef:CollectionReference?
    var receiverUID:String!
    var db:Firestore!
    
    func refresh() {
        
        if let thisStudnet = thisUser as? EFStudent{
            Firestore.firestore().collection("student").document(thisStudnet.memberID).collection("Message").document("Last").getDocument { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "获取最新消息时发生错误", err: err.localizedDescription)
                } else {
                    if let snapData = snap!.data(){
                        let lastMessageRef = snapData["ref"] as! DocumentReference
                        lastMessageRef.getDocument(completion: { (snap, err) in
                            if let err = err {
                                AppDelegate.showError(title: "获取信息时出现错误", err: err.localizedDescription)
                            } else {
                                if let data = snap!.data(){
                                    self.lastMessageForStudent[0] = data
                                    self.reload()
                                } else {
                                    AppDelegate.showError(title: "获取信息时出现错误", err: "消息对象为空")
                                }
                            }
                        })
                    }
                }
            }
            Firestore.firestore().collection("student").document(thisStudnet.memberID).collection("AdminMessage").document("Last").getDocument { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "获取最新消息时发生错误", err: err.localizedDescription)
                } else {
                    if let snapData = snap!.data(){
                        let lastMessageRef = snapData["ref"] as! DocumentReference
                        lastMessageRef.getDocument(completion: { (snap, err) in
                            if let err = err {
                                AppDelegate.showError(title: "获取信息时出现错误", err: err.localizedDescription)
                            } else {
                                if let data = snap!.data(){
                                    self.lastMessageForStudent[1] = data
                                    self.reload()
                                } else {
                                    AppDelegate.showError(title: "获取信息时出现错误", err: "消息对象为空")
                                }
                            }
                        })
                    }
                }
            }
            thisStudnet.getTrainer()
        } else if let thisTranier = thisUser as? EFTrainer{
            for studentRef in thisTranier.trainee{
                studentRef.collection("Message").document("Last").getDocument { (snap, err) in
                    if let err = err{
                        AppDelegate.showError(title: "获取最新消息时发生错误", err: err.localizedDescription)
                    } else {
                        if let snapData = snap!.data(){
                            let lastMessageRef = snapData["ref"] as! DocumentReference
                            lastMessageRef.getDocument(completion: { (snap, err) in
                                if let err = err {
                                    AppDelegate.showError(title: "获取信息时出现错误", err: err.localizedDescription)
                                } else {
                                    if let data = snap!.data(){
                                        self.lastMessageForTrainer[studentRef.documentID] = data
                                        self.reload()
                                    } else {
                                        AppDelegate.showError(title: "获取信息时出现错误", err: "消息对象为空")
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
        reload()
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
        if let tbc = self.tabBarController as? StudentTabBarController{
            thisUser = tbc.thisStudent
            thisUsergroup = .student
            thisRegion = tbc.thisStudent.region
            isAdmin = true
        } else if let tbc = self.tabBarController as? TrainerTabBarController{
            thisUser = tbc.thisTrainer
            thisUsergroup = .trainer
            thisRegion = tbc.thisTrainer.region
            isAdmin = true
        } else if let tbc = self.tabBarController as? AdminTabBarController{
            thisRegion = AppDelegate.AP().ds?.region
            isAdmin = true
        }
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
        if AppDelegate.AP().ds?.usergroup == userGroup.student{
            return 2
        } else if let thisTrainer = thisUser as? EFTrainer{
            return thisTrainer.trainee.count
        } else {
            return AppDelegate.AP().studentList.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as! MessageListTableViewCell
        cell.Read = true
        if let thisStudent = thisUser as? EFStudent{
            switch indexPath.row{
            case 0:
                if thisStudent.trainer == nil{
                    cell.messageTitle.text = "暂无教练"
                    cell.messageText.text = ""
                    cell.timeLabel.text = ""
                    cell.Read = true
                } else if let lastMessage = lastMessageForStudent[0]{
                    cell.messageTitle.text = "我的教练"
                    cell.messageText.text = lastMessage["Text"] as? String
                    cell.timeLabel.text = (lastMessage["Time"] as? Date)?.descriptDate()
                    if !(lastMessage["byStudent"] as! Bool){
                        cell.Read = lastMessage["Read"] as! Bool
                    } else {
                        cell.Read = true
                    }
                }
            default:
                if let lastMessage = lastMessageForStudent[1]{
                    cell.messageTitle.text = "小助手"
                    cell.messageText.text = lastMessage["Text"] as? String
                    cell.timeLabel.text = (lastMessage["Time"] as? Date)?.descriptDate()
                    if !(lastMessage["byStudent"] as! Bool){
                        cell.Read = lastMessage["Read"] as! Bool
                    } else {
                        cell.Read = true
                    }
                } else {
                    cell.messageTitle.text = "小助手"
                    cell.messageText.text = ""
                    cell.Read = true
                    cell.timeLabel.text = ""
                }
            }
        } else if let thisTrainer = thisUser as? EFTrainer{
            if thisTrainer.trainee.count != 0{
                let studentRef = thisTrainer.trainee[indexPath.row]
                if let student = DataServer.studentDic[studentRef.documentID]{
                    cell.messageTitle.text = student.name
                    if let lastMessage = lastMessageForTrainer[student.memberID]{
                        cell.messageText.text = lastMessage["Text"] as? String
                        cell.timeLabel.text = (lastMessage["Time"] as? Date)?.descriptDate()
                        if (lastMessage["byStudent"] as! Bool){
                            cell.Read = lastMessage["Read"] as! Bool
                        } else {
                            cell.Read = true
                        }
                    }
                    
                }
            } else {
                cell.messageTitle.text = "正在载入……"
                cell.messageText.text = ""
            }
        }
        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let theStudent = thisUser as? EFStudent{
            switch indexPath.row{
            case 0:
                if let theTrainerExist = theStudent.trainer{
                    self.prepareRef = Firestore.firestore().collection("student").document(AppDelegate.AP().ds!.memberID).collection("Message")
                    self.receiverUID = theStudent.trainerUID ?? "null"
                    performSegue(withIdentifier: "message", sender: self)
                } else {
                    AppDelegate.showError(title: "请稍后", err: "数据尚未完全载入")
                }
            default:
                Firestore.firestore().collection("users").whereField("region", isEqualTo: enumService.toString(e: theStudent.region)).whereField("usergroup", isEqualTo: "admin").getDocuments { (snaps, err) in
                    if let err = err {
                        AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
                    } else {
                        if snaps!.count == 0 {
                            AppDelegate.showError(title: "未知错误", err: "未找到管理员")
                        } else {
                            for doc in snaps!.documents{
                                self.prepareRef = Firestore.firestore().collection("student").document(AppDelegate.AP().ds!.memberID).collection("AdminMessage")
                                self.receiverUID = doc.documentID
                                self.performSegue(withIdentifier: "message", sender: self)
                                break
                            }
                        }
                    }
                }
                
            }
        } else if let thisTrainer = thisUser as? EFTrainer{
            if thisTrainer.trainee.count != 0{
                let studentRef = thisTrainer.trainee[indexPath.row]
                if let student = DataServer.studentDic[studentRef.documentID]{
                    self.prepareRef = Firestore.firestore().collection("student").document(student.memberID).collection("Message")
                    self.receiverUID = student.uid
                    performSegue(withIdentifier: "message", sender: self)
                }
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
            if let currentMemberID = AppDelegate.AP().ds?.memberID{
                dvc.colRef = self.prepareRef
                dvc.thisTrainerStudent = self.thisUser
            }
        }
    }
}
