//
//  CourseTableViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/17.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
