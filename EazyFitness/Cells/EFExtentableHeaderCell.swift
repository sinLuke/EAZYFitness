//
//  EFExtentableHeaderCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFExtentableHeaderCell: UICollectionReusableView {

    @IBOutlet weak var expandBtn: UIButton!
    @IBOutlet weak var TitleBar: UIView!
    @IBOutlet weak var widthOdCell: NSLayoutConstraint!
    
    var TitleBarColor:UIColor {
        set (value){
            TitleBar.backgroundColor = value
        }
        get {
            return TitleBar.backgroundColor ?? UIColor.black
        }
    }
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var BarItem: UIView!
    var isExpand:Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                if self.isExpand {
                    self.expandBtn.transform = CGAffineTransform(rotationAngle: .pi)
                } else {
                    self.expandBtn.transform = .identity
                }
            }
        }
    }
    var expandNumberOffset:Int{
        get {
            if isExpand {
                return 1
            } else {
                return 0
            }
        }
    }
    
    
    @IBAction func expandFunc(_ sender: Any) {
        self.isExpand = !self.isExpand
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthOdCell.constant = screenWidth - (2 * 12)
        self.TitleBar.layer.cornerRadius = 10
        self.TitleBar.clipsToBounds = true
        // Initialization code
    }
}
