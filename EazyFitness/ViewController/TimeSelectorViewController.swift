//
//  TimeSelectorViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-07-28.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class TimeSelectorViewController: UIViewController {
    
    var ref: DocumentReference!
    var TimeDate: Date!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeDetailLabel: UILabel!
    @IBOutlet weak var timeSelector: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishBtn(_ sender: Any) {
        if let TimeDate = self.TimeDate, let ref = self.ref {
            ref.updateData(["date" : TimeDate]) { (err) in
                if let err = err {
                    AppDelegate.showError(title: "更该课程时间时发生错误", err: err.localizedDescription)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
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
