//
//  EFCollectionViewCellWithButton.swift
//  EazyFitness
//
//  Created by Luke on 2018/6/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import MaterialComponents

class EFCollectionViewCellWithButton: EFCollectionViewCell {

    @IBOutlet weak var ContentLabel: UILabel!
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var AgreeBtn: UIButton!
    @IBOutlet weak var waitView: UIActivityIndicatorView!
    
    var startTime:Date!
    var efRequest:EFRequest!
    
    @IBAction func Cancel(_ sender: Any) {
        waitView.isHidden = false
        AgreeBtn.isUserInteractionEnabled = false
        waitView.startAnimating()
        UIView.animate(withDuration: 0.5, animations: {
        }) { (_) in
            self.efRequest.cancel()
            self.waitView.isHidden = true
            self.waitView.stopAnimating()
            AppDelegate.refresh()
        }
    }
    
    func function() {
        if startTime != nil, startTime < Date(){
            let message = MDCSnackbarMessage()
            message.text = "无法同意, 申请已过期"
            MDCSnackbarManager.show(message)
        } else {
            waitView.isHidden = false
            AgreeBtn.isUserInteractionEnabled = false
            waitView.startAnimating()
            UIView.animate(withDuration: 0.5, animations: {
            }) { (_) in
                UIView.animate(withDuration: 0.3, animations: {
                    //D9FAD9
                }, completion: { (_) in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.alpha = 0
                    }, completion: { (_) in
                        self.efRequest.approve()
                        self.waitView.isHidden = true
                        self.waitView.stopAnimating()
                        AppDelegate.refresh()
                    })
                })
            }
        }
    }
    
    @IBAction func Agree(_ sender: Any) {
        function()
    }
    
    override func awakeFromNib() {
        AgreeBtn.isUserInteractionEnabled = true
        waitView.isHidden = true
        super.awakeFromNib()
        // Initialization code
        CancelBtn.layer.cornerRadius = 5
        CancelBtn.clipsToBounds = true
        
        AgreeBtn.layer.cornerRadius = 5
        AgreeBtn.clipsToBounds = true
        
    }
}
