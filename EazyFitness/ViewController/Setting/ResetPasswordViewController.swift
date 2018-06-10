//
//  ResetPasswordViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-06-10.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class ResetPasswordViewController: DefaultViewController, credentialReciever {
    func callBack(authCredential: AuthCredential) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let cuser = Auth.auth().currentUser, let email = cuser.email{
            if !cuser.isEmailVerified {
                AppDelegate.showSelection(title: "你的邮箱没有验证", text: "\(email)尚未验证，是否要验证？", of: self, handlerAgree: {
                    AppDelegate.showSelection(title: "当前邮箱地址为\(email)，验证邮箱需要重新登录。", text: "如需更换邮箱，请按取消。", of: self, handlerAgree: {
                        Auth.auth().currentUser?.sendEmailVerification { (error) in
                            let message = MDCSnackbarMessage()
                            if let err = error {
                                message.text = "验证邮箱时发生错误: \(err.localizedDescription)"
                            } else {
                                message.text = "已向\(email)发送确认邮件，请注意查收"
                            }
                            MDCSnackbarManager.show(message)
                        }
                        AppDelegate.AP().signout()
                    }, handlerDismiss: {
                        self.performSegue(withIdentifier: "changeEmail", sender: self)
                    })
                }) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                AppDelegate.showSelection(title: "如需重设密码，需要向\(email)发送一封确认邮件。完成设置后需要重新登录。", text: "是否现在发送？", of: self, handlerAgree: {
                    Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                        let message = MDCSnackbarMessage()
                        if let err = error {
                            message.text = "重设密码时发生错误: \(err.localizedDescription)"
                        } else {
                            message.text = "已向\(email)发送确认邮件，请注意查收"
                        }
                        MDCSnackbarManager.show(message)
                    }
                    AppDelegate.AP().signout()
                }) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            AppDelegate.showError(title: "你尚未设置邮箱", err: "无法重新设置密码")
            self.navigationController?.popViewController(animated: true)
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
