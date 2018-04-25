//
//  ViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-03-15.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase
import GoogleSignIn

import FirebaseAuthUI
import FirebaseGoogleAuthUI

class ViewController: DefaultViewController, QRCodeReaderViewControllerDelegate {
    var ref: DatabaseReference!
    @IBOutlet weak var contactUS: UIButton!
    @IBOutlet weak var LoginBtn: UIButton!
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader          = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton = true
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    @IBAction func contactUSTapped(_ sender: Any) {
        if #available(iOS 10.0, *) {
            let alert = UIAlertController(title: "将会转到微信", message: "选择您所在的地区", preferredStyle: .actionSheet)
            
            let MississaugaWechat = UIAlertAction(title: "Mississauga", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if let url = URL(string: "https://u.wechat.com/IO7lmzYEPgVGDaG_Lja4_cw") {
                    UIApplication.shared.open(url, options: [:])
                }
            })
            
            let ScarboroughWechat = UIAlertAction(title: "Scarborough", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if let url = URL(string: "https://u.wechat.com/IBUyD9wwrkpsHi7gqwyNLtQ") {
                    UIApplication.shared.open(url, options: [:])
                }
            })
            
            let WaterlooWechat = UIAlertAction(title: "Waterloo", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if let url = URL(string: "https://u.wechat.com/IKwrgLRDClQnqKmKpkeEssE") {
                    UIApplication.shared.open(url, options: [:])
                }
            })
            
            let Website = UIAlertAction(title: "或访问我们的网站", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if let url = URL(string: "https://www.eazy.fitness/contact") {
                    UIApplication.shared.open(url, options: [:])
                }
            })
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
            })
            
            alert.addAction(MississaugaWechat)
            alert.addAction(ScarboroughWechat)
            alert.addAction(WaterlooWechat)
            alert.addAction(Website)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactUS.contentHorizontalAlignment = .left
        LoginBtn.contentHorizontalAlignment = .right
        ref = Database.database().reference()
        if #available(iOS 10.0, *){
            self.contactUS.isHidden = false
        }
        print("USER: ",Auth.auth().currentUser)
        if Auth.auth().currentUser != nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //login
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ScanMyCard(_ sender: Any) {
        self.startLoading()
    }
    
    func fetchUserData(CardID:String, ref:DatabaseReference){
        ref.child("student").child(CardID).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.gotUserData(userInfo: value!)
        }
    }
    
    func gotUserData(userInfo:NSDictionary){
        let registered = userInfo.value(forKey: "Registered") as! Int
        var messageString = ""
        if registered == 0{
            messageString = "用户未注册"
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let studentViewController = storyboard.instantiateViewController(withIdentifier: "Student") as! StudentViewController
            studentViewController.studentInfo = userInfo
            studentViewController.group = "student"
            studentViewController.MemberID = userInfo.value(forKey: "MemberID") as! Int
            self.present(studentViewController, animated: true)
        }
        if messageString != "" {
            let alert = UIAlertController(
                title: "QRCodeReader",
                message: messageString,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        var messageString = ""
        
        print(result.value.isAlphanumeric)
        
        let charset = CharacterSet(charactersIn: ".#$[]")
        if result.value.rangeOfCharacter(from: charset) != nil {
            messageString = "二维码无效"
            
        } else{
            let qrref = self.ref.child("QRCODE").child(result.value)
            if qrref != nil {
                qrref.observeSingleEvent(of: .value, with: { (snapshot) in
                    print (snapshot)
                    // Get user value
                    if let value = snapshot.value as? NSDictionary{
                        if let numberValue = value.value(forKey: "MemberID"){
                            self.fetchUserData(CardID: "\(numberValue)" as! String, ref:self.ref)
                        } else {
                            messageString = "数据库存在错误"
                        }
                    } else {
                        messageString = "二维码无效"
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
            
        }
        
        
        dismiss(animated: true) { [weak self] in
            
            if messageString != "" {
                let alert = UIAlertController(
                    title: "QRCodeReader",
                    message: messageString,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signin(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signin")
        self.present(vc, animated: true) 
    }
    
}



