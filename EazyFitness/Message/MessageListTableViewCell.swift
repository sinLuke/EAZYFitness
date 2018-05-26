//
//  MessageListTableViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class MessageListTableViewCell: UITableViewCell {

    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var newMessageBar: UIView!
    
    private var read:Bool = true
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var Read:Bool{
        get {
            return self.read
        }
        set(newValue) {
            self.read = newValue
            if newValue {
                self.messageText.textColor = UIColor.black.withAlphaComponent(0.5)
                self.newMessageBar.isHidden = true
            } else {
                self.messageText.textColor = HexColor.Pirmary
                self.newMessageBar.isHidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.newMessageBar.backgroundColor = HexColor.Pirmary
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
