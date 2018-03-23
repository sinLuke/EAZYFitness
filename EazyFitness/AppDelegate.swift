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
    
    var authUI: FUIAuth? = nil
    
    var myStudent:NSDictionary?
    var allStudent:NSDictionary?
    var trainer:NSDictionary?
    
    var myStudentBOOL = false
    var allStudentBOOL = false
    var trainerBOOL = false
    
    let debug = false

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        self.authUI = FUIAuth.defaultAuthUI()

        self.authUI?.delegate = self

        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        self.authUI?.providers = providers
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    class func getCurrentVC() -> UIViewController{
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let currentViewController = AppDelegate.getCurrentVCFrom(_rootViewController: rootViewController)
        return currentViewController
    }
    
    class func getCurrentVCFrom(_rootViewController:UIViewController?) -> UIViewController{
        var currentViewController:UIViewController
        var rootViewController = _rootViewController
        if (rootViewController?.presentedViewController != nil) {
            rootViewController = _rootViewController?.presentedViewController!
        }
        if (rootViewController?.isKind(of: UITabBarController.self))!  {
            let rootTabBarViewController = rootViewController as! UITabBarController
            currentViewController = AppDelegate.getCurrentVCFrom(_rootViewController: rootTabBarViewController.selectedViewController)
        } else if (rootViewController?.isKind(of: UINavigationController.self))!{
            let rootNavViewController = rootViewController as! UINavigationController
            currentViewController = AppDelegate.getCurrentVCFrom(_rootViewController: rootNavViewController.visibleViewController)
        } else {
            currentViewController = rootViewController!
        }
        return currentViewController
    }
    func presentTrainerView(user: User, mode:Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let trainerViewController = storyboard.instantiateViewController(withIdentifier: "TrainerNav") as! TrainerNav
        trainerViewController.user = user
        trainerViewController.myStudentDic = self.myStudent
        trainerViewController.allStudentDic = self.allStudent
        trainerViewController.trainerDic = self.trainer
        self.myStudentBOOL = false
        self.trainerBOOL = false
        self.allStudentBOOL = false
        switch mode {
        case 1:
            trainerViewController.mode = 1
            AppDelegate.getCurrentVC().present(trainerViewController, animated: true)
            return
        case 2:
            trainerViewController.mode = 2
            AppDelegate.getCurrentVC().present(trainerViewController, animated: true)
            return
        default:
            return
        }
    }
    func signout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    class func sentErrorMessage(message:String){
        let alert = UIAlertController(
            title: "验证出现了问题",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        AppDelegate.getCurrentVC().present(alert, animated: true, completion: nil)
    }
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if user != nil{
            if(debug){
                self.prepareForTrainer(user: user!)
                return
            } else {
                let ref = Database.database().reference()
                ref.child("trainer").observeSingleEvent(of: .value) { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil{
                        for uuid in (value?.allKeys)!{
                            if user?.uid == uuid as? String{
                                self.checkSuper(user: user!)
                                return
                            } else {
                                AppDelegate.sentErrorMessage(message: "用户无效")
                                self.signout()
                                return
                            }
                        }
                    }
                }
                return
            }
        } else {
            AppDelegate.sentErrorMessage(message: "无用户")
            self.signout()
            return
        }

    }
    
    func checkSuper(user: User){
        let ref2 = Database.database().reference()
        ref2.child("superuser").observeSingleEvent(of: .value, with: { (snapshot2) in
            let value2 = snapshot2.value as? NSDictionary
            if value2 != nil{
                for uuid2 in (value2?.allKeys)!{
                    if user.uid == uuid2 as? String{
                        self.prepareForSuper(user: user)
                        return
                    }
                }
                self.prepareForTrainer(user: user)
                return
            }
        })
    }
    
    func prepareForSuper(user: User){
        print(prepareForSuper)
        let ref = Database.database().reference()
        ref.child("trainer").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
            self.myStudent = snapshot.value as? NSDictionary
            self.myStudentBOOL = true
            if ((self.myStudentBOOL && self.allStudentBOOL) && self.trainerBOOL){
                self.presentTrainerView(user: user, mode:2)
            }
        }
        ref.child("trainer").observeSingleEvent(of: .value) { (snapshot) in
            self.trainer = snapshot.value as? NSDictionary
            self.trainerBOOL = true
            if ((self.myStudentBOOL && self.allStudentBOOL) && self.trainerBOOL){
                self.presentTrainerView(user: user, mode:2)
            }
        }
        ref.child("student").observeSingleEvent(of: .value) { (snapshot) in
            self.allStudent = snapshot.value as? NSDictionary
            self.allStudentBOOL = true
            if ((self.myStudentBOOL && self.allStudentBOOL) && self.trainerBOOL){
                self.presentTrainerView(user: user, mode:2)
            }
        }
    }
    
    func prepareForTrainer(user: User){
        let ref = Database.database().reference()
        ref.child("trainer").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
            self.myStudent = snapshot.value as? NSDictionary
            self.trainer = snapshot.value as? NSDictionary
            self.allStudent = snapshot.value as? NSDictionary
            if ((self.myStudent != nil && self.allStudent != nil) && self.trainer != nil){
                self.presentTrainerView(user: user, mode:1)
            }
        }
    }
}

