//
//  LocalNextDataTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/21.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class LocalNextDataTableViewController: DefaultTableViewController {
    
    var selected:EFData!
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
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
        if let theStudent = selected as? EFStudent{
            return 4
        } else if let theTrainer = selected as? EFTrainer{
            return 2
        } else if let theCourse = selected as? EFCourse{
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let theStudent = selected as? EFStudent{
            switch section{
            case 0:
                return theStudent.courseDic.count
            case 1:
                return theStudent.registeredDic.count
            case 2:
                return theStudent.messageDic.count
            case 3:
                return theStudent.personalDic.count
            default:
                return 0
            }
        }  else if let theTrainer = selected as? EFTrainer{
            switch section{
            case 0:
                return theTrainer.finish.count
            case 1:
                return theTrainer.trainee.count
            default:
                return 0
            }
        } else if let theCourse = selected as? EFCourse{
            return theCourse.traineeRef.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let theStudent = selected as? EFStudent{
            switch indexPath.section{
            case 0:
                let studentCourse = theStudent.courseDic[(Array(theStudent.courseDic.keys))[indexPath.row]]
                cell.textLabel?.text = enumService.toString(e: (studentCourse?.status)!)
                cell.detailTextLabel?.text = studentCourse?.note
            case 1:
                let studentRegistered = theStudent.registeredDic[(Array(theStudent.registeredDic.keys))[indexPath.row]]
                cell.textLabel?.text = "\(studentRegistered?.amount)"
                cell.detailTextLabel?.text = studentRegistered?.date.description
            case 2:
                let studentMessageDic = theStudent.messageDic[(Array(theStudent.messageDic.keys))[indexPath.row]]
                cell.textLabel?.text = studentMessageDic?.text
                cell.detailTextLabel?.text = enumService.toString(e: (studentMessageDic?.type)!)
            case 3:
                let studentPersonal = theStudent.personalDic[(Array(theStudent.personalDic.keys))[indexPath.row]]
                cell.textLabel?.text = studentPersonal?.recordKey
                cell.detailTextLabel?.text = "\(studentPersonal?.recordValue)"
            default:
                print("here")
            }
        }  else if let theTrainer = selected as? EFTrainer{
            switch indexPath.section{
            case 0:
                let theTrainerFinish = theTrainer.finish[indexPath.row]
                cell.textLabel?.text = enumService.toDescription(d: (DataServer.courseDic[theTrainerFinish.documentID]?.getTraineesStatus)!)
                cell.detailTextLabel?.text = DataServer.courseDic[theTrainerFinish.documentID]?.date.description
            case 1:
                let theTrainerTrainee = theTrainer.trainee[indexPath.row]
                cell.textLabel?.text = DataServer.studentDic[theTrainerTrainee.documentID]?.name
                cell.detailTextLabel?.text = DataServer.studentDic[theTrainerTrainee.documentID]?.memberID
            default:
                print("here")
            }
        } else if let theCourse = selected as? EFCourse{
            let theCourseTraineeRef = theCourse.traineeRef[indexPath.row]
            cell.textLabel?.text = DataServer.studentDic[theCourseTraineeRef.documentID]?.name
            cell.detailTextLabel?.text = DataServer.studentDic[theCourseTraineeRef.documentID]?.memberID
        } else {
            print("here")
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let theStudent = selected as? EFStudent{
            switch section{
            case 0:
                return "学生课程"
            case 1:
                return "学生注册"
            case 2:
                return "学生信息"
            case 3:
                return "学生个人"
            default:
                return ""
            }
        }  else if let theTrainer = selected as? EFTrainer{
            switch section{
            case 0:
                return "学生完成"
            case 1:
                return "学生学生"
            default:
                return ""
            }
        } else if let theCourse = selected as? EFCourse{
            return "学生"
        } else {
            return ""
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
