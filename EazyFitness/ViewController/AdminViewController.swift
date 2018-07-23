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
    
    let refreshView = UIRefreshControl()
    var db:Firestore!
    
    var 教练ref列表:[[String:DocumentReference]] = []
    var 学生ref列表:[[String:DocumentReference]] = []
    
    var reloadList:[Int:UICollectionView] = [:]
    
    var selectedRegion:userRegion?

    
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
        EFRequest.getRequestForCurrentUser(type: .studentAddValue)
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
        for theStudent in DataServer.studentDic.values{
            for regester in theStudent.registeredDic.values{
                
                if !regester.approved{
                    continue
                }
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
                
                if totalPurchase[.All] == nil {
                    totalPurchase[.All] = [regester]
                    totalPurchaseAmount[.All] = regester.amount
                } else {
                    totalPurchase[.All]!.append(regester)
                    totalPurchaseAmount[.All]! += regester.amount
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
            if theCourse.traineeRef.count != 0{
                if let regionForCourse = DataServer.studentDic[theCourse.traineeRef[0].documentID]?.region{
                    //AppDelegate.showError(title: "regionForCourse", err: enumService.toDescription(d: theCourse.getTraineesStatus))
                    let multiStatus = enumService.toMultiCourseStataus(list: theCourse.traineesStatus)
                    if enumService.FinishedAmountForAdmin(s: multiStatus) == 1 {
                        if totalCourse[regionForCourse] == nil {
                            totalCourse[regionForCourse] = [theCourse]
                            totalCourseAmount [regionForCourse] = theCourse.amount
                        } else {
                            totalCourse[regionForCourse]!.append(theCourse)
                            totalCourseAmount [regionForCourse]! += theCourse.amount
                        }
                        
                        if totalCourse[.All] == nil {
                            totalCourse[.All] = [theCourse]
                            totalCourseAmount [.All] = theCourse.amount
                        } else {
                            totalCourse[.All]!.append(theCourse)
                            totalCourseAmount [.All]! += theCourse.amount
                        }
                        
                    } else if multiStatus == .noTrainer {
                        
                        if totalNoTrainer[regionForCourse] == nil {
                            totalNoTrainer[regionForCourse] = [theCourse]
                        } else {
                            totalNoTrainer[regionForCourse]!.append(theCourse)
                        }
                        
                        if totalNoTrainer[.All] == nil {
                            totalNoTrainer[.All] = [theCourse]
                        } else {
                            totalNoTrainer[.All]!.append(theCourse)
                        }
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
                            if totalNoStudent[.All] == nil {
                                totalNoStudent[.All] = [theStudentCourse]
                            } else {
                                totalNoStudent[.All]!.append(theStudentCourse)
                            }
                        }
                        
                        if theStudentCourse.status == .noCard{
                            if totalNoCard[theStudent.region] == nil {
                                totalNoCard[theStudent.region] = [theStudentCourse]
                            } else {
                                totalNoCard[theStudent.region]!.append(theStudentCourse)
                            }
                            if totalNoCard[.All] == nil {
                                totalNoCard[.All] = [theStudentCourse]
                            } else {
                                totalNoCard[.All]!.append(theStudentCourse)
                            }
                        }
                        
                        if theStudentCourse.status == .ill{
                            if totalIll[theStudent.region] == nil {
                                totalIll[theStudent.region] = [theStudentCourse]
                            } else {
                                totalIll[theStudent.region]!.append(theStudentCourse)
                            }
                            if totalIll[.All] == nil {
                                totalIll[.All] = [theStudentCourse]
                            } else {
                                totalIll[.All]!.append(theStudentCourse)
                            }
                        }
                    }
                }
            }
        }
        
        self.collectionView?.reloadData()
        for views in reloadList.values{
            views.reloadData()
        }
        
    }
    
    @objc func userRefresh(_ refreshControl: UIRefreshControl){
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
        db = Firestore.firestore()

        self.refresh()
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        refreshView.attributedTitle = NSAttributedString(string: title)
        refreshView.addTarget(self, action:
            #selector(userRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        refreshView.tintColor = HexColor.Pirmary
        
        self.collectionView!.refreshControl = self.refreshView
        self.collectionView!.addSubview(self.refreshView)
        
        collectionView?.register(UINib.init(nibName: "EFCollectionViewCellWithButton", bundle: nil), forCellWithReuseIdentifier: "EFCollectionViewCellWithButton")

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
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            if AppDelegate.AP().ds?.region == userRegion.All{
                return 2 + EFRequest.requestList.count//request数
            } else {
                return 2 + EFRequest.requestList.count//request数
            }
        } else {
            if AppDelegate.AP().ds?.region == userRegion.All{
                return 1 //总课程统计
                    + enumService.Region.count//分区数
            } else {
                return 1//总课程统计
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: 0, height: 0)
        } else {
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 50)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "selector", for: indexPath) as! adminSelector
        cell.isUserInteractionEnabled = true
        cell.vc = self
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
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
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestBoard", for: indexPath) as! RequestCell
                cell.self.alpha = 1
                cell.waitView.isHidden = true
                
                cell.approveBtn.isHidden = false
                
                if EFRequest.requestList.count <= indexPath.row{
                    return cell
                } else {
                    let efRequest = EFRequest.requestList[indexPath.row]
                    cell.requestTitleLabel.text = efRequest.title
                    cell.requestDiscriptionLabel.text = efRequest.text
                    
                    cell.efRequest = efRequest
                    return cell
                }
            }
        } else {
            if AppDelegate.AP().ds?.region == userRegion.All{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
                cell.vc = self
                cell.itemCollectionView.delegate = cell
                cell.itemCollectionView.dataSource = cell
                reloadList[indexPath.row] = cell.itemCollectionView
                cell.itemCollectionView.reloadData()
                if (indexPath.row) < enumService.RegionString.count{
                    cell.nameLabel.text = enumService.RegionString[(indexPath.row)]
                    cell.region = enumService.Region[(indexPath.row)]
                } else {
                    cell.nameLabel.text = "总统计数据"
                    cell.region = .All
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
                cell.vc = self
                cell.itemCollectionView.delegate = cell
                cell.itemCollectionView.dataSource = cell
                reloadList[indexPath.row] = cell.itemCollectionView
                cell.itemCollectionView.reloadData()
                if indexPath.row == (0){
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
        if indexPath.section != 0{
            if AppDelegate.AP().ds?.region == userRegion.All{
                if indexPath.row >= 0 && indexPath.row < enumService.Region.count + 1{
                    if (indexPath.row) >= enumService.Region.count{
                        self.selectedRegion = .All
                    } else {
                        self.selectedRegion = enumService.Region[(indexPath.row)]
                    }
                    
                    self.performSegue(withIdentifier: "showTrainerData", sender: self)
                }
            } else {
                if indexPath.row == 0 {
                    if let reg = AppDelegate.AP().ds?.region{
                        self.selectedRegion = reg
                        self.performSegue(withIdentifier: "showTrainerData", sender: self)
                    } else {
                        self.selectedRegion = .Mississauga
                        self.performSegue(withIdentifier: "showTrainerData", sender: self)
                    }
                }
            }
        } else {
            if indexPath.row == EFRequest.requestList.count {
                self.performSegue(withIdentifier: "allTrainer", sender: self)
            }
            
            if indexPath.row == EFRequest.requestList.count + 1 {
                self.performSegue(withIdentifier: "allStudent", sender: self)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            switch indexPath.row {
            case EFRequest.requestList.count:
                return CGSize(width: 320 - 20, height: 124)
            case EFRequest.requestList.count + 1:
                return CGSize(width: 320 - 20, height: 124)
            default:
                return CGSize(width: 320 - 20, height: 150)
            }
            
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
            if self.selectedRegion == .All{
                dvc.title = "总统计数据"
            } else {
                if AppDelegate.AP().ds?.region == .All{
                    dvc.title = "\(enumService.toDescription(e: self.selectedRegion!)) 统计数据"
                } else {
                    dvc.title = "总统计数据"
                }
            }
            
        }
    }

}
