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

class LoginPasswordViewController: DefaultViewController, UITextFieldDelegate {
    
    var fname = "Name"
    var lname = "Undefine"
    var email = "email"
    var userInfo:NSDictionary!
    var db: Firestore!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        db = Firestore.firestore()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        print(userInfo)
        print(userInfo.value(forKey: "First Name")as? String)
        self.fname = (userInfo.value(forKey: "First Name") as? String) ?? "Name"
        self.lname = (userInfo.value(forKey: "Last Name") as? String) ?? "Undefine"
        self.email = (userInfo.value(forKey: "Email") as? String) ?? "email"
        
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
    @IBAction func login(_ sender: Any) {
        if let password = self.passwordField.text{
            startLoading()
            Auth.auth().signIn(withEmail: self.email, password: password, completion: { (user, error) in
                if let error = error{
                    self.endLoading()
                    AppDelegate.showError(title: "登陆错误", err: error.localizedDescription)
                }else {
                    self.endLoading()
                    AppDelegate.AP().login()
                }
            })
        } else {
            AppDelegate.showError(title: "请输入密码", err: "密码不能为空")
        }
    }
    
}
