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
            self.backgroundColor = HexColor.lightColor
        }) { (_) in
            self.docRef.updateData(["Approved" : true]) { (err) in
                if let err = err {
                    AppDelegate.showError(title: "网络发生问题", err: err.localizedDescription)
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        //D9FAD9
                        self.backgroundColor = HexColor.init(displayP3Red: 217/255, green: 250/255, blue: 217/255, alpha: 1)
                    }, completion: { (_) in
                        self.waitView.isHidden = true
                        self.waitView.stopAnimating()
                        AppDelegate.refresh()
                    })
                }
            }
        }
        
        docRef.updateData(["Approved" : true])
    }
}
