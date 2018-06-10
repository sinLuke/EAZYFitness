//
//  MessageCollectionViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/4.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents
private let reuseIdentifier = "Cell"

class EFMessage {
    var time:Date
    var text:String
    var byStudent:Bool
    var read:Bool
    var keyMessage:Bool = false
    var readLabel:Bool = false
    
    
    init(time: Date, text: String, byStudent: Bool, read: Bool, keyMessage: Bool, readLabel: Bool){
        self.time = time
        self.text = text
        self.byStudent = byStudent
        self.read = read
        self.keyMessage = keyMessage
        self.readLabel = readLabel
    }
}

class MessageCollectionViewController: DefaultViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {

    var receiver:String!
    var nameTitle:String? = ""
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var cotainerview: UIView!
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var inputViewContainer: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var colRef:CollectionReference!
    var MessageList:[EFMessage] = []
    var LastMessage:EFMessage?
    var LastMessageByStudent:EFMessage?
    var LastMessageByTrainer:EFMessage?
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
                self.LastMessage = nil
                self.LastMessageByTrainer = nil
                self.LastMessageByStudent = nil
                if let doctList = snaps?.documents{
                    for docs in doctList{
                        if docs.documentID != "Last"{
                            if let time = docs.data()["Time"] as? Date, let text = docs.data()["Text"] as? String, let read = docs.data()["Read"] as? Bool, let byStudent = docs.data()["byStudent"] as? Bool {
                                var thisMessage = EFMessage(time: time, text: text, byStudent: byStudent, read: read, keyMessage: false, readLabel: false)
                                print(thisMessage)
                                if self.LastMessage != nil {
                                    if Calendar.current.date(byAdding: .minute, value: 5, to: self.LastMessage!.time)! < thisMessage.time{
                                        self.LastMessage!.keyMessage = true
                                    }
                                    if self.LastMessageByStudent?.read != thisMessage.read && AppDelegate.AP().ds?.usergroup == userGroup.student && thisMessage.byStudent{
                                        self.LastMessageByStudent?.readLabel = true
                                        print("======")
                                    } else if self.LastMessageByTrainer?.read != thisMessage.read && AppDelegate.AP().ds?.usergroup != userGroup.student && !thisMessage.byStudent{
                                        self.LastMessageByTrainer?.readLabel = true
                                        print("======!")
                                    }
                                    self.MessageList.append(self.LastMessage!)
                                    
                                }
                                if thisMessage.byStudent && AppDelegate.AP().ds?.usergroup != userGroup.student{
                                    docs.reference.updateData(["Read" : true])
                                    (docs.data()["bage"] as! DocumentReference).delete()
                                } else if !thisMessage.byStudent && AppDelegate.AP().ds?.usergroup == userGroup.student{
                                    docs.reference.updateData(["Read" : true])
                                    (docs.data()["bage"] as! DocumentReference).delete()
                                }
                                
                                self.LastMessage = thisMessage
                                if thisMessage.byStudent {
                                    self.LastMessageByStudent = self.LastMessage
                                } else {
                                    self.LastMessageByTrainer = self.LastMessage
                                }
                            }
                        } else {
                            if AppDelegate.AP().ds?.usergroup == userGroup.student {
                                if (docs["TypingByTrainer"] as? Bool) ?? false{
                                    self.title = "对方正在输入……"
                                } else {
                                    self.title = self.nameTitle
                                }
                            } else {
                                if (docs["TypingByStudent"] as? Bool) ?? false{
                                    self.title = "对方正在输入……"
                                } else {
                                    self.title = self.nameTitle
                                }
                            }
                            
                        }
                    }
                    if self.LastMessage != nil {
                        self.LastMessage!.keyMessage = true
                        self.LastMessage!.readLabel = true
                        self.MessageList.append(self.LastMessage!)
                    }
                    self.LastMessageByStudent?.readLabel = true
                    self.LastMessageByTrainer?.readLabel = true
                } else {
                    
                }
                self.reload()
            }
        }
    }
    
    override func reload() {
        self.collectionView?.reloadData()
        self.scrollToBtm()
        
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
        if scrollView.panGestureRecognizer.state == .changed {
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
        self.navigationController?.title = nameTitle
        //scrollToBtm()
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
            AppDelegate.SandNotification(to: receiverUID, with: self.messageField.text, and: "")
            colRef.document("Last").updateData(["Text" : self.messageField.text, "ref":lastRef, "Time":Date()])
        }
        fieldHeight.constant = 34
        self.messageField.text = ""
    }
    
    @objc func dismissKeyboard(){
        self.messageField.endEditing(true)
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
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let navHeight = self.tabBarController?.tabBar.frame.height
        bottomSpace.constant = keyboardHeight - (navHeight ?? 0)
        topSpace.constant = -(keyboardHeight - (navHeight ?? 0))
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.scrollToBtm()
        }
        if AppDelegate.AP().ds?.usergroup == userGroup.student {
            colRef.document("Last").updateData(["TypingByStudent":true, "Time":Date()])
        } else {
            colRef.document("Last").updateData(["TypingByTrainer":true, "Time":Date()])
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomSpace.constant = 0
        topSpace.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.scrollToBtm()
        }
        if AppDelegate.AP().ds?.usergroup == userGroup.student {
            colRef.document("Last").updateData(["TypingByStudent":false, "Time":Date()])
        } else {
            colRef.document("Last").updateData(["TypingByTrainer":false, "Time":Date()])
        }
        
    }
    
    
    func scrollToBtm(){
        let section = collectionView.numberOfSections - 1
        let row = collectionView.numberOfItems(inSection: section) - 1
        if section >= 0 && row >= 0 {
            let lastIndexPath = IndexPath(row: row, section: section)
            collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
        }
        

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
        let theMsg = self.MessageList[indexPath.row]
        
        if (theMsg.byStudent && AppDelegate.AP().ds?.usergroup == userGroup.student) || (theMsg.byStudent == false && AppDelegate.AP().ds?.usergroup == userGroup.trainer){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "send", for: indexPath) as! SendTextCell
            if theMsg.readLabel {
                if theMsg.read {
                    cell.readLabel.text = "已读"
                    cell.readLabel.textColor = HexColor.Pirmary
                } else {
                    cell.readLabel.text = "已发送"
                    cell.readLabel.textColor = HexColor.gray
                }
            } else {
                cell.readLabel.text = ""
            }
            
            cell.Messagetext.text = theMsg.text ?? "[消息无法显示]"
            cell.msgView.layer.cornerRadius = 18
            cell.clipsToBounds = true
            
            cell.Messagetime.textColor = UIColor.gray
            if !theMsg.keyMessage && !theMsg.read {
                cell.Messagetime.text = ""
            } else {
                cell.Messagetime.text = "\(theMsg.time.descriptDate())"
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! EventTextCell
            cell.TimeLabel.text = theMsg.time.descriptDate()
            cell.textOfCell.text = theMsg.text ?? "[消息无法显示]"
            cell.msgView.layer.cornerRadius = 18
            cell.clipsToBounds = true
            
            cell.TimeLabel.textColor = UIColor.gray
            if !theMsg.keyMessage {
                cell.TimeLabel.text = ""
            }
            
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
