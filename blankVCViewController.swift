//
//  blankVCViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/28.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class blankVCViewController: DefaultViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ActivityViewController.shared?.activityLabelString = "blankVCViewController"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {

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
