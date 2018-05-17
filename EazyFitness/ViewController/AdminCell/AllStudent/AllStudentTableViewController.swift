//
//  AllStudentTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class AllStudentTableViewController: DefaultTableViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }
    
    
    var db:Firestore!
    var studentList:[String:[String:Any]] = [:]
    var studentEmptyList:[String:[String:Any]] = [:]
    var studentRefList:[String:DocumentReference] = [:]
    let _refreshControl = UIRefreshControl()
    
    var selectedRef:DocumentReference!
    var selectedName:String!
    
    var FstudentList:[String:[String:Any]] = [:]
    var FstudentEmptyList:[String:[String:Any]] = [:]
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func refresh() {
        for i in 1001...2000{
            db.collection("student").document("\(i)").getDocument { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取学生列表时发生问题", err: err.localizedDescription)
                } else {
                    if let doc = snap{
                        if doc.data() == nil{
                            self.studentEmptyList["\(i)"] = ["First Name": "未注册", "Last Name": " ", "region": "未设定地区", "Registered": 0, "MemberID": "\(i)", "usergroup":"student"]
                            self.FstudentEmptyList["\(i)"] = ["First Name": "未注册", "Last Name": " ", "region": "未设定地区", "Registered": 0, "MemberID": "\(i)", "usergroup":"student"]
                            self.studentList["\(i)"] = nil
                            self.FstudentList["\(i)"] = nil
                        } else {
                            self.studentEmptyList["\(i)"] = nil
                            self.FstudentEmptyList["\(i)"] = nil
                            
                            if let _region = doc.data()!["region"] as? String, enumService.toRegion(s: _region) == AppDelegate.AP().region || AppDelegate.AP().region == userRegion.All{
                                self.studentList["\(i)"] = doc.data()
                                self.FstudentList["\(i)"] = doc.data()
                                self.studentRefList["\(i)"] = doc.reference
                            } else {
                                AppDelegate.showError(title: "无法确定用户组", err: "请重新登录", handler:AppDelegate.AP().signout)
                            }
                        }
                        
                    } else {
                        self.studentEmptyList["\(i)"] = ["First Name": "未注册", "Last Name": " ", "region": "未设定地区", "Registered": 0, "MemberID": "\(i)", "usergroup":"student"]
                        self.FstudentEmptyList["\(i)"] = ["First Name": "未注册", "Last Name": " ", "region": "未设定地区", "Registered": 0, "MemberID": "\(i)", "usergroup":"student"]
                    }
                }
                self.reload()
            }
        }
    }
    
    override func reload() {
        self.tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
        }
        db = Firestore.firestore()
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        self.tableView.addSubview(self._refreshControl)
        self.tableView.refreshControl = self._refreshControl
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "搜索学员"
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            
        }
        definesPresentationContext = true
        
        
        
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
            return self.FstudentList.count
        default:
            return self.FstudentEmptyList.count
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
        return 60
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! AllStudentTableViewCell
        if indexPath.section == 0{
            if let dic = self.FstudentList[Array(self.FstudentList.keys).sorted()[indexPath.row]]{
                cell.nameLabel.text = "\(dic["First Name"] ?? "未注册") \(dic["Last Name"] ?? " ")"
                cell.IDLabel.text = dic["MemberID"] as? String ?? "未知"
                cell.regionLabel.text = dic["region"] as? String ?? "未设定"
                switch dic["Registered"] as! Int{
                case 0:
                    cell.statusLabel.text = "不可用"
                    cell.statusLabel.textColor = HexColor.Red
                case 1:
                    cell.statusLabel.text = "待注册"
                    cell.statusLabel.textColor = HexColor.Blue
                case 2:
                    cell.statusLabel.text = "已注册"
                    cell.statusLabel.textColor = HexColor.Green
                default:
                    cell.statusLabel.text = "状态：\(dic["Registered"] ?? "未知")"
                    cell.statusLabel.textColor = HexColor.Red
                }
            }
            return cell
        } else {
            if let dic = self.FstudentEmptyList[Array(self.FstudentEmptyList.keys).sorted()[indexPath.row]]{
                cell.nameLabel.text = "\(dic["First Name"] ?? "未注册") \(dic["Last Name"] ?? " ")"
                cell.IDLabel.text = dic["MemberID"] as? String ?? "未知"
                cell.regionLabel.text = dic["region"] as? String ?? "未设定"
                cell.statusLabel.text = "不可用"
                cell.statusLabel.textColor = HexColor.Red
            }
            return cell
        }
    }
    
    @IBAction func addMulti(_ sender: Any) {
        self.performSegue(withIdentifier: "show", sender: self)
    }
    
    
    func configureSearchController(){
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func filterSearchController(searchBar: UISearchBar){
        let searchText = searchBar.text?.lowercased() ?? ""
        print(searchText)
        self.FstudentList = [:]
        self.FstudentEmptyList = [:]
        
        self.FstudentList = self.studentList.filter({(theKey, theValue) -> Bool in
            if theKey.lowercased().contains(searchText){
                return true
            } else {
                var returnValue = false
                for items in theValue.values{
                    returnValue = returnValue || "\(items)".lowercased().contains(searchText)
                }
                return returnValue
            }
        })
        
        self.FstudentEmptyList = self.studentEmptyList.filter({(theKey, theValue) -> Bool in
            if theKey.lowercased().contains(searchText){
                return true
            } else {
                var returnValue = false
                for items in theValue.values{
                    returnValue = returnValue || "\(items)".lowercased().contains(searchText)
                }
                return returnValue
            }
        })
        if searchText == ""{
            self.FstudentList = self.studentList
            self.FstudentEmptyList = self.studentEmptyList
        }

        self.reload()
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            self.selectedRef = self.studentRefList[Array(self.FstudentList.keys).sorted()[indexPath.row]]!
            if let dic = self.studentList[Array(studentList.keys).sorted()[indexPath.row]]{
                self.selectedName = "\(dic["First Name"] ?? "未注册") \(dic["Last Name"] ?? " ")"
            }
        }else{
            self.selectedRef = db.collection("student").document(Array(self.FstudentEmptyList.keys).sorted()[indexPath.row])
            self.selectedName = "创建新的记录"
        }
        self.performSegue(withIdentifier: "detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? AllStudentDetailViewController{
            dvc.navigationItem.title = self.selectedName
            dvc.ref = self.selectedRef
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }

}
