//
//  MemberCollectionViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/23.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import MaterialComponents
class MemberCollectionViewCell: MDCCardCollectionCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var studentOrTrainer:EFData!
    
    @IBOutlet weak var NameID: UILabel!
    @IBOutlet weak var dateAdded: UILabel!
    @IBOutlet weak var itemCollection: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (studentOrTrainer as? EFTrainer) != nil {
            return 4
        } else if (studentOrTrainer as? EFStudent) != nil {
            return 7
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataItemCollectionViewCell", for: indexPath) as! DataItemCollectionViewCell
        if let theTrainer = studentOrTrainer as? EFTrainer{
            switch indexPath.row {
            case 0:
                cell.itemName.text = "已完成课时"
                cell.itemValue.text = "\(theTrainer.finish.count ?? 0)"
                return cell
            case 1:
                cell.itemName.text = "本月完成课时"
                return cell
            case 2:
                cell.itemName.text = "平均每日完成课时"
                return cell
            case 3:
                cell.itemName.text = "缺勤数"
                return cell
            default:
                cell.itemName.text = "正在载入"
                return cell
            }
        } else if let theStudent = studentOrTrainer as? EFStudent{
            switch indexPath.row {
            case 0:
                cell.itemName.text = "已完成课时"
                return cell
            case 1:
                cell.itemName.text = "本月完成课时"
                return cell
            case 2:
                cell.itemName.text = "平均每日完成课时"
                return cell
            case 3:
                cell.itemName.text = "还剩课时"
                return cell
            case 4:
                cell.itemName.text = "缺勤数"
                return cell
            case 5:
                cell.itemName.text = "没带卡数"
                return cell
            case 6:
                cell.itemName.text = "生病数"
                return cell
            default:
                cell.itemName.text = "正在载入"
                return cell
            }
        } else {
            return cell
        }
    }
}
