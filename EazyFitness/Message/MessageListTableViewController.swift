//
//  MessageListTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

struct MessageListItem {
    var name: String
    var usergroup: userGroup
    var lastMessage: String
    var read: Bool
    var time: Date?
}

class MessageListTableViewController: DefaultTableViewController {
    
    var thisUser:EFData!
    var thisUsergroup:userGroup!
    var thisRegion:userRegion!
    var isAdmin:Bool!
    
    var messageList: [userGroup:[MessageListItem]] = [:]
    let _refreshControl = UIRefreshControl()
    
    var prepareRef:CollectionReference?
    var receiverUID:String!
    var db:Firestore!
    
    var usergroup: userGroup = .student
    
    var prepareTitle:String? = ""
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    func getLastMessageFromCollection(ref: DocumentReference, collection: CollectionReference, usergoup: userGroup) {
        ref.getDocument { (snap2, err2) in
            if let err = err2 {
                AppDelegate.showError(title: "读取\(enumService.toDescription(e: usergoup))(\(ref.documentID))信息时发生错误", err: err.localizedDescription)
            } else {
                var name = "(\(ref.documentID), \(enumService.toDescription(e: usergoup))"
                if let firstName = snap2!.data()?["firstName"] as? String,
                    let lastName = snap2!.data()?["lastName"] as? String{
                    name = "\(firstName) \(lastName)"
                }
                if let cusergroup = AppDelegate.AP().ds?.usergroup, let cregion = AppDelegate.AP().ds?.region{
                    if usergoup == .trainer && cusergroup == .student {
                        name = "我的教练"
                    }
                    if usergoup == .admin {
                        name = "\(enumService.toDescription(e: cregion))小助手"
                    }
                }
                
                collection.document("Last").getDocument { (snap, err) in
                    if let err = err {
                        AppDelegate.showError(title: "读取\(enumService.toDescription(e: usergoup))\(name)最近消息时发生错误", err: err.localizedDescription)
                    } else {
                        
                        if let lastMessage = snap!.data()?["Text"] as? String,
                            let ref = snap!.data()?["ref"] as? DocumentReference,
                            let time = snap!.data()?["Time"] as? Date {
                            ref.getDocument(completion: { (snap, _) in
                                if let snap = snap {
                                    let read = snap.data()?["Read"] as? Bool ?? true
                                    let thisMessgae = MessageListItem(name: name, usergroup: usergoup, lastMessage: lastMessage, read: read, time: time)
                                    if self.messageList[usergoup] == nil {
                                        self.messageList[usergoup] = [thisMessgae]
                                    } else {
                                        self.messageList[usergoup]?.append(thisMessgae)
                                    }
                                    self.reload()
                                }
                            })
                        } else {
                            let thisMessgae = MessageListItem(name: name, usergroup: usergoup, lastMessage: "[无聊天记录]", read: true, time: nil)
                            if self.messageList[usergoup] == nil {
                                self.messageList[usergoup] = [thisMessgae]
                            } else {
                                self.messageList[usergoup]!.append(thisMessgae)
                            }
                            self.reload()
                        }
                    }
                }
            }
        }
    }
    
