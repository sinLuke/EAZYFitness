//
//  GeneralDataViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-07-23.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase

class GeneralDataViewController: DefaultViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func refresh() {
        AdminDataModel.refreshData()
    }
    
    override func reload() {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AdminDataModel.DataDic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cells")
        let dataItem = AdminDataModel.DataDic.values.sorted { (a, b) -> Bool in
            return a.time < b.time
        }[indexPath.row]
        cell?.textLabel?.text = "\(dataItem.title) \(dataItem.time.descriptDate())"
        cell?.textLabel?.text = "\(dataItem.trainerName), \(dataItem.studentName)"
        return cell!
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
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
