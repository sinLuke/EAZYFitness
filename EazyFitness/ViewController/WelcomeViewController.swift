//
//  WelcomeViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/24.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: DefaultViewController {

    
    @IBOutlet weak var timetablescrollview: UIScrollView!
    var ref:DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        timetablescrollview.contentSize = CGSize(width: timetablescrollview.frame.width, height: timetablescrollview.frame.height)
        let timetable = UIView(frame: CGRect(x: 0, y: 0, width: timetablescrollview.frame.width, height: timetablescrollview.frame.height))
        
        if let cuser = Auth.auth().currentUser{
            ref.child("users").child(cuser.uid).child("timetable").observeSingleEvent(of: .value) { (snap) in
                if let doc = snap.value as? NSDictionary{
                    TimeTable.makeTimeTable(on: timetable, with: ["Luke":doc])
                }
            }
        }
        timetablescrollview.addSubview(timetable)
        
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
