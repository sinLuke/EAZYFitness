//
//  posterViewViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/7.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class posterViewViewController: UIViewController {

    @IBOutlet weak var posterimage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        posterimage.image = #imageLiteral(resourceName: "eazyfitnessposter")
        posterimage.contentMode = .scaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dism (_:)))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dism(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
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
