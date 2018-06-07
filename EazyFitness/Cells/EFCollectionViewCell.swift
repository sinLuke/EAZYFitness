//
//  EFCollectionViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var widthOdCell: NSLayoutConstraint!
    @IBOutlet weak var titleBar: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthOdCell.constant = screenWidth - (2 * 12)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        titleBar.layer.cornerRadius = 10
        titleBar.clipsToBounds = true
        // Initialization code
    }

}
