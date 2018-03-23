//
//  TrainerViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-03-22.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuthUI
import FirebaseDatabase

class TrainerViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    var ref: DatabaseReference!
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader          = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton = true
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    var vc:TrainerNav!
    
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var displayedName: UILabel!
    
    @IBOutlet weak var myStudent: UIButton!
    
    //superuser
    @IBOutlet weak var trainer: UIButton!
    @IBOutlet weak var allStudent: UIButton!
    @IBOutlet weak var superLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        superLabel.layer.cornerRadius = 10
        superLabel.layer.masksToBounds = true
        self.vc = self.navigationController as! TrainerNav
        print(vc.mode)
        if (vc.mode == 2){
            trainer.isHidden = false
            allStudent.isHidden = false
            superLabel.isHidden = false
        } else {
            trainer.isHidden = true
            allStudent.isHidden = true
            superLabel.isHidden = true
        }
        let firebaseAuth = Auth.auth()
        emailAddress.text = firebaseAuth.currentUser?.email
        displayedName.text = firebaseAuth.currentUser?.displayName
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            dismiss(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: MyStudentTableVC.self){
            //let vc = segue.destination as! MyStudentTableVC
            
        }
        // Pass the selected object to the new view controller.
    }
    @IBAction func scan(_ sender: Any) {
        guard checkScanPermissions() else { return }
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate               = self
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
            }
        }
        present(readerVC, animated: true, completion: nil)
    }
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        ref = Database.database().reference()
        
        var cardID="";
        var messageString = ""
        ref.child("QRCODE").child(result.value).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let numberValue = value?.value(forKey: "MemberID")
            cardID = "\(numberValue ?? 0)"
            print(cardID)
            if(cardID != "0"){
                self.fetchUserData(CardID: cardID, ref:self.ref)
            } else {
                messageString = "二维码无效"
            }
        }) { (error) in
            print(error.localizedDescription)
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
            studentViewController.mode = self.vc.mode
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
