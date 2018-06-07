//
//  EFViewCellWithTrainerCourseStudentStatus.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFViewCellWithTrainerCourseStudentStatus: UICollectionViewCell {

    @IBOutlet weak var StatusLabel: UILabel!
    
    @IBOutlet weak var StatusView: UIView!
    
    @IBOutlet weak var StatusFootNote: UILabel!
    @IBOutlet weak var widthOdCell: NSLayoutConstraint!
    
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
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthOdCell.constant = screenWidth - (2 * 12)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        StatusView.layer.cornerRadius = 8
        StatusView.layer.borderWidth = 1
        
    }
}
