//
//  TrainerScanCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class TrainerScanCell: UICollectionViewCell {
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        //dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    var rootViewComtroller:DefaultCollectionViewController!
    var studentID:String!

    @IBAction func scaCard(_ sender: Any) {
        scan.scanCard(_vc: rootViewComtroller as! QRCodeReaderViewControllerDelegate)
    }
}
