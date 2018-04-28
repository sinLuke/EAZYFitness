//
//  AppDelegate.swift
//  EazyFitness
//
//  Created by Luke on 2018-03-15.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import Firebase

import FirebaseAuthUI
import FirebaseGoogleAuthUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate {
    
    var usergroup:String?
    
    var authUI: FUIAuth? = nil
    var ref: DatabaseReference!
    var myStudent:NSDictionary?
    var allStudent:NSDictionary?
    var trainer:NSDictionary?
    
    var myStudentBOOL = false
    var allStudentBOOL = false
    var trainerBOOL = false
    
    var listener:ListenerRegistration?

    var window: UIWindow?
    
    
    func login()->(){
        if let vc = AppDelegate.getCurrentVC() as? DefaultViewController{
            print("Hello")
            vc.startLoading()
        }
        
        ref = Database.database().reference()
        if let cuser = Auth.auth().currentUser{
            ref.child("users").child(cuser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let vc = AppDelegate.getCurrentVC() as? DefaultViewController{
                    print("Hello")
                    vc.endLoading()
                }
                if let document = snapshot.value as? NSDictionary{
                    
                    if let Usergroup = document.value(forKey: "Type") as? String{
                        print(Usergroup)
                        self.usergroup = Usergroup
                        switch Usergroup{
                        case "Student":
                            AppDelegate.resetMainVC(with: "student")
                        case "Super":
                            AppDelegate.resetMainVC(with: "super")
                        case "Mississauga":
                            AppDelegate.resetMainVC(with: "admin")
                        case "Waterloo":
                            AppDelegate.resetMainVC(with: "admin")
                        case "Scarborough":
                            AppDelegate.resetMainVC(with: "admin")
                        case "Trainer":
                            AppDelegate.resetMainVC(with: "trainer")
                        default:
                            AppDelegate.showError(title: "登陆发生错误", err:"无法确定用户组", handler: self.signout)
                        }
                    }
                }
            }) { (err) in
                AppDelegate.showError(title: "登陆发生错误", err: err.localizedDescription)
            }
        } else {
            AppDelegate.resetMainVC(with: "login")
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self

        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        self.authUI?.providers = providers
        self.login()
        return true
    }
    /*
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
*/
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.\
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    class func getCurrentVC() -> UIViewController?{
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let currentViewController = AppDelegate.getCurrentVCFrom(_rootViewController: rootViewController)
        return currentViewController
    }
    
    class func getCurrentVCFrom(_rootViewController:UIViewController?) -> UIViewController?{
        var currentViewController:UIViewController
        if var rootViewController = _rootViewController{
            if (rootViewController.presentedViewController != nil) {
                rootViewController = (_rootViewController?.presentedViewController!)!
            }
            if (rootViewController.isKind(of: UITabBarController.self))  {
                let rootTabBarViewController = rootViewController as! UITabBarController
                currentViewController = AppDelegate.getCurrentVCFrom(_rootViewController: rootTabBarViewController.selectedViewController)!
            } else if (rootViewController.isKind(of: UINavigationController.self)){
                let rootNavViewController = rootViewController as! UINavigationController
                currentViewController = AppDelegate.getCurrentVCFrom(_rootViewController: rootNavViewController.visibleViewController)!
            } else {
                currentViewController = rootViewController
            }
            return currentViewController
        } else {
            return nil
        }
        
    }
    func presentTrainerView(user: User, group:String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let trainerViewController = storyboard.instantiateViewController(withIdentifier: "TrainerNav") as! TrainerNav
        trainerViewController.user = user
        trainerViewController.myStudentDic = self.myStudent
        trainerViewController.allStudentDic = self.allStudent
        trainerViewController.trainerDic = self.trainer
        self.myStudentBOOL = false
        self.trainerBOOL = false
        self.allStudentBOOL = false
        trainerViewController.group = group
        AppDelegate.getCurrentVC()?.present(trainerViewController, animated: true)
        return
    }
    /*
    func signout(){
        print ("signout")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    */
    
    func signout() -> Void{
        if let listener = self.listener{
            listener.remove()
        }
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            AppDelegate.showError(title: "sign out error", err: signOutError.localizedDescription)
        }
        AppDelegate.resetMainVC(with: "login")
    }
    
    func requireUser(){
        if let cvc = AppDelegate.getCurrentVC(){
            if Auth.auth().currentUser == nil{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let authViewController = AppDelegate.AP().authUI!.authViewController()
                cvc.present(authViewController, animated: true)
            } else {
                let db = Firestore.firestore()
                let userRef = db.collection("users")
                if let _uid = Auth.auth().currentUser?.uid {
                    userRef.whereField("profileInfo.uid", isEqualTo: _uid).getDocuments { (snap, error) in
                        if let err = error {
                            AppDelegate.showError(title: "Database Error", err: err.localizedDescription, handler: self.signout)
                        } else {
                            if(snap?.documents.count == 0){
                                AppDelegate.showError(title: "Database User Error", err: "Local user cannot find on database", handler: self.signout)
                            } else {
                                
                            }
                        }
                    }
                } else {
                    AppDelegate.showError(title: "Local User Error", err: "Current User dont have uid", handler: self.signout)
                }
            }
        } else {
            print("Here")
        }
    }
    
    
    class func showError(title:String, err:String, of cvc:UIViewController, handler:(()->())? = nil){
        let alert: UIAlertController = UIAlertController(title: title, message: err, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: {_ in
            if let _handler = handler{
                _handler()
            }
        }))
        
        cvc.present(alert, animated: true)
    }
    class func showError(title:String, err:String, handler:(()->())? = nil){
        if let cvc = AppDelegate.getCurrentVC(){
            AppDelegate.showError(title: title, err: err, of: cvc, handler: handler)
        }
    }
    
    /*
    func loginFunc(user:User){
        print("b")
        if let vc = AppDelegate.getCurrentVC() as? ViewController{
            vc.loading.isHidden = false
            vc.loading.startAnimating()
        }
        let ref = Database.database().reference()
        ref.child("trainer").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                for uuid in (value.allKeys){
                    if user.uid == uuid as? String{
                        if let trainervalue = value.value(forKey: uuid as! String) as? NSDictionary{
                            if let usergroup = trainervalue.value(forKey: "usergroup") as? String{
                                switch usergroup{
                                    case "super":
                                        self.prepare(user: user, group: usergroup)
                                    case "trainer":
                                        self.prepare(user: user, group: usergroup)
                            
                                    default: AppDelegate.sentErrorMessage(message: "用户组无效")
                                }
                                return
                            } else {
                                print("1")
                                AppDelegate.sentErrorMessage(message: "用户组无效")
                                self.signout()
                                return
                            }
                        } else {
                            print("2")
                            AppDelegate.sentErrorMessage(message: "用户数据无效")
                            self.signout()
                            return
                        }
                    }
                }
                print("3")
                AppDelegate.sentErrorMessage(message: "loginFunc: 用户无效")
                self.signout()
                return
            }
            else {
                print("4")
                AppDelegate.sentErrorMessage(message: "数据库错误")
                self.signout()
                return
            }
        }
    }
    */
    /*
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if user != nil{
            print("loginFunc")
            loginFunc(user: user!)
        } else {
            AppDelegate.sentErrorMessage(message: "无用户")
            self.signout()
            return
        }
    }
 */
    /*
    func prepare(user: User, group: String){
        let ref = Database.database().reference()
        ref.child("trainer").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
            self.myStudent = snapshot.value as? NSDictionary
            self.myStudentBOOL = true
            if ((self.myStudentBOOL && self.allStudentBOOL) && self.trainerBOOL){
                self.presentTrainerView(user: user, group: group)
            } else {
                print("myStudent")
            }
        }
        ref.child("trainer").observeSingleEvent(of: .value) { (snapshot) in
            self.trainer = snapshot.value as? NSDictionary
            self.trainerBOOL = true
            if ((self.myStudentBOOL && self.allStudentBOOL) && self.trainerBOOL){
                self.presentTrainerView(user: user, group: group)
            } else {
                print("trainer")
            }
        }
        ref.child("student").observeSingleEvent(of: .value) { (snapshot) in
            self.allStudent = snapshot.value as? NSDictionary
            self.allStudentBOOL = true
            if ((self.myStudentBOOL && self.allStudentBOOL) && self.trainerBOOL){
                self.presentTrainerView(user: user, group: group)
            } else {
                print("allStudent")
            }
        }
    }*/
    class func AP() -> AppDelegate{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    class func resetMainVC(with ID: String){
        AppDelegate.AP().window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: ID)
        
        AppDelegate.AP().window?.rootViewController = initialViewController
        AppDelegate.AP().window?.makeKeyAndVisible()
    }
}

