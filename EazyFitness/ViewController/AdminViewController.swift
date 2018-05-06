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
    
    var 申请标题列表:[String:String] = [:]
    var 申请ref列表:[String:DocumentReference] = [:]
    
    var 总上课数:Int = 0
    var 总学生没来数:Int = 0
    var 总教练没来数:Int = 0
    var 总剩课时数:Int = 0
    var 总购买课时数:Int = 0
    
    var 本月上课数:Int = 0
    var 本月学生没来数:Int = 0
    var 本月教练没来数:Int = 0
    var 本月购买课时数:Int = 0
    
    func refresh() {
        获取学生总数()
        获取教练总数()
    }
    
    func reload() {
        self.collectionView?.reloadData()
    }
    
    @objc func 用户刷新(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    func 获取学生总数(){
        if let ug = AppDelegate.AP().usergroup{
            数据库.collection("student").whereField("Registered", isEqualTo: 2).getDocuments { (snap, err) in
                self.学生ref列表 = []
                if let err = err{
                    AppDelegate.showError(title: "获取数据发生错误", err: err.localizedDescription, handler: AppDelegate.AP().signout)
                } else {
                    if let 文档列表 = snap?.documents{
                        for 文档 in 文档列表{
                            if let dug = 文档.data()["region"] as? String{
                                if dug == ug || ug == "super"{
                                    self.学生ref列表.append([文档.documentID: 文档.reference])
                                    print("Here")
                                }
                            } else {
                                AppDelegate.showError(title: "获取学生时出错", err: "学生的地区无法确定")
                                return
                            }
                        }
                        self.reload()
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
                self.教练ref列表 = []
                if let err = err{
                    AppDelegate.showError(title: "获取数据发生错误", err: err.localizedDescription, handler: AppDelegate.AP().signout)
                } else {
                    if let 文档列表 = snap?.documents{
                        for 文档 in 文档列表{
                            if let dug = 文档.data()["region"] as? String{
                                if dug == ug || ug == "super"{
                                    self.教练ref列表.append([文档.documentID: 文档.reference])
                                    self.获取总上课时数(教练的数据库ref: 文档.reference)
                                }
                            } else {
                                AppDelegate.showError(title: "获取教练时出错", err: "教练的地区无法确定")
                                return
                            }
                        }
                        self.reload()
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
    
    func 获取买课申请(){
        if AppDelegate.AP().usergroup == "super"{
            Firestore.firestore().collection("student").getDocuments { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取申请时发生错误", err: err.localizedDescription)
                } else {
                    if let dicList = snap?.documents{
                        for studentdoc in dicList{
                            studentdoc.reference.collection("CourseRegistered").whereField("Approved", isEqualTo: false).getDocuments(completion: { (snap, err) in
                                if let err = err {
                                    AppDelegate.showError(title: "获取申请时发生错误", err: err.localizedDescription)
                                } else {
                                    if let dicList = snap?.documents{
                                        for doc in dicList{
                                            self.申请ref列表[doc.documentID] = doc.reference
                                            self.申请标题列表[doc.documentID] = "为 \(studentdoc.data()["First Name"]) \(studentdoc.data()["First Name"]) 加 \(self.prepareCourseNumber(doc.data()["Amount"] as! Int)) 节课"
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return 11 + 申请ref列表.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 申请ref列表.count:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allStudent", for: indexPath) as! AdminStudentViewCell
            cell.numberOfStudentsLabel.text = "\(self.学生ref列表.count)"
            cell.layer.cornerRadius = 10
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            return cell
        case 申请ref列表.count + 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allTrainer", for: indexPath) as! AdminTrainerViewCell
            cell.numberOfTrainerLabel.text = "\(self.教练ref列表.count)"
            cell.layer.cornerRadius = 10
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            return cell
        case 申请ref列表.count + 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "本月上课数"
            cell.summaryNumberLabel.text = "\(self.本月上课数)"
            cell.layer.cornerRadius = 10
            cell.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
            return cell
        case 申请ref列表.count + 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "总上课数"
            cell.summaryNumberLabel.text = "\(self.总上课数)"
            cell.layer.cornerRadius = 10
            cell.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
            return cell
        case 申请ref列表.count + 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "本月教练没来数"
            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case 申请ref列表.count + 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "总教练没来数"
            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case 申请ref列表.count + 6:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "本月学生没来数"
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case 申请ref列表.count + 7:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "总学生没来数"
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case 申请ref列表.count + 8:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "总剩余课时数"
            cell.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case 申请ref列表.count + 9:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "总课时购买数"
            cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
            return cell
        case 申请ref列表.count + 10:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as! AdminSummaryViewCell
            cell.summaryNameLabel.text = "本月课时购买数"
            cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            cell.layer.cornerRadius = 10
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
