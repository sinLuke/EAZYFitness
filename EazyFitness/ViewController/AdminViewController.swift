//
//  AdminViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/5.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class AdminViewController: DefaultCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let 刷新菊花 = UIRefreshControl()
    var 数据库:Firestore!
    
    var selectedRegion:userRegion!
    
    var 教练ref列表:[[String:DocumentReference]] = []
    var 学生ref列表:[[String:DocumentReference]] = []
    
    //Data
    var timeid = 0 // 0:总，1:本月，2:本日
    var totalCourse:[userRegion: [EFCourse]] = [:]
    var totalCourseAmount: [userRegion: Int] = [:]
    var totalPurchase:[userRegion: [EFStudentRegistered]] = [:]
    var totalPurchaseAmount:[userRegion: Int] = [:]
    var totalNoStudent:[userRegion: [EFStudentCourse]] = [:]
    var totalNoTrainer:[userRegion: [EFCourse]] = [:]
    var totalNoCard:[userRegion: [EFStudentCourse]] = [:]
    var totalIll:[userRegion: [EFStudentCourse]] = [:]
    
    override func refresh() {
        AppDelegate.AP().ds?.download()
        self.reload()
    }
    
    override func reload() {
        
        totalCourse = [:]
        totalCourseAmount = [:]
        totalPurchase = [:]
        totalPurchaseAmount = [:]
        totalNoStudent = [:]
        totalNoTrainer = [:]
        totalNoCard = [:]
        totalIll = [:]
        
        self.collectionView?.reloadData()
        
        for theStudent in DataServer.studentDic.values{
            for regester in theStudent.registeredDic.values{
                switch timeid{
                case 1:
                    if regester.date < Date().startOfMonth(){
                        continue
                    }
                case 2:
                    if regester.date < Date().startOfTheDay(){
                        continue
                    }
                default:
                    break
                }
                if totalPurchase[theStudent.region] == nil {
                    totalPurchase[theStudent.region] = [regester]
                    totalPurchaseAmount[theStudent.region] = regester.amount
                } else {
                    totalPurchase[theStudent.region]!.append(regester)
                    totalPurchaseAmount[theStudent.region]! += regester.amount
                }
            }
        }
        
        for theCourse in DataServer.courseDic.values{
            switch timeid{
            case 1:
                if theCourse.date < Date().startOfMonth(){
                    continue
                }
            case 2:
                if theCourse.date < Date().startOfTheDay(){
                    continue
                }
            default:
                break
            }
            
            //totalCourse
            if let regionForCourse = DataServer.studentDic[theCourse.traineeRef[0].documentID]?.region{
                if enumService.toDescription(d: theCourse.getTraineesStatus) == "已全部扫描" {
                    if totalCourse[regionForCourse] == nil {
                        totalCourse[regionForCourse] = [theCourse]
                    } else {
                        totalCourse[regionForCourse]!.append(theCourse)
                    }
                } else if enumService.toDescription(d: theCourse.getTraineesStatus) == "教练未到" {
                    if totalNoTrainer[regionForCourse] == nil {
                        totalNoTrainer[regionForCourse] = [theCourse]
                    } else {
                        totalNoTrainer[regionForCourse]!.append(theCourse)
                    }
                }
            }
            
            for theStudentRef in theCourse.traineeRef{
                if let theStudent = DataServer.studentDic[theStudentRef.documentID]{
                    if let theStudentCourse = theStudent.courseDic[theCourse.ref.documentID]{
                        
                        if theStudentCourse.status == .noStudent{
                            if totalNoStudent[theStudent.region] == nil {
                                totalNoStudent[theStudent.region] = [theStudentCourse]
                            } else {
                                totalNoStudent[theStudent.region]!.append(theStudentCourse)
                            }
                        }
                        
                        if theStudentCourse.status == .noCard{
                            if totalNoCard[theStudent.region] == nil {
                                totalNoCard[theStudent.region] = [theStudentCourse]
                            } else {
                                totalNoCard[theStudent.region]!.append(theStudentCourse)
                            }
                        }
                        
                        if theStudentCourse.status == .ill{
                            if totalIll[theStudent.region] == nil {
                                totalIll[theStudent.region] = [theStudentCourse]
                            } else {
                                totalIll[theStudent.region]!.append(theStudentCourse)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func 用户刷新(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    
    func 获取买课申请(){
    }

    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *), UIScreen.main.bounds.height >= 580{
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            
        }
        数据库 = Firestore.firestore()

        self.refresh()
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        刷新菊花.attributedTitle = NSAttributedString(string: title)
        刷新菊花.addTarget(self, action:
            #selector(用户刷新(_:)),
                                  for: UIControlEvents.valueChanged)
        刷新菊花.tintColor = HexColor.Pirmary
        
        self.collectionView!.refreshControl = self.刷新菊花
        self.collectionView!.addSubview(self.刷新菊花)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if AppDelegate.AP().ds?.region == userRegion.All{
            return 2 //总学生，总教练
            + enumService.Region.count//分区数
            + EFRequest.requestList.count//request数
        } else {
            return 2 //总学生，总教练
                + 1//总课程统计
                + EFRequest.requestList.count//request数
        }
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt \(indexPath) collectionView")
        switch indexPath.row {
        case EFRequest.requestList.count + 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allStudent", for: indexPath) as! AdminStudentViewCell
            cell.numberOfStudentsLabel.text = "\(DataServer.studentDic.count)"
            return cell
        case EFRequest.requestList.count:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allTrainer", for: indexPath) as! AdminTrainerViewCell
            cell.numberOfTrainerLabel.text = "\(DataServer.trainerDic.count)"
            return cell
        default:
            
             
            if AppDelegate.AP().ds?.region == userRegion.All{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
                cell.itemCollectionView.delegate = cell
                cell.itemCollectionView.dataSource = cell
                if (indexPath.row - EFRequest.requestList.count - 2) < enumService.RegionString.count{
                    cell.nameLabel.text = enumService.RegionString[(indexPath.row - EFRequest.requestList.count - 2)]
                    cell.region = enumService.Region[(indexPath.row - EFRequest.requestList.count - 2)]
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
                cell.itemCollectionView.delegate = cell
                cell.itemCollectionView.dataSource = cell
                if indexPath.row == (EFRequest.requestList.count + 2){
                    if let reg = AppDelegate.AP().ds?.region{
                        cell.region = reg
                        cell.nameLabel.text = "总统计数据"
                    } else {
                        cell.region = .Mississauga
                        cell.nameLabel.text = "总统计数据"
                    }
                }
                return cell
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AppDelegate.AP().ds?.region == userRegion.All{
            if indexPath.row - EFRequest.requestList.count - 2 >= 0 && indexPath.row - EFRequest.requestList.count - 2 < enumService.Region.count{
                self.selectedRegion = enumService.Region[(indexPath.row - EFRequest.requestList.count - 2)]
                self.performSegue(withIdentifier: "showTrainerData", sender: self)
            }
        } else {
            if indexPath.row - EFRequest.requestList.count - 2 == 0 {
                if let reg = AppDelegate.AP().ds?.region{
                    self.selectedRegion = reg
                    self.performSegue(withIdentifier: "showTrainerData", sender: self)
                } else {
                    self.selectedRegion = .Mississauga
                    self.performSegue(withIdentifier: "showTrainerData", sender: self)
                }
            }
        }
        
        if indexPath.row == EFRequest.requestList.count {
            self.performSegue(withIdentifier: "allTrainer", sender: self)
        }
        
        if indexPath.row == EFRequest.requestList.count + 1 {
            self.performSegue(withIdentifier: "allStudent", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case EFRequest.requestList.count:
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
        case EFRequest.requestList.count + 1:
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
        default:
            
            if AppDelegate.AP().ds?.region == userRegion.All{
                switch (indexPath.row - EFRequest.requestList.count - 2) {
                case 0:
                    return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 150)
                default:
                    return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 150)
                }
                
            } else {
                if indexPath.row == (EFRequest.requestList.count + 2){
                    return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 150)
                }
            }
        }
        if indexPath.row == EFRequest.requestList.count {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 150)
        } else {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 150)
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? DataCollectionViewController {
            dvc.region = self.selectedRegion
        }
    }

}
