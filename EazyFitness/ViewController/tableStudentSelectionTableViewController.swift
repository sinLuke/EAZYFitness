//
//  tableStudentSelectionTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/7.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
class tableStudentSelectionTableViewController: DefaultTableViewController, UISearchResultsUpdating {
    
    var handler:(([EFStudent]) -> ())!
    var listOfStudent:[EFStudent] = []
    var FlistOfStudent:[EFStudent] = []

    let _refreshControl = UIRefreshControl()
    @IBOutlet weak var doneBtnRef: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        let navc = self.navigationController as! SelectionNavigationViewController
        
        self.handler = navc.handler
        self.listOfStudent = navc.listOfStudent
        
        self.tableView.allowsMultipleSelection = true
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        self.tableView.addSubview(self._refreshControl)
        self.tableView.refreshControl = self._refreshControl
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
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
        return listOfStudent.count
    }
    
    override func refresh() {
        self.reload()
    }
    
    override func reload() {
        self.tableView.reloadData()
        if listOfStudent.count == 0{
            self.dismiss(animated: true)
        }
        if tableView.numberOfSections == 0{
            doneBtnRef.isEnabled = false
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "选择一个学生……"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selection", for: indexPath) as! selectionTableViewCell

        cell.nameLabel.text = listOfStudent[indexPath.row].name
        cell.idLabel.text = listOfStudent[indexPath.row].memberID
        cell.selectionStyle = .default
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        if tableView.numberOfSections == 0{
            doneBtnRef.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        if tableView.numberOfSections == 0{
            doneBtnRef.isEnabled = false
        }
    }

    @IBAction func doneBtn(_ sender: Any) {
        self.dismiss(animated: true)
        if let f = self.handler{
            var returnList:[EFStudent] = []
            if let selelctedList = self.tableView.indexPathsForSelectedRows{
                for indexpath in selelctedList{
                    returnList.append(listOfStudent[indexpath.row])
                }
            }
            f(returnList)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }
    
    func filterSearchController(searchBar: UISearchBar){
        let searchText = searchBar.text?.lowercased() ?? ""
        
        self.FlistOfStudent = self.listOfStudent.filter({(theStudent) -> Bool in
            return (theStudent.name.lowercased().contains(searchText) || theStudent.memberID.lowercased().contains(searchText))
        })
        
        if searchText == ""{
            self.FlistOfStudent = self.listOfStudent
        }
        self.reload()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
