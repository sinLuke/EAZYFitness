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

class MessageCollectionViewController: DefaultViewController,refreshableVC,UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var colRef:CollectionReference!
    var MessageList:[[String:Any]] = []
    @IBOutlet weak var bottomSpace : NSLayoutConstraint!
    
    func refresh() {
        self.MessageList = []
        colRef.order(by: "Time").getDocuments { (snaps, err) in
            if let err = err{
                AppDelegate.showError(title: "读取信息时发生错误", err: err.localizedDescription)
            } else {
                if let doctList = snaps?.documents{
                    print(self.colRef.path)
                    for docs in doctList{
                        self.MessageList.append(docs.data())
                        print(docs.data())
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
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = falseå

        // Register cell classes
        collectionView?.register(UINib.init(nibName: "EventTextCell", bundle: nil), forCellWithReuseIdentifier: "TextCell")
        collectionView?.register(UINib.init(nibName: "SendTextCell", bundle: nil), forCellWithReuseIdentifier: "send")
        if let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.estimatedItemSize = CGSize(width: (collectionView?.frame.width)! - 2*12 , height: 200)
            flowlayout.sectionHeadersPinToVisibleBounds = true
        }
        self.refresh()
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            if let tabbar = self.tabBarController?.tabBar{
                print(tabbar.frame)

                UIView.animate(withDuration: 0.3, animations: {
                    self.bottomSpace.constant += (keyboardViewEndFrame.height - tabbar.frame.height)
                })
                
                
            } else {
                self.bottomSpace.constant = keyboardSize.height

            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.bottomSpace.constant = 0
        }
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
        
        if (MessageDic["byStudent"] as! Bool) == true {
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
