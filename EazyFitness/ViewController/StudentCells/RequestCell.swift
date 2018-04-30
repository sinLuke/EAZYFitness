//
//  RequestCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
class RequestCell: UICollectionViewCell {
    
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var requestDiscriptionLabel: UILabel!
    
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var waitView: UIActivityIndicatorView!
    var docRef:DocumentReference!
    
    @IBAction func approve(_ sender: Any) {
        waitView.isHidden = false
        approveBtn.isHidden = true
        waitView.startAnimating()
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }) { (_) in
            self.docRef.updateData(["Approved" : true]) { (err) in
                if let err = err {
                    AppDelegate.showError(title: "网络发生问题", err: err.localizedDescription)
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        //D9FAD9
                        self.backgroundColor = HexColor.Green.withAlphaComponent(0.3)
                    }, completion: { (_) in
                        UIView.animate(withDuration: 0.2, animations: {
                            self.alpha = 0
                        }, completion: { (_) in
                            self.waitView.isHidden = true
                            self.waitView.stopAnimating()
                            AppDelegate.refresh()
                        })
                    })
                }
            }
        }
        
        docRef.updateData(["Approved" : true])
    }
}
