//
//  ThisMonthViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import MaterialComponents
class ThisMonthViewCell: MDCCardCollectionCell {
    
    @IBOutlet weak var allCourseFinishedLabel: UILabel!
    @IBOutlet weak var AllTimeLabel: UILabel!
    @IBOutlet weak var thisMonthFinishedLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    @IBAction func goCourseRecord(_ sender: Any) {
        
    }
    
    override func awakeFromNib() {
        //progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 16)
    }
    
}
