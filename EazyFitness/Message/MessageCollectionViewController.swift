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

class MessageCollectionViewController: DefaultViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {

    var receiver:String!
    var keyboardCanHide = false
    
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var inputViewContainer: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var colRef:CollectionReference!
    var MessageList:[[String:Any]] = []
    @IBOutlet weak var bottomSpace : NSLayoutConstraint!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var sendMessage: UIButton!
    var gesture:UIGestureRecognizer!
    var listener:ListenerRegistration!
    
    var postView_y:CGFloat = 0
    
    var thisTrainerStudent:EFData!
    
    override func refresh() {
        
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
                            if (docs.data()["byStudent"] as! Bool == true) && AppDelegate.AP().ds?.usergroup != userGroup.student{
                                docs.reference.updateData(["Read" : true])
                                (docs.data()["bage"] as! DocumentReference).delete()
                            } else if (docs.data()["byStudent"] as! Bool == false) && AppDelegate.AP().ds?.usergroup == userGroup.student{
                                docs.reference.updateData(["Read" : true])
                                (docs.data()["bage"] as! DocumentReference).delete()
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
    
    override func reload() {
        print(MessageList)
        self.collectionView?.reloadData()
        self.collectionView.setContentOffset(CGPoint(x: 0, y: max(0, self.collectionView.contentSize.height - self.collectionView.frame.height)), animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = falseå
        
        // Register cell classes
        collectionView?.register(UINib.init(nibName: "EventTextCell", bundle: nil), forCellWithReuseIdentifier: "TextCell")
        collectionView?.register(UINib.init(nibName: "SendTextCell", bundle: nil), forCellWithReuseIdentifier: "send")
        messageField.layer.cornerRadius = 5
        messageField.clipsToBounds = true
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
        fieldHeight.constant = 34
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if keyboardCanHide {
            self.dismissKeyboard()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        postView_y = inputViewContainer.frame.origin.y
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func sendMessageAction(_ sender: Any) {
        if let receiverUID = receiver{
            let bageRef = Firestore.firestore().collection("Message").addDocument(data: ["uid" : receiverUID, "bage":1])
            let lastRef = colRef.addDocument(data: ["Read" : false,
                                                    "Text" : self.messageField.text,
                                                    "Time":Date(),
                                                    "byStudent":(AppDelegate.AP().ds?.usergroup == userGroup.student),
                                                    "bage" : bageRef])
            colRef.document("Last").setData(["Text" : self.messageField.text, "ref":lastRef])
        }
        fieldHeight.constant = 34
        self.messageField.text = ""
    }
    
    @objc func dismissKeyboard(){
        self.keyboardCanHide = false
        self.messageField.endEditing(true)
        bottomSpace.constant = 0
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
            let bottomOffset = CGPoint(x: 0, y: max(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height))
            self.collectionView.setContentOffset(bottomOffset, animated: false)
        }) { (_) in
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.messageField.resignFirstResponder()
        if self.messageField.text == ""{
            self.sendMessage.isEnabled = false
        } else {
            self.sendMessage.isEnabled = true
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        bottomSpace.constant = keyboardHeight - (self.tabBarController?.tabBar.frame.height)!
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            
            self.keyboardCanHide = true
        }
        let bottomOffset = CGPoint(x: 0, y: max(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height))
        self.collectionView.setContentOffset(bottomOffset, animated: true)
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        print("keyboardWillHide")
        bottomSpace.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.width;
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame = textView.frame;
        newFrame.size = CGSize(width: fixedWidth, height: newSize.height)
        textView.frame = newFrame;
        print(textView.frame.height)
        fieldHeight.constant = textView.frame.height
        textView.isScrollEnabled = false
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
        
        if ((MessageDic["byStudent"] as! Bool) == true && AppDelegate.AP().ds?.usergroup == userGroup.student) || ((MessageDic["byStudent"] as! Bool) == false && AppDelegate.AP().ds?.usergroup == userGroup.trainer){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "send", for: indexPath) as! SendTextCell
            if let date = MessageDic["Time"] as? Date{
                if (MessageDic["Read"] as? Bool) == true {
                    cell.Messagetime.text = "\(date.descriptDate()) 已读"
                } else {
                    cell.Messagetime.text = "\(date.descriptDate()) 已发送"
                }
            }
            cell.Messagetext.text = MessageDic["Text"] as? String ?? "[消息无法显示]"
            cell.msgView.layer.cornerRadius = 18
            cell.clipsToBounds = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! EventTextCell
            if let date = MessageDic["Time"] as? Date{
                cell.TimeLabel.text = date.descriptDate()
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
