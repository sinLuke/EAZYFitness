//
//  ResetEmailViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-06-10.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import MaterialComponents
import Firebase

class ResetEmailViewController: DefaultViewController, UITextFieldDelegate, credentialReciever {
    func callBack(authCredential: AuthCredential) {
        if let cuser = Auth.auth().currentUser {
            cuser.reauthenticate(with: authCredential) { (err) in
                if let err = err {
                    if let errCode = AuthErrorCode(rawValue: err._code) {
                        if errCode.rawValue == 17014 {
                            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginPassword") as! LoginPasswordViewController
                            loginVC.singleUse = true
                            loginVC.callBackVC = self
                            self.present(loginVC, animated: true, completion: nil)
                        } else {
                            self.errorField.text = err.localizedDescription
                        }
                    }
                    
                } else {
                    self.changeEmail()
                }
            }
        }
    }
    

    @IBOutlet weak var emailField: MDCTextField!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var errorField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorField.text = ""
        errorField.textColor = HexColor.Pirmary
        emailField.delegate = self
        emailField.placeholder = "email@emaple.com"
        if let cuser = Auth.auth().currentUser{
            emailField.text = cuser.email
        } else {
            emailField.text = ""
        }
        // Do any additional setup after loading the view.
    }
    
    func changeEmail(){
        if emailField.text == nil {
            errorField.text = "邮箱不能为空"
        } else {
            Auth.auth().currentUser?.updateEmail(to: emailField.text!) { (error) in
                if let err = error {
                    if let errCode = AuthErrorCode(rawValue: err._code) {
                        if errCode.rawValue == 17014 {
                            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginPassword") as! LoginPasswordViewController
                            loginVC.singleUse = true
                            loginVC.callBackVC = self
                            self.present(loginVC, animated: true, completion: nil)
                        } else {
                            self.errorField.text = err.localizedDescription
                        }
                    }
                    
                } else {
                    Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["email" : self.emailField.text!])
                    AppDelegate.AP().ds?.email = self.emailField.text!
                    let message = MDCSnackbarMessage()
                    message.text = "已成功将\(self.emailField.text!)设置为\(Auth.auth().currentUser!.displayName!)的新邮箱地址"
                    MDCSnackbarManager.show(message)
                    AppDelegate.AP().signout()
                }
            }
        }
    }
    
    @IBAction func done(_ sender: Any) {
        AppDelegate.showSelection(title: "更改邮箱需要重新登录", text: "是否继续？", of: self, handlerAgree: {
            self.changeEmail()
        }) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            doneBtn.isEnabled = false
        } else {
            doneBtn.isEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? ResetPasswordViewController {
            dvc.title = "重设密码"
        } else if let dvc = segue.destination as? ResetEmailViewController {
            dvc.title = "重设邮箱"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        if let cuser = Auth.auth().currentUser{
            cuser.reauthenticate(with: authCredential) { (err) in
                if let err = err {
                    self.errorField.text = err.localizedDescription
                }
            }
        }
 */
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
