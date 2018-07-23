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
        switch generalDataTypeOfData {
        case .coursePurchase:
            Firestore.firestore().collection("<#T##collectionPath: String##String#>")
        default:
            <#code#>
        }
    }
    
    override func reload() {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
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
