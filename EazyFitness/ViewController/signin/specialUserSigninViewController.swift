//
//  specialUserSigninViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MaterialComponents
class specialUserSigninViewController: DefaultViewController, UITextFieldDelegate{
    
    var db: Firestore!
    
    @IBOutlet weak var emailField: MDCTextField!
    @IBOutlet weak var passwordField: MDCTextField!
    @IBOutlet weak var password2Field: MDCTextField!
    
    @IBOutlet weak var fnameField: MDCTextField!
    @IBOutlet weak var lnameField: MDCTextField!
    @IBOutlet weak var usergroupLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    
    var Userdata: [String:Any] = [:]
    
    var theUserRefrence: DocumentReference!
    var usergroup:userGroup!
    var region:userRegion!
    var fname:String!
    var lname:String!
    var memberID:String!
    
    var avaliable = false
    
    override func viewDidLoad() {
        
        db = Firestore.firestore()
        ActivityViewController.callStart += 1
        Firestore.firestore().collection("admin").document(enumService.toString(e: region)).getDocument { (snap, err) in
            self.avaliable = true
            if let snap = snap {
                if let data = snap.data(){
                    if data["uid"] != nil && self.usergroup == .admin{
                        self.avaliable = false
                        AppDelegate.showError(title: "该账号已存在", err: "无法注册", handler: self.backFunc)
                    }
                }
            }
            ActivityViewController.callEnd += 1
        }
        
        
        self.fnameField.text = fname
        self.lnameField.text = lname
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        if let ug = self.usergroup, let rg = self.region{
            usergroupLabel.text = enumService.toDescription(e: ug)
            regionLabel.text = enumService.toDescription(e: rg)
        } else {
            AppDelegate.showError(title: "发生未知错误", err: "无法识别用户组1", handler: self.cancelfunc)
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func backFunc(){
        self.navigationController?.popViewController(animated: true)
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
    
    func createUserComplete(user:AuthDataResult?, error:Error?)->(){
        if let error = error {
            AppDelegate.showError(title: "创建用户时出现问题(#0103#)", err: error.localizedDescription)

        } else {
            if let cuser = Auth.auth().currentUser{
                self.db.collection("users").document(cuser.uid).setData(self.Userdata)
                if let _theUserRefrence = theUserRefrence{
                    if let cu = Auth.auth().currentUser{
                        _theUserRefrence.updateData(["registered": enumService.toString(e: .signed)])
                        _theUserRefrence.updateData(["uid" : cu.uid])
                    }
                }
                
                if let ug = self.usergroup, let rg = self.region{
                    print("if let ug = self.usergroup, let rg = self.region{")
                    print(enumService.toString(e: rg))
                    AppDelegate.AP().applicationDidStart()
                } else {
                    AppDelegate.showError(title: "发生未知错误", err: "无法识别用户组2", handler: self.cancelfunc)
                }
            } else {
                AppDelegate.showError(title: "注册失败", err: "请联系客服", handler: self.cancelfunc)
            }
        }
    }
    
    @IBAction func finish(_ sender: Any) {
        if !avaliable {
            self.backFunc()
            return
        }
        if let _userEmail = emailField.text{
            let userEmail = _userEmail.trimmingCharacters(in: .whitespaces)
            if self.isValidEmail(testStr: userEmail){
                if password2Field.text != passwordField.text{
                    AppDelegate.showError(title: "密码不一致", err: "请重试(#0101#)")
                    self.password2Field.text = ""
                } else {
                    if let password = passwordField.text{
                        if let fname = self.fnameField.text, let lname = self.lnameField.text, let ug = self.usergroup, let cardID = self.memberID, let email = self.emailField.text{

                            let uuid = UIDevice.current.identifierForVendor!.uuidString
                            self.Userdata = [
                                "firstName": fname,
                                "lastName": lname,
                                "memberID": cardID,
                                "usergroup": enumService.toString(e: ug),
                                "region": enumService.toString(e: self.region),
                                "email": email,
                                "loginDevice": uuid
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
