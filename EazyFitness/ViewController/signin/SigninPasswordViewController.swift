//
//  SigninPasswordViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

//#02

class SigninPasswordViewController: DefaultViewController, UITextFieldDelegate {
    
    var fname = "Name"
    var lname = "Undefine"
    var userInfo:NSDictionary?
    var ref: DatabaseReference!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    
    override func viewDidLoad() {

        ref = Database.database().reference()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.fname = (userInfo!.value(forKey: "First Name") as? String) ?? "Name"
        self.lname = (userInfo!.value(forKey: "Last Name") as? String) ?? "Undefine"
        
        nameLabel.text = "\(self.fname) \(self.lname)"
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        self.passwordField.endEditing(true)
        self.password2Field.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func createUserComplete(user:User?, error:Error?)->(){
        if let error = error {
            AppDelegate.showError(title: "创建用户时出现问题(#0103#)", err: error.localizedDescription)
        } else {
            ref.child("users").child(user!.uid).setValue(
                [
                    "MemberID": userInfo!.value(forKey: "MemberID"),
                    "Type": "Student"
                ])
            
        }
    }
    
    @IBAction func finish(_ sender: Any) {
        if let _userEmail = emailField.text{
            let userEmail = _userEmail.trimmingCharacters(in: .whitespaces)
            if self.isValidEmail(testStr: userEmail){
                if password2Field.text != passwordField.text{
                    AppDelegate.showError(title: "密码不一致", err: "请重试(#0101#)")
                    self.password2Field.text = ""
                } else {
                    if let password = passwordField.text{
                        self.startLoading()
                        Auth.auth().createUser(withEmail: userEmail, password: password, completion: self.createUserComplete)
                    }
                }
            } else {
                AppDelegate.showError(title: "邮箱错误", err: "请输入一个正确的邮箱(#0102#)")
            }
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
