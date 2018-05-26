//
//  DataCollectionViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/23.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class DataCollectionViewController: DefaultCollectionViewController {
    
    let _refreshControl = UIRefreshControl()
    
    var region:userRegion!
    var thisTrainer:EFTrainer!
    var listOfTrainer:[EFTrainer] = []
    var listOfStudent:[EFStudent] = []
    
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
        } else {
            for student in thisTrainer.trainee{
                if let theStudent = DataServer.studentDic[student.documentID]{
                    self.listOfStudent.append(theStudent)
                }
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
            return listOfTrainer.count
        } else {
            return listOfStudent.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollectionViewCell", for: indexPath) as! MemberCollectionViewCell
        
        if thisTrainer == nil {
            let theTrainer = listOfTrainer[indexPath.row]
            cell.NameID.text = "\(theTrainer.name) (\(theTrainer.memberID))"
        } else {
            let theStudent = listOfStudent[indexPath.row]
            cell.NameID.text = "\(theStudent.name) (\(theStudent.memberID))"
        }
        cell.itemCollection.dataSource = cell
        cell.itemCollection.delegate = cell
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
