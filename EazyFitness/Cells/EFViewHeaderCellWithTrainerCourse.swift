//
//  EFViewHeaderCellWithTrainerCourse.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFViewHeaderCellWithTrainerCourse: EFExtentableHeaderCell {
    
    
    @IBOutlet weak var back: UIView!
    
    @IBOutlet weak var BarRightLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var TextLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundView.layer.cornerRadius = 10
        self.backgroundView.clipsToBounds = true
        self.back.layer.cornerRadius = 10
        self.back.clipsToBounds = true
    }
    
}
