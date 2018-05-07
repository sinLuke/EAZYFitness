//
//  specialUserSigninViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class specialUserSigninViewController: DefaultViewController, UITextFieldDelegate{
    
    var userInfo:[String:Any]!
    var db: Firestore!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    
    @IBOutlet weak var fnameField: UITextField!
    @IBOutlet weak var lnameField: UITextField!
    @IBOutlet weak var usergroup: UILabel!
    
    var Userdata: [String:Any] = [:]
    
    var theUserRefrence: DocumentReference!
    
    override func viewDidLoad() {
        
        db = Firestore.firestore()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if let ug = userInfo!["usergroup"] as? String{
            usergroup.text = ug
        } else {
            AppDelegate.showError(title: "发生未知错误", err: "请与技术人员联系", handler: self.cancelfunc)
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    func cancelfunc(){
        AppDelegate.resetMainVC(with: "login")
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
            self.endLoading()
        } else {
            if let cuser = Auth.auth().currentUser{
                self.db.collection("users").document(cuser.uid).setData(self.Userdata)
                if let _theUserRefrence = theUserRefrence{
                    _theUserRefrence.updateData(["Registered": 2])
                }
                switch usergroup.text{
                case "Super":
                    AppDelegate.AP().usergroup = "super"
                    AppDelegate.resetMainVC(with: "super")
                case "trainer":
                    AppDelegate.AP().usergroup = "trainer"
                    AppDelegate.AP().getAllMystudent()
                    AppDelegate.resetMainVC(with: "trainer")
                default:
                    AppDelegate.resetMainVC(with: "admin")
                }
            }
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
                        if let fname = self.fnameField.text, let lname = self.lnameField.text, let ug = usergroup.text, let cardID = userInfo["MemberID"] as? String, let email = self.emailField.text{
                            self.startLoading()
                            self.Userdata = [
                                "First Name": fname,
                                "Last Name": lname,
                                "MemberID": cardID,
                                "Type": ug,
                                "Email": email
                            ]
                            Auth.auth().createUser(withEmail: userEmail, password: password, completion: self.createUserComplete)
                        } else if let fname = self.fnameField.text, let lname = self.lnameField.text, let ug = usergroup.text, let email = self.emailField.text{
                            self.startLoading()
                            self.Userdata = [
                                "First Name": fname,
                                "Last Name": lname,
                                "MemberID": "0",
                                "Type": ug,
                                "Email": email
                            ]
                            Auth.auth().createUser(withEmail: userEmail, password: password, completion: self.createUserComplete)
                        } else {
                            AppDelegate.showError(title: "未知错误", err: "信息输入有误，请检查输入的信息。")
                        }
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
