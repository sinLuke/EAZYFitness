//
//  AddMultiUserViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/7.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class AddMultiUserViewController: DefaultViewController, UITableViewDelegate, UITableViewDataSource, refreshableVC {

    
    var Name:String?
    var MemberList:[String] = []
    var MemberNameList:[String:String] = [:]
    var region: String?
    let _refreshControl = UIRefreshControl()
    
    var selectedRegion = "mississauga"
    @IBOutlet weak var regionSelection: UISegmentedControl!
    
    var avaliableStudentList:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        switch regionSelection.selectedSegmentIndex {
        case 0:
            selectedRegion = "mississauga"
        case 1:
            selectedRegion = "waterloo"
        case 2:
            selectedRegion = "scarborough"
        default:
            selectedRegion = "mississauga"
        }
        self.MemberList = []
        self.MemberNameList = [:]
        self.refresh()
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.MemberNameList.removeValue(forKey: MemberList[indexPath.row])
            self.MemberList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            // self.refresh()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemberNameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! selectionTableViewCell
        cell.idLabel.text = MemberList[indexPath.row]
        cell.nameLabel.text = MemberNameList[MemberList[indexPath.row]]
        return cell
    }
    
    func refresh() {
        for studentID in self.MemberList{
            Firestore.firestore().collection("student").document(studentID).getDocument { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取学生列表时发生问题", err: err.localizedDescription, of:self)
                } else {
                    if let dicData = snap!.data(){
                        if let fname = dicData["First Name"], let lname = dicData["Last Name"]{
                            self.MemberNameList[studentID] = "\(fname) \(lname)"
                        }
                    }
                }
                self.reload()
            }
        }
        
    }
    
    func reload() {
        self.tableView.reloadData()
    }

    @IBAction func addMemberBtn(_ sender: Any) {
        
        switch regionSelection.selectedSegmentIndex {
        case 0:
            selectedRegion = "mississauga"
        case 1:
            selectedRegion = "waterloo"
        case 2:
            selectedRegion = "scarborough"
        default:
            selectedRegion = "mississauga"
        }
        
        self.startLoading()
        Firestore.firestore().collection("student").getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取学生列表时发生问题", err: err.localizedDescription, of:self)
            } else {
                self.avaliableStudentList = []
                for doc in snap!.documents{
                    if (doc.data()["region"] as! String) == self.selectedRegion{
                        self.avaliableStudentList.append(doc.documentID)
                    }
                }
                
                let story = UIStoryboard(name: "Main", bundle: nil)
                let vc = story.instantiateViewController(withIdentifier: "selection") as! tableStudentSelectionTableViewController
                vc.listOfStudent = self.avaliableStudentList
                vc.handler = self.handleStudentSelection
                self.endLoading()
                self.present(vc, animated: true)
            }
        }
    }
    
    func handleStudentSelection(StudentID:String?){
        self.MemberList.append(StudentID!)
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppDelegate.AP().usergroup != "super"{
            selectedRegion = AppDelegate.AP().usergroup!
            regionSelection.isEnabled = false
        }
        
        switch selectedRegion {
        case "mississauga":
            regionSelection.selectedSegmentIndex = 0
        case "waterloo":
            regionSelection.selectedSegmentIndex = 1
        case "scarborough":
            regionSelection.selectedSegmentIndex = 2
        default:
            regionSelection.selectedSegmentIndex = 0
        }
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        self.tableView.addSubview(self._refreshControl)
        self.tableView.refreshControl = self._refreshControl
        
        self.refresh()
        
        // Do any additional setup after loading the view.
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
