//
//  AllTrainerTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class AllTrainerTableViewController: DefaultTableViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }
    
    var new = false
    var trainerList:[Int:String] = [:]
    var trainerEmptyList:[Int] = []

    weak var selected:EFTrainer!
    var selectedName:String = ""
    var FtrainerList:[Int:String] = [:]
    var FtrainerEmptyList:[Int] = []
    let _refreshControl = UIRefreshControl()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func refresh() {
        AppDelegate.AP().ds?.download()
    }
    
    override func reload() {
        self.tableView.reloadData()
        FtrainerEmptyList = []
        trainerEmptyList = []
        print("reload")
        for i in 1...999{
            if let thisTrainer = DataServer.trainerDic["\(i)"]{
                trainerList[i] = "\(i)"
                FtrainerList[i] = "\(i)"
            } else {
                trainerEmptyList.append(i)
                FtrainerEmptyList.append(i)
            }
        }
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
            return self.FtrainerList.count
        default:
            return self.FtrainerEmptyList.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainerCell", for: indexPath) as! AllTrainerTableViewCell
        if indexPath.section == 0{
            if let memberID = self.FtrainerList[Array(self.FtrainerList.keys.sorted())[indexPath.row]]{
                if let trainer = DataServer.trainerDic[memberID]{
                    
                    if self.FtrainerList.keys.sorted()[indexPath.row] <= 4 {
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
                }
            } else {
            }
            
            return cell
        } else {
            cell.nameLabel.text = "未注册"
            cell.idLabel.text = "\(self.FtrainerEmptyList[indexPath.row])"
            cell.regionLabel.text = "未设定"
            cell.statusLabel.text = "不可用"
            cell.statusLabel.textColor = HexColor.gray
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            if let memberID = self.FtrainerList[Array(self.FtrainerList.keys.sorted())[indexPath.row]]{
                if let trainer = DataServer.trainerDic[memberID]{
                    self.selected = trainer
                    self.selectedName = trainer.name
                    self.new = false
                    self.performSegue(withIdentifier: "detail", sender: self)
                } else {
                }
            } else {
        }
            
        } else {
            let memberID = "\(self.FtrainerEmptyList[indexPath.row])"
            if let region = AppDelegate.AP().ds?.region{
                
                if region == userRegion.All{
                    self.selected = EFTrainer.addTrainer(at: memberID, in: userRegion.Mississauga)
                } else {
                    self.selected = EFTrainer.addTrainer(at: memberID, in: region)
                }
            } else {
                self.selected = EFTrainer.addTrainer(at: memberID, in: userRegion.Mississauga)
            }
            self.selectedName = "创建新的记录"
            self.new = true
            self.performSegue(withIdentifier: "detail", sender: self)
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
        self.FtrainerList = [:]
        self.FtrainerEmptyList = []
        
        self.FtrainerList = self.trainerList.filter({(theKey, theValue) -> Bool in
            if "\(theKey)".lowercased().contains(searchText){
                return true
            } else {
                if let _trainer = DataServer.trainerDic[theValue]{
                    return (_trainer.name.lowercased().contains(searchText) ||
                    enumService.toString(e: _trainer.region).lowercased().contains(searchText) ||
                    _trainer.memberID.lowercased().contains(searchText) ||
                    enumService.toDescription(e: _trainer.registered).contains(searchText))
                } else {
                    return false
                }
            }
        })
        
        self.FtrainerEmptyList = self.trainerEmptyList.filter({ (memberID) -> Bool in
            return "\(memberID)".lowercased().contains(searchText)
        })
        
        if searchText == ""{
            self.FtrainerList = self.trainerList
            self.FtrainerEmptyList = self.trainerEmptyList
        }
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? AllTrainerDetailViewController{
            dvc.thisTrainer = self.selected
            dvc.titleName = self.selectedName
            dvc.new = self.new
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    
}
