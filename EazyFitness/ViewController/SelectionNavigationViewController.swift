//
//  SelectionNavigationViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/13.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class SelectionNavigationViewController: UINavigationController {

    var handler:(([EFStudent]) -> ())!
    var listOfStudent:[EFStudent] = []
    
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

}