    override func refresh() {
        
        print(AppDelegate.AP().ds?.usergroup)

        self.messageList = [:]
        
        if let currentUserGroup = AppDelegate.AP().ds?.usergroup {
            self.usergroup = currentUserGroup
            switch currentUserGroup {
            case .trainer:
                
                if let currentID = AppDelegate.AP().ds?.memberID {
                    let trainerRef = Firestore.firestore().collection("trainer").document(currentID)
                    trainerRef.getDocument { (snap, err) in
                        if let err = err {
                            AppDelegate.showError(title: "读取学生列表时错误，请稍后重试", err: err.localizedDescription)
                        } else {
                            if let studentRefList = snap!.data()!["trainee"] as? [DocumentReference] {
                                for studentRef in studentRefList {
                                    self.getLastMessageFromCollection(ref: studentRef, collection: studentRef.collection("Message"), usergoup: .student)
                                }
                            }
                        }
                    }
                    self.getLastMessageFromCollection(ref: trainerRef, collection: trainerRef.collection("AdminMessage"), usergoup: .admin)
                }
                
            case .admin:
                if let currentRegion = AppDelegate.AP().ds?.region {
                    Firestore.firestore().collection("trainer").getDocuments { (snaps, err) in
                        if let err = err {
                            AppDelegate.showError(title: "读取教练列表时错误，请稍后重试", err: err.localizedDescription)
                        } else {
                            let documents = snaps!.documents
                            for trainerDoc in documents{
                                if currentRegion != userRegion.All{
                                    if let region = trainerDoc.data()["region"] as? String {
                                        let regionValue = enumService.toRegion(s: region)
                                        if currentRegion == regionValue {
                                            self.getLastMessageFromCollection(ref: trainerDoc.reference, collection: trainerDoc.reference.collection("AdminMessage"), usergoup: .trainer)
                                        }
                                    }
                                } else {
                                    self.getLastMessageFromCollection(ref: trainerDoc.reference, collection: trainerDoc.reference.collection("AdminMessage"), usergoup: .trainer)
                                }
                            }
                        }
                    }
                    
                    Firestore.firestore().collection("student").getDocuments { (snaps, err) in
                        if let err = err {
                            AppDelegate.showError(title: "读取学生列表时错误，请稍后重试", err: err.localizedDescription)
                        } else {
                            let documents = snaps!.documents
                            for studentDoc in documents{
                                if currentRegion != userRegion.All{
                                    if let region = studentDoc.data()["region"] as? String {
                                        let regionValue = enumService.toRegion(s: region)
                                        if currentRegion == regionValue {
                                            self.getLastMessageFromCollection(ref: studentDoc.reference, collection: studentDoc.reference.collection("AdminMessage"), usergoup: .student)
                                        }
                                    }
                                } else {
                                    self.getLastMessageFromCollection(ref: studentDoc.reference, collection: studentDoc.reference.collection("AdminMessage"), usergoup: .student)
                                }
                            }
                        }
                    }
                }
            case .student:
                print(AppDelegate.AP().ds?.memberID)
                if let currentID = AppDelegate.AP().ds?.memberID {
                    let studentRef = Firestore.firestore().collection("student").document(currentID)
                    self.getLastMessageFromCollection(ref: studentRef, collection: studentRef.collection("AdminMessage"), usergoup: .admin)
                    self.getLastMessageFromCollection(ref: studentRef, collection: studentRef.collection("Message"), usergoup: .trainer)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentUserGroup = AppDelegate.AP().ds?.usergroup {
            if currentUserGroup == .student {
                return nil
            } else {
                let currentKey = Array(self.messageList.keys)[section]
                return enumService.toDescription(e: currentKey)
            }
        } else {
            return nil
        }
    }
    
    override func reload() {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        self.tableView!.refreshControl = self._refreshControl
        self.tableView!.addSubview(self._refreshControl)
        
        //self.refresh()
        
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
        
        return self.messageList.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let currentKey = Array(self.messageList.keys)[section]
        return self.messageList[currentKey]?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as! MessageListTableViewCell
        cell.Read = true
        let currentKey = Array(self.messageList.keys)[indexPath.section]
        cell.messageData = self.messageList[currentKey]?.sorted(by: { (a, b) -> Bool in
            if let atime = a.time, let btime = b.time {
                return atime > btime
            } else {
                return a.name > b.name
            }
        })[indexPath.row]
        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
                dvc.receiver = self.receiverUID
                dvc.colRef = self.prepareRef
                dvc.thisTrainerStudent = self.thisUser
                dvc.nameTitle = self.prepareTitle
                dvc.title = self.prepareTitle
            }
        }
    }
}
