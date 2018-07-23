//
//  AdminSummaryViewCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import MaterialComponents
class AdminSummaryViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    var tinmString = "总"
    var vc: AdminViewController!
    var region:userRegion!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataItemCollectionViewCell", for: indexPath) as! DataItemCollectionViewCell
        switch vc.timeid {
        case 0:
            tinmString = "总"
        case 1:
            tinmString = "本月"
        default:
            tinmString = "本日"
        }
        //print(vc.totalCourseAmount)
        
        switch indexPath.row {
        case 0:
            cell.itemName.text = "\(tinmString)上课数"
            cell.itemValue.text = prepareCourseNumber(vc.totalCourseAmount[region] ?? 0)
            return cell
        case 1:
            cell.itemName.text = "\(tinmString)购买课程次数"
            cell.itemValue.text = prepareCourseNumber(vc.totalPurchaseAmount[region] ?? 0)
            return cell
        case 2:
            cell.itemName.text = "\(tinmString)学生缺勤次数"
            cell.itemValue.text = prepareCourseNumber(vc.totalNoStudent[region]?.count ?? 0)
            return cell
        case 3:
            cell.itemName.text = "\(tinmString)教练缺勤次数"
            cell.itemValue.text = prepareCourseNumber(vc.totalNoTrainer[region]?.count ?? 0)
            return cell
        case 4:
            cell.itemName.text = "\(tinmString)没带卡次数"
            cell.itemValue.text = prepareCourseNumber(vc.totalNoCard[region]?.count ?? 0)
            return cell
        default:
            cell.itemName.text = "\(tinmString)生病次数"
            cell.itemValue.text = prepareCourseNumber(vc.totalIll[region]?.count ?? 0)
            return cell
        }
    }
    
    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AdminDataModel.generalDataScope = .all
        AdminDataModel.generalRegion = region
        //AppDelegate.showError(title: enumService.toDescription(e: region), err: "region")
        switch vc.timeid {
        case 0:
            AdminDataModel.generalDataTime = .all
        case 1:
            AdminDataModel.generalDataTime = .thisMonth
        default:
            AdminDataModel.generalDataTime = .today
        }
        switch indexPath.row {
        case 0:
            AdminDataModel.generalDataTypeOfData = .courseInfo
        case 1:
            AdminDataModel.generalDataTypeOfData = .coursePurchase
        case 2:
            AdminDataModel.generalDataTypeOfData = .noStudent
        case 3:
            AdminDataModel.generalDataTypeOfData = .notrainer
        case 4:
            AdminDataModel.generalDataTypeOfData = .nocard
        default:
            AdminDataModel.generalDataTypeOfData = .ill
        }
        vc.performSegue(withIdentifier: "Datatable", sender: vc)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 165, height: 110)
    }
    
}
