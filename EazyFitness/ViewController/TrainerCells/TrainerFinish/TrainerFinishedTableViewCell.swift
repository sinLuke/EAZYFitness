//
//  TrainerFinishedTableViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class TrainerFinishedTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTime: UILabel!
    @IBOutlet weak var AmountStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
