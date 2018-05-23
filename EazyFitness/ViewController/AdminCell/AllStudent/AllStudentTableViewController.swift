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
    
    var new = false
    var db:Firestore!
    var studentList:[String:String] = [:]
    var studentEmptyList:[String] = []
    weak var selected:EFStudent!
    let _refreshControl = UIRefreshControl()
    
    var FstudentList:[String:String] = [:]
    var FstudentEmptyList:[String] = []

    var selectedName:String!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func refresh() {
        AppDelegate.AP().ds?.download()
    }
    
    override func reload() {
        FstudentEmptyList = []
        studentEmptyList = []
        
        for i in 1001...2000{
            let stringIndex: String = "\(i)"
            if let thisStudent = DataServer.studentDic[stringIndex]{
                studentList[stringIndex] = stringIndex
                FstudentList[stringIndex] = stringIndex
            } else {
                studentEmptyList.append(stringIndex)
                FstudentEmptyList.append(stringIndex)
            }
        }
        self.tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *), UIScreen.main.bounds.height >= 580 {
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
            if let memberID = self.FstudentList[Array(self.FstudentList.keys.sorted())[indexPath.row]]{
                if let student = DataServer.studentDic[memberID]{
                    cell.nameLabel.text = student.name
                    cell.IDLabel.text = student.memberID
                    cell.regionLabel.text = enumService.toDescription(e: student.region)
                    switch student.registered{
                    case .avaliable:
                        cell.statusLabel.text = "不可用"
                        cell.statusLabel.textColor = HexColor.Red
                    case .unsigned:
                        cell.statusLabel.text = "待注册"
                        cell.statusLabel.textColor = HexColor.Blue
                    case .signed:
                        cell.statusLabel.text = "已注册"
                        cell.statusLabel.textColor = HexColor.Green
                    case .canceled:
                        cell.statusLabel.text = "已注销"
                        cell.statusLabel.textColor = HexColor.gray
                    }
                } else {
                AppDelegate.showError(title: "未知错误", err: "发生未知错误")
                }
            } else {
                AppDelegate.showError(title: "未知错误", err: "发生未知错误")
            }
            return cell
        } else {
            cell.nameLabel.text = "未注册"
            cell.IDLabel.text = self.FstudentEmptyList[indexPath.row]
            cell.regionLabel.text = "未设定"
            cell.statusLabel.text = "不可用"
            cell.statusLabel.textColor = HexColor.gray
            return cell
        }
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
        self.FstudentEmptyList = []
        
        self.FstudentList = self.studentList.filter({(theKey, theValue) -> Bool in
            
            if theKey.lowercased().contains(searchText){
                print(theKey)
                return true
            } else {
                if let _student = DataServer.studentDic[theValue]{
                    let namecontain = _student.name.lowercased().contains(searchText)
                    let regioncontain = enumService.toString(e: _student.region).lowercased().contains(searchText)
                    let memberIDcontain = _student.memberID.lowercased().contains(searchText)
                    let registeredcontain = enumService.toDescription(e: _student.registered).contains(searchText)
                    print("\(namecontain) \(regioncontain) \(memberIDcontain) \(registeredcontain)")
                    return (namecontain || regioncontain || memberIDcontain || registeredcontain)
                } else {
                    return false
                }
            }
        })
        
        self.FstudentEmptyList = self.studentEmptyList.filter({ (memberID) -> Bool in
            return memberID.lowercased().contains(searchText)
        })
        
        if searchText == ""{
            self.FstudentList = self.studentList
            self.FstudentEmptyList = self.studentEmptyList
        }
        self.tableView.reloadData()
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            if let memberID = self.FstudentList[Array(self.FstudentList.keys.sorted())[indexPath.row]]{
                if let student = DataServer.studentDic[memberID]{
                    self.selected = student
                    self.selectedName = student.name
                    self.new = false
                    self.performSegue(withIdentifier: "detail", sender: self)
                } else {
                    AppDelegate.showError(title: "未知错误", err: "发生未知错误")
                }
            } else {
                AppDelegate.showError(title: "未知错误", err: "发生未知错误")
            }
            
        } else {
            let memberID = self.FstudentEmptyList[indexPath.row]
            if let region = AppDelegate.AP().ds?.region{
                
                if region == userRegion.All{
                    self.selected = EFStudent.addStudent(at: memberID, in: userRegion.Mississauga)
                } else {
                    self.selected = EFStudent.addStudent(at: memberID, in: region)
                }
            } else {
                self.selected = EFStudent.addStudent(at: memberID, in: userRegion.Mississauga)
            }
            self.selectedName = "创建新的记录"
            self.new = true
            self.performSegue(withIdentifier: "detail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? AllStudentDetailViewController{
            dvc.navigationItem.title = self.selectedName
            dvc.thisStudent = self.selected
            dvc.new = self.new
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }

}
