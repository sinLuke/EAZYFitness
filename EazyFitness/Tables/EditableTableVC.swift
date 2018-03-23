//
//  EditableTableVC.swift
//  EazyFitness
//
//  Created by Luke on 2018-03-22.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase

class EditableTableVC: UITableViewController {
    var _path = ""
    var dic = NSDictionary()
    var listItems = [ListItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...self.dic.count-1{
            self.listItems += [ListItem(text: "\(self.dic.allValues[i])", path: self._path + "/\(self.dic.allKeys[i])")]
        }
        tableView.register(EditableTableCell.self, forCellReuseIdentifier: "tableCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateDatabase()
    }

    func updateDatabase(){
        print("updateDatabase")
        let ref = Database.database().reference()
        ref.child("student").child("\(dic.value(forKey: "MemberID")!)").observeSingleEvent(of: .value) { (snapshot) in
            
            self.dic = (snapshot.value as? NSDictionary)!
            print(self.dic)
            print(self.dic.allValues)
            self.listItems = [ListItem]()
            for i in 0...self.dic.count-1{
                self.listItems += [ListItem(text: "\(self.dic.allValues[i])", path: self._path + "/\(self.dic.allKeys[i])")]
                
            }
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dic.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! EditableTableCell

        // Configure the cell...
        let item = listItems[indexPath.section]
        cell.listItems = item
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.tableView = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(dic.allKeys[section])"
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
