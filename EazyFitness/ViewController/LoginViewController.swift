//
//  LoginViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/26.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents
class LoginViewController: DefaultViewController, UITextFieldDelegate {
    var db: Firestore!
    @IBOutlet weak var emailField: MDCTextField!
    @IBOutlet weak var nextButton: UIButton!
    var userInfo:NSDictionary?
    var callBackVC:credentialReciever!
    var singleUse:Bool = false
    
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

    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    @IBAction func backbtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func nextSetp(_ sender: Any) {
        if let email = self.emailField.text{
            if isValidEmail(testStr: self.emailField.text!) == false{
                AppDelegate.showError(title: "邮箱错误", err: "这不是有效的邮箱")
            } else {

                ActivityViewController.shared?.activityLabelString = "LoginViewController"
                if singleUse {
                    self.performSegue(withIdentifier: "loginPassword", sender: self)
                } else {
                    DataServer.initfunc(email: email)
                }
            }
        } else {
            print("3")
            AppDelegate.showError(title: "邮箱错误", err: "请输入有效的邮箱")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? LoginPasswordViewController {
            dvc.singleUse = self.singleUse
            dvc.callBackVC = self.callBackVC
        }
    }
}
