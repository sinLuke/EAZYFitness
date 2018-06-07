//
//  EFExtentableHeaderCellWithButton.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFExtentableHeaderCellWithButton: EFExtentableHeaderCell {
    
    var BarButtonFunction:(()->())? = nil
    
    @IBOutlet weak var BarButton: UIButton!
    @IBAction func BarButtonTapped(_ sender: Any) {
        if BarButtonFunction != nil {
            BarButtonFunction!()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        BarButton.layer.cornerRadius = 5
        BarButton.clipsToBounds = true
    }
    
}
