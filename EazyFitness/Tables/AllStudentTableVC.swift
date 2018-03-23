//
//  AllStudentTableVC.swift
//  EazyFitness
//
//  Created by Luke on 2018-03-22.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase

class AllStudentTableVC: UITableViewController {
    var dic = NSDictionary()
    var sortedKeys = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = self.navigationController as! TrainerNav
        dic = vc.allStudentDic
        self.title = "所以学生"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let ref = Database.database().reference()
        ref.child("student").observeSingleEvent(of: .value) { (snapshot) in
            self.dic = (snapshot.value as? NSDictionary)!
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dic.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        self.sortedKeys = (dic.allKeys as! [String]).sorted { $0 < $1 }
        cell.textLabel?.text = "\(sortedKeys[indexPath.row])"
        if (dic.value(forKey: sortedKeys[indexPath.row]) as? NSDictionary)?.value(forKey: "Registered") as! Int == 1{
            let fname = (dic.value(forKey: sortedKeys[indexPath.row]) as? NSDictionary)?.value(forKey: "First Name") ?? dic.allKeys[indexPath.row]
            let lname = (dic.value(forKey: sortedKeys[indexPath.row]) as? NSDictionary)?.value(forKey: "Last Name") ?? ""
            cell.detailTextLabel?.text = "\(fname) \(lname)"
        } else {
            cell.detailTextLabel?.text = "未注册"
            cell.detailTextLabel?.textColor = UIColor.red
        }
        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue)
        if segue.identifier == "show", let destination = segue.destination as? EditableTableVC, let Index = tableView.indexPathForSelectedRow?.row{
            destination.dic = (dic.value(forKey: sortedKeys[Index]) as? NSDictionary ?? NSDictionary())!
            destination._path = "/student/\(sortedKeys[Index])"
        }
    }
}
