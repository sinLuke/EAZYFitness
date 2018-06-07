//
//  EFCollectionViewCellWithProgress.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFCollectionViewCellWithProgress: EFCollectionViewCell {

    @IBOutlet weak var ContentLabel: UILabel!
    @IBOutlet weak var ContentFootNote: UILabel!
    @IBOutlet weak var ProgressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ProgressBar.tintColor = HexColor.Pirmary
        // Initialization code
    }

}
