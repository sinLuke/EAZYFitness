//
//  LoginViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/26.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: DefaultViewController, UITextFieldDelegate {
    var db: Firestore!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    var userInfo:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        emailField.text = emailField.text?.trimmingCharacters(in: .whitespaces)
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginPasswordViewController{
            vc.userInfo = self.userInfo
        }
    }

    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    @IBAction func backbtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func nextSetp(_ sender: Any) {
        print("4")
        if let email = self.emailField.text{
            if isValidEmail(testStr: self.emailField.text!) == false{
                print("2")
                AppDelegate.showError(title: "邮箱错误", err: "这不是有效的邮箱")
            } else {
                self.startLoading()
                db.collection("users").whereField("Email", isEqualTo: email).getDocuments { (snap, err) in
                    if let err = err{
                        self.endLoading()
                        AppDelegate.showError(title: "未知错误", err: err.localizedDescription)
                    } else {
                        if let _snap = snap{
                            if _snap.documents.count == 0{
                                self.endLoading()
                                AppDelegate.showError(title: "邮箱错误", err: "未找到该用户")
                            } else {
                                self.endLoading()
                                self.userInfo = _snap.documents[0].data() as NSDictionary
                                self.performSegue(withIdentifier: "next", sender: self)
                            }
                        } else {
                            print("snap")
                        }
                    }
                }
                
            }
        } else {
            print("3")
            AppDelegate.showError(title: "邮箱错误", err: "请输入有效的邮箱")
        }
    }
}
