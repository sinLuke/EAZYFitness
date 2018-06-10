//
//  SendTextCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class SendTextCell: UICollectionViewCell {

    @IBOutlet weak var widthOfCell: NSLayoutConstraint!
    @IBOutlet weak var Messagetext: UILabel!
    @IBOutlet weak var Messagetime: UILabel!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var readLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthOfCell.constant = screenWidth - (2 * 12)
        readLabel.textColor = HexColor.Pirmary
    }

}
