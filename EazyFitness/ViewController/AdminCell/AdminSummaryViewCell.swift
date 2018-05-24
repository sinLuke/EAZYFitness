//
//  AdminSummaryViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import MaterialComponents
class AdminSummaryViewCell: MDCCardCollectionCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    var tinmString = "总"
    
    var region:userRegion!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataItemCollectionViewCell", for: indexPath) as! DataItemCollectionViewCell
        
        switch indexPath.row {
        case 0:
            cell.itemName.text = "\(tinmString)上课数"
            return cell
        case 0:
            cell.itemName.text = "\(tinmString)购买课程数"
            return cell
        case 1:
            cell.itemName.text = "\(tinmString)学生缺勤数"
            return cell
        case 2:
            cell.itemName.text = "\(tinmString)教练缺勤数"
            return cell
        case 3:
            cell.itemName.text = "\(tinmString)没带卡次数"
            return cell
        default:
            cell.itemName.text = "\(tinmString)生病次数"
            return cell
        }
    }
}
