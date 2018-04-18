//
//  SpecialViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/9.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class SpecialViewController: UIViewController {
    
    var studentInfo: NSDictionary?
    var MemberID: Int!
    var group = "" //4 inside nav
    var special = ""
    
    @IBAction func nocard(_ sender: Any) {
        special = "没带卡"
    }
    
    @IBAction func didntcome(_ sender: Any) {
        special = "没来"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        if segue.identifier == "nocard" || segue.identifier == "didntcome", let destination = segue.destination as? StudentViewController, let _studentInfo = self.studentInfo, let _MemberID = self.MemberID{
            destination.studentInfo = _studentInfo
            destination.MemberID = _MemberID
            destination.group = "trainer"
            destination.special = self.special
            destination.ifBack = true
        }
        // Pass the selected object to the new view controller.
    }

}
