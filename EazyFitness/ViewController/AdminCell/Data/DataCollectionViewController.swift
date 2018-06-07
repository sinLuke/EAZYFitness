//
//  DataCollectionViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/23.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class DataCollectionViewController: DefaultCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let _refreshControl = UIRefreshControl()
    
    var region:userRegion!
    var thisTrainer:EFTrainer!
    var listOfTrainer:[EFTrainer] = []
    var listOfStudent:[EFStudent] = []
    
    var selectTrainer:EFTrainer!
    var selectStudent:EFStudent!
    
    override func refresh() {
        
        AppDelegate.AP().ds?.download()
        self.reload()
    }
    
    override func reload() {
        listOfTrainer = []
        listOfStudent = []
        
        if thisTrainer == nil{
            for trainers in DataServer.trainerDic.values {
                
                if trainers.region == region || region == .All{
                    listOfTrainer.append(trainers)
                }
            }
            listOfTrainer.sort { (a, b) -> Bool in
                return Int(a.memberID) ?? 0 < Int(b.memberID) ?? 0
            }
        } else {
            for student in thisTrainer.trainee{
                if let theStudent = DataServer.studentDic[student.documentID]{
                    print(student.documentID)
                    self.listOfStudent.append(theStudent)
                }
            }
            listOfStudent.sort { (a, b) -> Bool in
                return Int(a.memberID) ?? 0 < Int(b.memberID) ?? 0
            }
        }
        self.collectionView?.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.collectionView!.refreshControl = self._refreshControl
        self.collectionView!.addSubview(self._refreshControl)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


        // Do any additional setup after loading the view.
        self.refresh()
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
        if thisTrainer == nil {
            return max(listOfTrainer.count, 1)
        } else {
            return max(listOfStudent.count, 1)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if thisTrainer == nil {
            if listOfTrainer.count == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "no", for: indexPath)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollectionViewCell", for: indexPath) as! MemberCollectionViewCell
                let theTrainer = listOfTrainer[indexPath.row]
                if theTrainer.name != nil, theTrainer.memberID != nil{
                    cell.NameID.text = "\(theTrainer.name)"
                    cell.dateAdded.text = "\(theTrainer.memberID)"
                }
                cell.studentOrTrainer = theTrainer
                cell.itemCollection.dataSource = cell
                cell.itemCollection.delegate = cell
                return cell
            }
        } else {
            if listOfStudent.count == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "no", for: indexPath)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollectionViewCell", for: indexPath) as! MemberCollectionViewCell
                let theStudent = listOfStudent[indexPath.row]
                if theStudent.name != nil, theStudent.memberID != nil{
                    cell.NameID.text = "\(theStudent.name)"
                    cell.dateAdded.text = "\(theStudent.memberID)"
                }
                cell.studentOrTrainer = theStudent
                cell.itemCollection.dataSource = cell
                cell.itemCollection.delegate = cell
                return cell
            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView?.frame.width)! - 20, height: 160)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if thisTrainer == nil {
            self.selectTrainer = listOfTrainer[indexPath.row]
            self.performSegue(withIdentifier: "showStudentData", sender: self)
        } else {
            self.selectStudent = listOfStudent[indexPath.row]
            self.performSegue(withIdentifier: "showOneStudent", sender: self)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? DataCollectionViewController {
            dvc.region = self.region
            dvc.title = "\(selectTrainer.name) 统计数据"
            dvc.thisTrainer = selectTrainer
        }
        if let dvc = segue.destination as? CourseTableViewController {
            dvc.thisStudentOrTrainer = self.selectStudent
            dvc.title = "\(selectStudent.name) 的课程"
        }
        if let dvc = segue.destination as? AllTrainerDetailViewController {
            dvc.thisTrainer = self.thisTrainer
            dvc.titleName = self.thisTrainer.name
            dvc.new = false
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
