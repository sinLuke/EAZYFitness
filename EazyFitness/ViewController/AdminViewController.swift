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

class AdminViewController: DefaultCollectionViewController, refreshableVC, UICollectionViewDelegateFlowLayout {
    
    let 刷新菊花 = UIRefreshControl()
    var 数据库:Firestore!
    
    var 教练ref列表:[[String:DocumentReference]] = []
    var 学生ref列表:[[String:DocumentReference]] = []
    
    var 总上课数:Int = 0
    var 总学生没来数:Int = 0
    var 总剩课时数:Int = 0
    var 总购买课时数:Int = 0
    
    var 本月上课数:Int = 0
    var 本月学生没来数:Int = 0
    var 本月剩课时数:Int = 0
    var 本月购买课时数:Int = 0
    
    func refresh() {
        
    }
    
    func reload() {
        
    }
    
    @objc func 用户刷新(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    func 获取学生总数(){
        if let ug = AppDelegate.AP().usergroup{
            数据库.collection("student").getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "获取数据发生错误", err: err.localizedDescription, handler: AppDelegate.AP().signout)
                } else {
                    if let 文档列表 = snap?.documents{
                        for 文档 in 文档列表{
                            if let dug = 文档.data()["region"] as? String{
                                if dug == ug || ug == "super"{
                                    self.学生ref列表.append([文档.documentID: 文档.reference])
                                }
                            } else {
                                AppDelegate.showError(title: "获取学生时出错", err: "学生的地区无法确定")
                                return
                            }
                        }
                    }
                }
            }
        } else {
            AppDelegate.showError(title: "获取数据发生错误", err: "无法确定用户组", handler: AppDelegate.AP().signout)
        }
    }
    
    func 获取教练总数(){
        if let ug = AppDelegate.AP().usergroup{
            数据库.collection("trainer").getDocuments { (snap, err) in
                if let err = err{
                    AppDelegate.showError(title: "获取数据发生错误", err: err.localizedDescription, handler: AppDelegate.AP().signout)
                } else {
                    if let 文档列表 = snap?.documents{
                        for 文档 in 文档列表{
                            if let dug = 文档.data()["region"] as? String{
                                if dug == ug || ug == "super"{
                                    self.学生ref列表.append([文档.documentID: 文档.reference])
                                    
                                }
                            } else {
                                AppDelegate.showError(title: "获取教练时出错", err: "教练的地区无法确定")
                                return
                            }
                        }
                    }
                }
            }
        } else {
            AppDelegate.showError(title: "获取数据发生错误", err: "无法确定用户组", handler: AppDelegate.AP().signout)
        }
    }
    
    func 获取总上课时数(教练的数据库ref:DocumentReference){
        教练的数据库ref.collection("Finished").whereField("FinishedType", isEqualTo: "Scaned").getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取总上课时数时出现问题", err: err.localizedDescription)
            } else {
                if let 文件列表 = snap?.documents{
                    for 文档 in 文件列表{
                        if let date = 文档.data()["Date"] as? Date{
                            if date > Date().startOfMonth(){
                                self.本月上课数 += 1
                                self.总上课数 += 1
                            } else {
                                self.总上课数 += 1
                            }
                        } else {
                            AppDelegate.showError(title: "获取总上课时数时出现问题", err: "无法确定日期")
                        }
                    }
                } else {
                    AppDelegate.showError(title: "获取总上课时数时出现问题", err: "未知错误")
                }
            }
        }
    }
    
    func 获取总学生没来数(){
        
    }
    
    func 获取总教练没来数(){
        
    }
    
    func 获取总剩课时数(){
        
    }
    
    func 获取总购买课时数(){
        
    }
    
    func 获取当月学生没来数(){
        
    }
    
    func 获取当月剩课时数(){
        
    }
    
    func 获取当月购买课时数(){
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        数据库 = Firestore.firestore()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
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
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
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
