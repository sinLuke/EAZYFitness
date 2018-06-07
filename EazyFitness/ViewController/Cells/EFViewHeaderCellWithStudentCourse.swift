//
//  EFViewHeaderCellWithStudentCourse.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFViewHeaderCellWithStudentCourse: EFExtentableHeaderCell{
    
    @IBOutlet weak var BarRightLabel: UILabel!
    
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var StatusFootNote: UILabel!
    @IBOutlet weak var StatusView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var reportBtn: UIButton!
    
    @IBAction func report(_ sender: Any) {
        
    }
    
    var statusCircleColor: HexColor? {
        set (color) {
            if color == nil {
                StatusView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
                StatusView.backgroundColor = UIColor.white
            } else {
                StatusView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
                StatusView.backgroundColor = color!
            }
        } get {
            return HexColor.Blue
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundView.layer.cornerRadius = 10
        self.backgroundView.clipsToBounds = true
        
        reportBtn.layer.cornerRadius = 5
        reportBtn.clipsToBounds = true
        
        StatusView.layer.cornerRadius = 8
        reportBtn.clipsToBounds = true
        
        StatusView.layer.borderWidth = 1
    }
    
}
