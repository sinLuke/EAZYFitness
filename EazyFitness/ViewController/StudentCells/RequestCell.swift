//
//  RequestCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class RequestCell: MDCCardCollectionCell {
    var startTime:Date!
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var requestDiscriptionLabel: UILabel!
    
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var waitView: UIActivityIndicatorView!
    var efRequest:EFRequest!
    
    @IBAction func cancel(_ sender: Any) {
        waitView.isHidden = false
        approveBtn.isHidden = true
        waitView.startAnimating()
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }) { (_) in
            self.efRequest.cancel()
            self.waitView.isHidden = true
            self.waitView.stopAnimating()
            AppDelegate.refresh()
        }
    }
    
    @IBAction func approve(_ sender: Any) {
        
        if startTime != nil, startTime < Date(){
            AppDelegate.showError(title: "无法同意", err: "申请已过期")
        } else {
            waitView.isHidden = false
            approveBtn.isHidden = true
            waitView.startAnimating()
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            }) { (_) in
                UIView.animate(withDuration: 0.3, animations: {
                    //D9FAD9
                    self.backgroundColor = HexColor.Green.withAlphaComponent(0.3)
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
}
