//
//  EventHeaderCell.swift
//  Cardigin
//
//  Created by Luke on 2018/3/30.
//  Copyright © 2018年 cardigin. All rights reserved.
//

import UIKit

class EventTextCell: UICollectionViewCell {
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var textOfCell: UILabel!
    @IBOutlet weak var widthOfCell: NSLayoutConstraint!
    @IBOutlet weak var msgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthOfCell.constant = screenWidth - (2 * 12)
    }
}
