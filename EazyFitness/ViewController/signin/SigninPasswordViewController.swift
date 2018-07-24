//
//  SigninPasswordViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents
import FirebaseAuth
import FirebaseFirestore
//#02

class SigninPasswordViewController: DefaultViewController, UITextFieldDelegate {

    var db: Firestore!
    
    var usergroup:userGroup!
    var region:userRegion!
    var fname:String!
    var lname:String!
    var memberID:String!
    
    var theUserRefrence: DocumentReference!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailField: MDCTextField!
    @IBOutlet weak var passwordField: MDCTextField!
    @IBOutlet weak var password2Field: MDCTextField!
    
    override func viewDidLoad() {
        
        self.db = Firestore.firestore()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        nameLabel.text = "\(self.fname!) \(self.lname!)"
        
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
    
    func createUserComplete(user:AuthDataResult?, error:Error?)->(){
        if let error = error {
            AppDelegate.showError(title: "创建用户时出现问题(#0103#)", err: error.localizedDescription)

        } else {
            if let cuser = Auth.auth().currentUser{
                if let memberID = self.memberID{
                    let cardID = "\(memberID)"
                    let uuid = UIDevice.current.identifierForVendor!.uuidString
                    db.collection("users").document(cuser.uid).setData([
                        "firstName": self.fname,
                        "lastName": self.lname,
                        "memberID": cardID,
                        "usergroup": enumService.toString(e: userGroup.student),
                        "region": enumService.toString(e: self.region),
                        "email": self.emailField.text!,
                        "loginDevice": uuid
                        ])
                    theUserRefrence.updateData(["registered": enumService.toString(e: .signed), "uid" : cuser.uid])
                    
                    AppDelegate.AP().applicationDidStart()
                } else {
                    AppDelegate.showError(title: "创建用户时出现问题(#0103#)", err: "无法确认卡号")

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
