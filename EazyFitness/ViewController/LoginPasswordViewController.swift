//
//  LoginPasswordViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/26.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import MaterialComponents
import FirebaseFirestore


class LoginPasswordViewController: DefaultViewController, UITextFieldDelegate {
    var singleUse:Bool = false
    var callBackVC:credentialReciever!
    @IBOutlet weak var welcomeLabel: UILabel!
    var fname = "Name"
    var lname = "Undefine"
    var email = "email"
    var userInfo:NSDictionary!
    var db: Firestore!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordField: MDCTextField!
    
    override func viewDidLoad() {
        db = Firestore.firestore()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        if let ds = AppDelegate.AP().ds{
            self.fname = ds.fname
            self.lname = ds.lname
            self.email = ds.email
        }
        
        emailLabel.text = "\(self.fname) \(self.lname)"
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard(){
        self.passwordField.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        if singleUse {
            self.welcomeLabel.text = "正在验证"
        } else {
            self.welcomeLabel.text = "欢迎"
        }
        
    }
    @IBAction func login(_ sender: Any) {
        if let password = self.passwordField.text{

            if self.singleUse {
                self.callBackVC.callBack(authCredential: EmailAuthProvider.credential(withEmail: self.email, password: password))
                self.dismiss(animated: true, completion: nil)
            } else {
                ActivityViewController.callStart += 1
                Auth.auth().signIn(withEmail: self.email, password: password, completion: { (user, error) in
                    if let error = error{
                        AppDelegate.showError(title: "登陆错误", err: error.localizedDescription)
                    } else {
                        let uuid = UIDevice.current.identifierForVendor!.uuidString
                        if let user = user {
                            Firestore.firestore().collection("users").document(user.user.uid).updateData(["loginDevice" : uuid])
                        } else {
                            AppDelegate.showError(title: "登陆设备时发生错误", err: "建议重新登录用户")
                        }
                    }
                    AppDelegate.AP().dataServerDidFinishInit()
                    ActivityViewController.callEnd += 1
                })
            }
        } else {
            AppDelegate.showError(title: "请输入密码", err: "密码不能为空")
        }
    }
    
}
