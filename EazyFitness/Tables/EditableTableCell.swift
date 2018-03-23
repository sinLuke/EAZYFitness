//
//  EditableTableCellTableViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018-03-22.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

class EditableTableCell: UITableViewCell, UITextFieldDelegate {
    let label:UITextField
    weak var tableView:EditableTableVC?
    var listItems:ListItem? {
        didSet {
            label.text = listItems!.text
        }
    }
    
    let leftMarginForLabel: CGFloat = 15.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: leftMarginForLabel, y: 0, width: bounds.size.width - leftMarginForLabel, height: bounds.size.height)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if listItems != nil {
            listItems?.text = textField.text!
        }
        listItems?.update()
        textField.text = "请稍等……"
        var timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
        return true
    }
    
    @objc func update(){
        self.tableView?.updateDatabase()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        label = UITextField(frame: CGRect.null)
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        label.delegate = self
        label.contentVerticalAlignment = UIControlContentVerticalAlignment.center

        addSubview(label)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
