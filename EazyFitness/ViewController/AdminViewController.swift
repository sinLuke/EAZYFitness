//
//  AdminViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/5.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class AdminViewController: DefaultCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let 刷新菊花 = UIRefreshControl()
    var 数据库:Firestore!
    
    var 教练ref列表:[[String:DocumentReference]] = []
    var 学生ref列表:[[String:DocumentReference]] = []
    
    var 申请标题列表:[String:String] = [:]
    var 申请ref列表:[String:DocumentReference] = [:]
    
    override func refresh() {

    }
    
    override func reload() {
        self.collectionView?.reloadData()
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
            + 1//总课程统计
            + enumService.Region.count//分区数
            + 0//request数
        } else {
            return 2 //总学生，总教练
                + 1//总课程统计
                + 0//request数
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 申请ref列表.count:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allStudent", for: indexPath) as! AdminStudentViewCell
            cell.numberOfStudentsLabel.text = "\(DataServer.studentDic.count)"
            cell.layer.cornerRadius = 10
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            return cell
        case 申请ref列表.count + 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allTrainer", for: indexPath) as! AdminTrainerViewCell
            cell.numberOfTrainerLabel.text = "\(DataServer.trainerDic.count)"
            cell.layer.cornerRadius = 10
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestBoard", for: indexPath) as! AdminRequestViewCell
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 申请ref列表.count:
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
        case 申请ref列表.count + 1:
            return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
        default:
            if indexPath.row < 申请ref列表.count{
                return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 124)
            } else {
                return CGSize(width: ((self.collectionView?.frame.width)! - 10)/3 - 10, height: 124)
            }
            
        }
        if indexPath.row == 申请ref列表.count {
            
        } else {
            
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

}
