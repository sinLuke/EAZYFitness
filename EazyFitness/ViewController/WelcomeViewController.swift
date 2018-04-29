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
        
        timetablescrollview.contentSize = CGSize(width: timetablescrollview.frame.width, height: timetablescrollview.frame.height*2)
        let timetable = UIView(frame: CGRect(x: 0, y: 0, width: timetablescrollview.frame.width, height: timetablescrollview.frame.height*2))
        
        if let cuser = Auth.auth().currentUser{
            ref.child("users").child(cuser.uid).child("timetable").observeSingleEvent(of: .value) { (snap) in
                if let doc = snap.value as? NSDictionary{
                    TimeTable.makeTimeTable(on: timetable, with: [
                        "Luke":["mon":[0,0], "fri":[1250,5], "sat":[1900, 3], "sun":[1820, 3], "thu":[1700, 4], "wed":[1250, 3]],
                        "Brandon":["mon":[1230,3], "fri":[1150,2], "sat":[1700, 2], "sun":[0620, 5], "thu":[0700, 4], "wed":[1000, 3]],
                        "Evo":["mon":[1500,3], "fri":[1219,2], "sat":[1500, 2], "sun":[1918, 5], "thu":[2222, 2], "wed":[0, 0]]])
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
