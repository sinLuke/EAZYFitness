//
//  MyStudentVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/24.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase


class MyStudentVC: DefaultViewController, UITableViewDelegate, UITableViewDataSource{
    
    var dic = NSDictionary()
    var sortedKeys = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dic.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        sortedKeys = [String](dic.allKeys as! [String]).sorted() // +++++++++++++++++++++++++++
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "allStudentCell")
        let rowNum = indexPath.row
        let rowInfo = dic.value(forKey: sortedKeys[rowNum]) as? NSDictionary
        
        cell.textLabel?.text = "\(sortedKeys[rowNum])"
        
        if ((rowInfo?.value(forKey: "Registered") as? Int) != 1) {
            cell.detailTextLabel?.text = "未注册"
            cell.detailTextLabel?.textColor = UIColor.red
            
        } else {
            let fname = rowInfo?.value(forKey: "First Name") ?? ""
            let lname = rowInfo?.value(forKey: "Last Name") ?? String(sortedKeys[rowNum])
         
            cell.detailTextLabel?.text = "\(fname) \(lname)"
        }
        
        return (cell)
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
