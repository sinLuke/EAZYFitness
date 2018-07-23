//
//  AllTrainerDetailViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/6.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class AllTrainerDetailViewController: DefaultViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var _gesture:UIGestureRecognizer!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnManager: UIButton!
    @IBOutlet weak var timeTabelMgr: UIButton!
    var thisTrainer:EFTrainer!
    var titleName:String!
    var new = false
    
    var cell:AllTrainerDetailViewCell!

    override func viewDidAppear(_ animated: Bool) {
        //AppDelegate.showError(title: "该教练不存在", err: "请返回上一页", handler: self.goBack)
    }
    
    func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func reload() {
        cell?.reload()
        if new {
            btnManager.isHidden = true
            timeTabelMgr.isHidden = true
        } else {
            btnManager.isHidden = false
            timeTabelMgr.isHidden = false
        }
    }
    
    override func refresh() {
        thisTrainer.download()
        cell?.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleName
        self._gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(_gesture)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        cell.fname.endEditing(true)
        cell.lname.endEditing(true)
        cell.goalField.endEditing(true)
    }
    
    @IBAction func donebtn(_ sender: Any) {
        cell.doneInput()
    }
    
    @IBAction func manageTrainer(_ sender: Any) {
        cell.uploadData()
        if cell.goalField.text == ""{
            cell.goalField.text = "30"
        }
        if cell.fname.text == "" || cell.lname.text == ""{
            AppDelegate.showError(title: "不允许姓名为空", err: "必须填写姓名")
        } else {
            performSegue(withIdentifier: "manage", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? AllTrainerStudentTableViewController{
            dvc.title = "\(self.title!) 的学生"
            dvc.thisTrainer = self.thisTrainer
        } else if let dvc = segue.destination as? TimeTableViewController{
            dvc.startoftheweek = Date().startOfWeek()
            dvc.cMemberID = nil
            dvc.theStudentOrTrainer = self.thisTrainer
            dvc.title = "本周"
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: max(494, self.view.frame.height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let viewWidth:CGFloat = self.view.frame.width
        let totalCellWidth:CGFloat = 375
        let Inset:CGFloat = max(0, (viewWidth - (totalCellWidth))/2)
        return UIEdgeInsets(top: 0, left: Inset, bottom: 0, right: Inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath) as! AllTrainerDetailViewCell
        cell.vc = self
        self.cell = cell
        cell.reload()
        return cell
    }
}

class AllTrainerDetailViewCell: UICollectionViewCell {
    @IBOutlet weak var fname: MDCTextField!
    @IBOutlet weak var lname: MDCTextField!
    @IBOutlet weak var goalField: MDCTextField!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var registered: UISegmentedControl!
    @IBOutlet weak var region: UISegmentedControl!
    
    
    
    var vc: AllTrainerDetailViewController!
    
    
    override func awakeFromNib() {
        self.region.isEnabled = false
        
        if let region = AppDelegate.AP().ds?.region{
            if region == userRegion.All{
                self.region.selectedSegmentIndex = 0
                self.region.isEnabled = true
            } else {
                let i = enumService.toInt(e: region)
                self.region.selectedSegmentIndex = i
                self.region.isEnabled = false
            }
        } else {
            AppDelegate.showError(title: "无法确定用户组", err: "请重新登录", handler:AppDelegate.AP().signout)
        }
        
        self.refresh()
    }
    
    func doneInput(){
        self.fname.endEditing(true)
        self.lname.endEditing(true)
        self.goalField.endEditing(true)
        if goalField.text == ""{
            goalField.text = "30"
        }
        if self.fname.text != "" && self.lname.text != "" && goalField.text != "" {
            self.uploadData()
            vc.thisTrainer.upload()
            _ = vc.navigationController?.popViewController(animated: true)
        } else {
            AppDelegate.showError(title: "上传出现错误", err: "必须填写姓名")
        }
    }
    
    func uploadData(){
        vc.thisTrainer.firstName = self.fname.text!
        vc.thisTrainer.lastName = self.lname.text!
        vc.thisTrainer.goal = Int(goalField.text!)!
        vc.thisTrainer.registered = enumService.toUserStatus(i: self.registered.selectedSegmentIndex)
        vc.thisTrainer.region = enumService.Region[self.region.selectedSegmentIndex]
        vc.new = false
        vc.title = vc.thisTrainer.name
        self.reload()
    }
    
    func refresh() {
        self.region.removeAllSegments()
        for i in 0...enumService.RegionName.count-1{
            self.region.insertSegment(withTitle: enumService.RegionName[i], at: i, animated: false)
        }
        
        
        reload()
    }
    
    func reload() {
        
        if let vc = vc{
            if let intMemberID = Int(vc.thisTrainer.memberID){
                idLabel.text = String(format:"%04d", intMemberID)
            }
            self.region.selectedSegmentIndex = enumService.toInt(e: vc.thisTrainer.region)
            self.fname.text = vc.thisTrainer.firstName
            self.lname.text = vc.thisTrainer.lastName
            self.goalField.text = String(vc.thisTrainer.goal)
            self.region.selectedSegmentIndex = enumService.toInt(e: vc.thisTrainer.region)
            self.registered.selectedSegmentIndex = enumService.toInt(i: vc.thisTrainer.registered)
            vc.endLoading()
        }
        
    }
}
