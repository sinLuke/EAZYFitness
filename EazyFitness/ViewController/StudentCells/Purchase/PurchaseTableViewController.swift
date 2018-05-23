//
//  PurchaseTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/5.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class PurchaseTableViewController: UITableViewController {

    let _refreshControl = UIRefreshControl()
    
    @IBOutlet weak var addNew: UIBarButtonItem!
    
    var thisStudent:EFStudent!
    
    func refresh() {
        self.thisStudent.registeredDic.sorted { (itm1, itm2) -> Bool in
            return itm1.value.date > itm2.value.date
        }
        self.reload()
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(self.thisStudent.name)的购买记录"
        
        
        if (AppDelegate.AP().ds!.usergroup == userGroup.student || AppDelegate.AP().ds!.usergroup == userGroup.trainer){
            self.addNew.isEnabled = false
        } else {
            self.addNew.isEnabled = true
        }
        
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.tableView.refreshControl = self._refreshControl
        self.tableView.addSubview(self._refreshControl)
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
        return thisStudent.registeredDic.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "finishedCell", for: indexPath) as! PurchaseTableViewCell
        
        if let efStudentRegistered = self.thisStudent.registeredDic[Array(self.thisStudent.registeredDic.keys)[indexPath.row]]{
            cell.courseLabel.text = "课时：\(efStudentRegistered.amountString)"
            cell.noteLabel.text = efStudentRegistered.note
            cell.timeLabel.text = efStudentRegistered.dateString
            if efStudentRegistered.approved {
                cell.typeLabel.text = "有效"
                cell.typeLabel.textColor = HexColor.Green
                cell.backgroundColor = UIColor.white
            } else {
                cell.typeLabel.text = "尚未处理"
                cell.typeLabel.textColor = UIColor.gray
                cell.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            }
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? AllStudentNewPurchaseViewController{
            dvc.thisStudent = self.thisStudent
        }
    }
}
