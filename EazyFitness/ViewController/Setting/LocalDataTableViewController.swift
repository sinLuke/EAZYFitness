//
//  LocalDataTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/21.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class LocalDataTableViewController: DefaultTableViewController {
    
    var selected:EFData?

    override func viewDidLoad() {
        super.viewDidLoad()

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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return DataServer.studentDic.count
        case 1:
            return DataServer.trainerDic.count
        case 2:
            return DataServer.courseDic.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.section {
        case 0:
            let student = DataServer.studentDic[(Array(DataServer.studentDic.keys))[indexPath.row]]
            cell.textLabel?.text = student?.name
            cell.detailTextLabel?.text = (Array(DataServer.studentDic.keys))[indexPath.row]
        case 1:
            let trainer = DataServer.trainerDic[(Array(DataServer.trainerDic.keys))[indexPath.row]]
            cell.textLabel?.text = trainer?.name
            cell.detailTextLabel?.text = (Array(DataServer.studentDic.keys))[indexPath.row]
        case 2:
            let course = DataServer.courseDic[(Array(DataServer.courseDic.keys))[indexPath.row]]
            cell.textLabel?.text = course?.note
            cell.detailTextLabel?.text = (Array(DataServer.studentDic.keys))[indexPath.row]
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.performSegue(withIdentifier: "move", sender: self)
            selected = DataServer.studentDic[(Array(DataServer.studentDic.keys))[indexPath.row]]
        case 1:
            self.performSegue(withIdentifier: "move", sender: self)
            selected = DataServer.trainerDic[(Array(DataServer.trainerDic.keys))[indexPath.row]]
        case 2:
            self.performSegue(withIdentifier: "move", sender: self)
            selected = DataServer.courseDic[(Array(DataServer.courseDic.keys))[indexPath.row]]
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "学生"
        case 1:
            return "教练"
        case 2:
            return "课程"
        default:
            return "学生"
        }
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
        if let dvc = segue.destination as? LocalNextDataTableViewController{
            dvc.selected = self.selected
        }
    }
 

}
