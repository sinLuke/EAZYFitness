//
//  adminSelector.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/26.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import MaterialComponents
class adminSelector: UICollectionReusableView {
    override func awakeFromNib() {
        selectorValue.tintColor = UIColor.gray
    }
    var vc:AdminViewController!
    @IBOutlet weak var selectorValue: UISegmentedControl!
    @IBAction func selector(_ sender: Any) {
        print("here")
        vc.timeid = selectorValue.selectedSegmentIndex
        vc.reload()
    }
}
