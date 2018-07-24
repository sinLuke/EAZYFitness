//
//  SettingVC.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class SettingVC: DefaultViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 5
        case 1:
            return 1
        default:
            return 1
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "signout")
            cell?.selectionStyle = .none
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Text")
            cell?.textLabel?.text = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")"
            cell?.selectionStyle = .none
            return cell!
        default:
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Text")
                if let cuser = Auth.auth().currentUser{
                    cell?.textLabel?.text = cuser.displayName
                }
                cell?.selectionStyle = .none
                return cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Info")
                if let ds = AppDelegate.AP().ds{
                    cell?.detailTextLabel?.text = enumService.toDescription(e: ds.usergroup)
                    cell?.textLabel?.text = "当前登录的用户组"
                }
                cell?.selectionStyle = .none
                return cell!
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Info")
                if let ds = AppDelegate.AP().ds{
                    cell?.detailTextLabel?.text = enumService.toDescription(e: ds.region)
                    cell?.textLabel?.text = "当前用户所在地区"
                }
                cell?.selectionStyle = .none
                return cell!
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Label")
                if let cuser = Auth.auth().currentUser{
                    cell?.textLabel?.text = cuser.email
                    cell?.detailTextLabel?.text = "更改邮箱"
                }
                cell?.selectionStyle = .none
                return cell!
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Label")
                cell?.textLabel?.text = "******"
                cell?.detailTextLabel?.text = "更改密码"
                cell?.selectionStyle = .none
                return cell!
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Info")
                cell?.textLabel?.text = ""
                cell?.selectionStyle = .none
                return cell!
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 2:
            switch indexPath.row{
                case 0:
                    AppDelegate.showSelection(title: "您正在退出您的账号", text: "是否继续", of: self, handlerAgree: AppDelegate.AP().signout, handlerDismiss: nil)
                
                default: break
            }
        case 0:
            switch indexPath.row{
            case 3:
                self.performSegue(withIdentifier: "changeEmail", sender: self)
            case 4:
                self.performSegue(withIdentifier: "changePassword", sender: self)
            default: break
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "我的账户"
        case 1:
            return "EAZY Fitness App"
        case 2:
            return ""
        default:
            return ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
