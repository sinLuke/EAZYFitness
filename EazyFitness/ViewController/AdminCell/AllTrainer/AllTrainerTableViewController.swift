//
//  AllTrainerTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AllTrainerTableViewController: DefaultTableViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }

    weak var selected:EFTrainer!
    let _refreshControl = UIRefreshControl()
    
    var FilteredKeyList:[String] = []
    var new = false
    
    var selectedName:String = ""

    var newTrainerIDReady: Int?
    var newTrainerRegion:userRegion = .Mississauga
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func refresh() {
        AppDelegate.AP().ds?.download()
    }
    
    override func reload() {
        FilteredKeyList = DataServer.trainerDic.keys.sorted(by: { (a, b) -> Bool in
            if let inta = Int(a), let intb = Int(b){
                return inta < intb
            } else {
                return false
            }
        })
        self.tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UIScreen.main.bounds.height)
        if #available(iOS 11.0, *), UIScreen.main.bounds.height >= 580 {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
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
        searchController.searchBar.placeholder = "搜索教练"
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            
        }
        definesPresentationContext = true
        
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
        return FilteredKeyList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainerCell", for: indexPath) as! AllTrainerTableViewCell
        let memberID = FilteredKeyList[indexPath.row]
        
        if let trainer = DataServer.trainerDic[memberID]{
            
            if let valueNumber = Int(trainer.ref.documentID), valueNumber <= 4 {
                cell.nameLabel.text = "[主教练]\(trainer.name)"
            } else {
                cell.nameLabel.text = trainer.name
            }
            
            cell.idLabel.text = trainer.ref.documentID
            cell.regionLabel.text = enumService.toDescription(e: trainer.region)
            switch trainer.registered{
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
            cell.nameLabel.text = "正在读取..."
        }
        
        return cell
    }
    
    func configureSearchController(){
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func filterSearchController(searchBar: UISearchBar){
        let searchText = searchBar.text?.lowercased() ?? ""
        if !isFiltering() {
            reload()
            return
        }
        FilteredKeyList = DataServer.trainerDic.filter { (key: String, value: EFTrainer) -> Bool in
            if key.lowercased().contains(searchText){
                return true
            } else {
                let namecontain = value.name.lowercased().contains(searchText)
                let regioncontain = enumService.toString(e: value.region).lowercased().contains(searchText)
                let memberIDcontain = value.memberID.lowercased().contains(searchText)
                let registeredcontain = enumService.toDescription(e: value.registered).contains(searchText)
                return (namecontain || regioncontain || memberIDcontain || registeredcontain)
            }
            }.keys.sorted(by: { (a, b) -> Bool in
                if let inta = Int(a), let intb = Int(b){
                    return inta < intb
                } else {
                    return false
                }
            })
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memberID = FilteredKeyList[indexPath.row]
        if let trainer = DataServer.trainerDic[memberID]{
            self.selected = trainer
            self.selectedName = trainer.name
            new = false
            self.performSegue(withIdentifier: "detail", sender: self)
        } else {
            AppDelegate.showError(title: "未知错误", err: "无法读取\(memberID)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? AllTrainerDetailViewController{
            if new {
                dvc.navigationItem.title = "新建教练"
                dvc.new = new
                dvc.newTrainerIDReady = self.newTrainerIDReady
                if let intMemberID = self.newTrainerIDReady{
                    dvc.idLabelString = String(format:"%04d", intMemberID)
                }
                dvc.newTrainerRegion = self.newTrainerRegion
            } else {
                dvc.navigationItem.title = self.selectedName
                dvc.thisTrainer = self.selected
                dvc.new = new
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        //self.refresh()
    }
    
    @IBAction func addTrainerBtn(_ sender: Any) {
        new = true
        
        let alert = UIAlertController(title: "添加教练", message: "请输入卡号或编号", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "0000"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            
            
            if let studentID = textField?.text {
                guard let studentIDINT = Int(studentID) else {
                    AppDelegate.showError(title: "该编号无效", err: "输入值为：\(studentID)")
                    return
                }
                if studentIDINT <= 0 || studentIDINT > 1000{
                    AppDelegate.showError(title: "该编号无效或不可用于教练", err: "输入值为：\(studentID)")
                    return
                }
                ActivityViewController.callStart += 1
                Firestore.firestore().collection("QRCODE").whereField("MemberID", isEqualTo: studentIDINT).getDocuments(completion: { (snap, err) in
                    if (snap?.documents.count ?? 0) > 0 {
                        ActivityViewController.callStart += 1
                        Firestore.firestore().collection("student").document(studentID).getDocument(completion: { (snap, err) in
                            if snap?.data()?["memberID"] as? String == nil {
                                self.newTrainerIDReady = studentIDINT
                                
                                if let ds = AppDelegate.AP().ds{
                                    if ds.region != .All {
                                        self.newTrainerRegion = ds.region
                                    } else {
                                        self.newTrainerRegion = .Mississauga
                                    }
                                    self.performSegue(withIdentifier: "detail", sender: self)
                                } else {
                                    AppDelegate.showError(title: "登录错误", err: "请重新登录", handler: AppDelegate.AP().signout)
                                }
                            } else {
                                AppDelegate.showError(title: "该编号已被占用", err: "输入值为：\(studentID)")
                            }
                            ActivityViewController.callEnd += 1
                        })
                    } else {
                        AppDelegate.showError(title: "该编号无效或不可用于教练", err: "输入值为：\(studentID)")
                    }
                    ActivityViewController.callEnd += 1
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
        /*
        new = true
        
        let alert = UIAlertController(title: "添加教练", message: "请输入卡号或编号", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "0000"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            if let studentID = textField?.text {
                self.newTrainerIDReady = studentID
                
                if let ds = AppDelegate.AP().ds{
                    if ds.region != .All {
                        self.newStudentRegion = ds.region
                        
                    } else {
                        self.newStudentRegion = .Mississauga
                    }
                    self.performSegue(withIdentifier: "detail", sender: self)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
 */
    }
    
    
    
    
    
    
}
