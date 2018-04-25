//
//  SigninScanViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AVFoundation

//#01

class SigninScanViewController: DefaultViewController, QRCodeReaderViewControllerDelegate {
    
    var userInfo:NSDictionary?
    var ref: DatabaseReference!
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
        let charset = CharacterSet(charactersIn: ".#$[]")
        if result.value.rangeOfCharacter(from: charset) != nil {
            AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0101#)", of: self)
        } else{
            let qrref = self.ref.child("QRCODE").child(result.value)
            self.startLoading()
            qrref.observeSingleEvent(of: .value, with: { (snapshot) in
                print (snapshot)
                if let value = snapshot.value as? NSDictionary{
                    if let _numberValue = value.value(forKey: "MemberID"){
                        let numberValue = "\(_numberValue)"
                        switch numberValue {
                        case "SUPER":
                            self.userInfo = ["usergroup":"super"]
                            self.performSegue(withIdentifier: "special", sender: self)
                        case "MISSISSAUGA":
                            self.userInfo = ["usergroup":"mississauga"]
                            self.performSegue(withIdentifier: "special", sender: self)
                        case "WATERLOO":
                            self.userInfo = ["usergroup":"waterloo"]
                            self.performSegue(withIdentifier: "special", sender: self)
                        case "SCARBOROUGH":
                            self.userInfo = ["usergroup":"scarborough"]
                            self.performSegue(withIdentifier: "special", sender: self)
                        case "TRAINER":
                            self.userInfo = ["usergroup":"trainer"]
                            self.performSegue(withIdentifier: "special", sender: self)
                        default:
                            self.fetchUserData(CardID: "\(numberValue)" , ref:self.ref)
                        }
                    } else {
                        self.endLoading()
                        AppDelegate.showError(title: "未知错误", err: "请稍后再试(#0102#)", of: self)
                    }
                } else {
                    self.endLoading()
                    AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0103#)", of: self)
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func fetchUserData(CardID:String, ref:DatabaseReference){
        ref.child("student").child(CardID).observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                self.userInfo = value
                self.gotUserData()
            } else {
                self.endLoading()
                AppDelegate.showError(title: "未知错误", err: "请稍后再试(#0104#)", of: self)
            }
        }
    }
    
    func gotUserData(){
        let registered = userInfo!.value(forKey: "Registered") as! Int

        if registered == 0{
            self.endLoading()
            AppDelegate.showError(title: "此卡不允许注册", err: "此会员卡尚未激活或已被注销，请联系客服(#0105#)", of: self, handler: self.signInCancel)
        } else if registered == 2{
            self.endLoading()
            AppDelegate.showError(title: "用户已存在", err: "此会员卡已经被注册，请直接登录，或联系客服(#0106#)", of: self, handler: self.signInCancel)
            dismiss(animated: true, completion: nil)
        } else {
            self.endLoading()
            performSegue(withIdentifier: "password", sender: self)
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        
    }
    
    func signInCancel()->(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
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
            print("1")
            vc.userInfo = self.userInfo
        } else if let vc = segue.destination as? specialUserSigninViewController{
            print("2")
            vc.userInfo = self.userInfo
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */

}
