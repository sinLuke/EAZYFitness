//
//  selectionTableViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/7.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class selectionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
