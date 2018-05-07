//
//  MessageCollectionViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
private let reuseIdentifier = "Cell"

class MessageCollectionViewController: DefaultViewController,refreshableVC,UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var messageBox: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var colRef:CollectionReference!
    var MessageList:[[String:Any]] = []
    @IBOutlet weak var bottomSpace : NSLayoutConstraint!
    @IBOutlet weak var sendMessage: UIButton!
    var gesture:UIGestureRecognizer!
    var listener:ListenerRegistration!
    
    func refresh() {
        
        AppDelegate.AP().startListener()
        
        colRef.order(by: "Time").getDocuments { (snaps, err) in
            if let err = err{
                AppDelegate.showError(title: "读取信息时发生错误", err: err.localizedDescription)
            } else {
                self.MessageList = []
                if let doctList = snaps?.documents{
                    print(self.colRef.path)
                    for docs in doctList{
                        if docs.documentID != "Last"{
                            self.MessageList.append(docs.data())
                            if (docs.data()["byStudent"] as! Bool == true) && AppDelegate.AP().usergroup != "student"{
                                docs.reference.updateData(["Read" : true])
                            } else if  (docs.data()["byStudent"] as! Bool == false) && AppDelegate.AP().usergroup == "student"{
                                docs.reference.updateData(["Read" : true])
                            }
                        }
                    }
                } else {
                    print("无信息")
                }
                self.reload()
            }
        }
    }
    
    func reload() {
        self.collectionView?.reloadData()
        self.collectionView.setContentOffset(CGPoint(x: 0, y: max(0, self.collectionView.contentSize.height - self.collectionView.frame.height)), animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = falseå
        
        // Register cell classes
        collectionView?.register(UINib.init(nibName: "EventTextCell", bundle: nil), forCellWithReuseIdentifier: "TextCell")
        collectionView?.register(UINib.init(nibName: "SendTextCell", bundle: nil), forCellWithReuseIdentifier: "send")
        
        if let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.estimatedItemSize = CGSize(width: (collectionView?.frame.width)! - 2*12 , height: 200)
            flowlayout.sectionHeadersPinToVisibleBounds = true
        }
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.collectionView.addGestureRecognizer(gesture)
        self.refresh()
        // Do any additional setup after loading the view.
        
        self.listener = colRef.document("Last").addSnapshotListener { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "读取信息时发生错误", err: err.localizedDescription)
            } else {
                self.refresh()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    @IBAction func sendMessageAction(_ sender: Any) {
        colRef.addDocument(data: ["Read" : false, "Text" : self.messageBox.text, "Time":Date(), "byStudent":(AppDelegate.AP().usergroup == "student")])
        colRef.document("Last").setData(["Text" : self.messageBox.text, "Time":Date()])
        self.messageBox.text = ""
    }
    
    @objc func dismissKeyboard(){
        self.messageBox.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.messageBox.resignFirstResponder()
        if self.messageBox.text == ""{
            self.sendMessage.isEnabled = false
        } else {
            self.sendMessage.isEnabled = true
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            if let tabbar = self.tabBarController?.tabBar{
                self.bottomSpace.constant = (keyboardViewEndFrame.height - tabbar.frame.height)
            } else {
                self.bottomSpace.constant = keyboardSize.height
            }
        }
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        //self.collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: false)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        print("keyboardWillHide")
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.bottomSpace.constant = 0
        }
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        //self.collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: false)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        //self.collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: true)
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        //self.collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: true)
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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.MessageList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let MessageDic = self.MessageList[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        if ((MessageDic["byStudent"] as! Bool) == true && AppDelegate.AP().usergroup == "student") || ((MessageDic["byStudent"] as! Bool) == false && AppDelegate.AP().usergroup == "trainer"){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "send", for: indexPath) as! SendTextCell
            if let date = MessageDic["Time"] as? Date{
                if (MessageDic["Read"] as? Bool) == true {
                    cell.Messagetime.text = "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date)) 已读"
                } else {
                    cell.Messagetime.text = "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"
                }
            }
            cell.Messagetext.text = MessageDic["Text"] as? String ?? "[消息无法显示]"
            cell.msgView.layer.cornerRadius = 18
            cell.clipsToBounds = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! EventTextCell
            if let date = MessageDic["Time"] as? Date{
                cell.TimeLabel.text = "\(dateFormatter.string(from: date)) \(date.getThisWeekDayLongName()) \(timeFormatter.string(from: date))"
            }
            cell.textOfCell.text = MessageDic["Text"] as? String ?? "[消息无法显示]"
            cell.msgView.layer.cornerRadius = 18
            cell.clipsToBounds = true
            return cell
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
