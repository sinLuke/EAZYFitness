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
    var thisTrainer:EFTrainer!
    let _refreshControl = UIRefreshControl()
    var studentList:[EFStudent] = []
    
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
        return (self.studentList).count
    }
    
    override func refresh() {
        print(thisTrainer.trainee)
        self.studentList = []
        for studentRef in thisTrainer.trainee{
            if let thisStudent = DataServer.studentDic[studentRef.documentID]{
                self.studentList.append(thisStudent)
            }
        }
    }
    
    override func reload() {
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AllTrainerStudentTableViewCell
        if studentList.count >= indexPath.row + 1 {
            cell.nameLabel.text = studentList[indexPath.row].name
            cell.typeLabel.text = studentList[indexPath.row].memberID
        }
        return cell
    }
    
    @IBAction func addStudent(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "selection") as! SelectionNavigationViewController
        vc.listOfStudent = Array(DataServer.studentDic.filter({ (key, value) -> Bool in
            return value.region == thisTrainer.region
        }).values)
        vc.handler = self.handleStudentSelection
        self.present(vc, animated: true)
    }
    
    func handleStudentSelection(_Student:[EFStudent]){
        for _student in _Student{
            var abletoadd = true
            for items in self.thisTrainer.trainee{
                if items.documentID == _student.ref.documentID{
                    AppDelegate.showError(title: "无法添加", err: "该学生已经被添加", of: self)
                    abletoadd = false
                }
            }
            if abletoadd {
                thisTrainer.trainee.append(_student.ref)
                thisTrainer.upload()
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
            for i in 0...thisTrainer.trainee.count{
                if thisTrainer.trainee[i] == self.studentList[indexPath.row].ref{
                    thisTrainer.trainee.remove(at: i)
                }
            }
            self.studentList.remove(at: indexPath.row)
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
