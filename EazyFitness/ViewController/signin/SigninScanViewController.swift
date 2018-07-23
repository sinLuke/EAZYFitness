//
//  SigninScanViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
//#01

class SigninScanViewController: DefaultViewController, QRCodeReaderViewControllerDelegate {

    var db: Firestore!
    var registered:userStatus?
    var theUserRefrence: DocumentReference?
    var usergroup:userGroup!
    var region:userRegion!
    var fname:String!
    var lname:String!
    var memberID:String!
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
        self.startLoading()
        let charset = CharacterSet(charactersIn: ".#$[]")
        if result.value.rangeOfCharacter(from: charset) != nil || result.value == ""{
            self.endLoading()
            AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0101#)", of: self)
        } else{
            print(result.value)
            db.collection("QRCODE").document(result.value).getDocument { (snap, err) in
                if let err = err{
                    self.endLoading()
                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription, of: self)
                } else {
                    if let document = snap!.data(){
                        if let _numberValue = document["MemberID"]{
                            let numberValue = "\(_numberValue)"
                            self.fname = ""
                            self.lname = ""
                            self.memberID = numberValue
                            print(numberValue)
                            switch numberValue {
                                
                            case "SUPER":
                                self.usergroup = userGroup.admin
                                self.region = userRegion.All
                                self.performSegue(withIdentifier: "special", sender: self)
                            case "MISSISSAUGA":
                                self.usergroup = userGroup.admin
                                self.region = userRegion.Mississauga
                                self.performSegue(withIdentifier: "special", sender: self)
                            case "WATERLOO":
                                self.usergroup = userGroup.admin
                                self.region = userRegion.Waterloo
                                self.performSegue(withIdentifier: "special", sender: self)
                            case "SCARBOROUGH":
                                self.usergroup = userGroup.admin
                                self.region = userRegion.Scarborough
                                self.performSegue(withIdentifier: "special", sender: self)
                            case "LONDON":
                                self.usergroup = userGroup.admin
                                self.region = userRegion.London
                                self.performSegue(withIdentifier: "special", sender: self)
                            default:
                                self.fetchUserData(CardID: "\(numberValue)")
                            }
                        } else {
                            self.endLoading()
                            AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0103#)", of: self)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func fetchUserData(CardID:String){
        if let CardIDNumber = Int(CardID){
            if CardIDNumber > 1000 && CardIDNumber < 2000{
                //学生
                self.usergroup = userGroup.student
                db.collection("student").document(CardID).getDocument { (snap, err) in
                    if let err = err{
                        self.endLoading()
                        AppDelegate.showError(title: "未知错误", err: err.localizedDescription, of: self)
                    } else {
                        if let data = snap!.data(){
                            self.theUserRefrence = (snap?.reference)
                            self.registered = enumService.toUserStatus(s: data["registered"] as! String)
                            self.fname = data["firstName"] as! String
                            self.lname = data["lastName"] as! String
                            self.memberID = data["memberID"] as! String
                            self.region = enumService.toRegion(s: data["region"] as! String)
                            let thisStudent = EFStudent(with: snap!.reference)
                            thisStudent.download()
                            DataServer.studentDic[snap!.reference.documentID] = thisStudent
                            self.gotUserData()
                        } else {
                            AppDelegate.showError(title: "二维码无效", err: "请与客服联系", of: self)
                        }
                    }
                }
            } else {
                //教练
                self.usergroup = userGroup.trainer
                db.collection("trainer").document(CardID).getDocument { (snap, err) in
                    if let err = err{
                        self.endLoading()
                        AppDelegate.showError(title: "未知错误", err: err.localizedDescription, of: self)
                    } else {
                        if let data = snap!.data(){
                            self.theUserRefrence = (snap?.reference)
                            self.registered = enumService.toUserStatus(s: data["registered"] as! String)
                            self.fname = data["firstName"] as! String
                            self.lname = data["lastName"] as! String
                            self.memberID = data["memberID"] as! String
                            self.region = enumService.toRegion(s: data["region"] as! String)
                            let thisTrainer = EFTrainer(with: snap!.reference)
                            thisTrainer.download()
                            DataServer.trainerDic[snap!.reference.documentID] = thisTrainer
                            self.gotUserData()
                        } else {
                            AppDelegate.showError(title: "二维码无效", err: "请与客服联系", of: self)
                        }
                    }
                }
            }
        } else {
            AppDelegate.showError(title: "二维码无效", err: "无法将卡号转化为ID", of: self)
        }
        
        
    }
    
    func gotUserData(){
        

        if registered == userStatus.canceled || registered == userStatus.avaliable{
            self.endLoading()
            AppDelegate.showError(title: "此卡不允许注册", err: "此会员卡尚未激活或已被注销，请联系客服(#0105#)", of: self, handler: self.signInCancel)
        } else if registered == userStatus.signed{
            self.endLoading()
            AppDelegate.showError(title: "用户已存在", err: "此会员卡已经被注册，请直接登录，或联系客服(#0106#)", of: self, handler: self.signInCancel)
            dismiss(animated: true, completion: nil)
        } else {
            self.endLoading()
            if self.usergroup == userGroup.trainer || self.usergroup == userGroup.admin {
                performSegue(withIdentifier: "special", sender: self)
            } else {
                performSegue(withIdentifier: "password", sender: self)
            }
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func signInCancel()->(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func scanCard(_ sender: Any) {
        scan.scanCard(_vc: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.endLoading()
        if let vc = segue.destination as? SigninPasswordViewController{
            vc.theUserRefrence = self.theUserRefrence
            vc.usergroup = self.usergroup
            vc.region = self.region
            vc.fname = self.fname
            vc.lname = self.lname
            vc.memberID = self.memberID
        } else if let vc = segue.destination as? specialUserSigninViewController{
            vc.theUserRefrence = self.theUserRefrence
            vc.usergroup = self.usergroup
            vc.region = self.region
            print("vc.region = self.region")
            print(enumService.toString(e: self.region))
            vc.fname = self.fname
            vc.lname = self.lname
            vc.memberID = self.memberID
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */

}
