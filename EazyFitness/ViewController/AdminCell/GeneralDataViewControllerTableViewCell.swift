//
//  GeneralDataViewControllerTableViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/7/23.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

class GeneralDataViewControllerTableViewCell: UITableViewCell {

    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var RightUpLabel: UILabel!
    @IBOutlet weak var RightDownLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
