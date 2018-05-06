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
    
    var myStudentListGeneral:[String] = []
    var myStudentListMultiple:[String] = []
    
    //教练
    
    var usergroup:String?
    var myName:String?
    var currentMemberID:String?
    
    var UserDoc:NSDictionary?
    var StudentDoc:NSDictionary?
    
    var authUI: FUIAuth? = nil
    var db: Firestore!
    var myStudent:NSDictionary?
    var allStudent:[String:String]?
    var trainer:NSDictionary?
    
    var myStudentBOOL = false
    var allStudentBOOL = false
    var trainerBOOL = false
    
    var listener:ListenerRegistration?

    var window: UIWindow?
    /*
    func Special(){
        print("***special**")
        var db = Firestore.firestore()
        ref = Database.database().reference()
        ref.child("QRCODE").observeSingleEvent(of: .value) { (snap) in
            if let docList = snap.value as? NSDictionary{
                for allKeyMemberID in docList.allKeys{
                    if let StringMemberID = allKeyMemberID as? String{
                        
                        if let dic = docList[StringMemberID] as? NSDictionary{

                            db.collection("QRCODE").document(StringMemberID).setData(["MemberID" : dic["MemberID"]])
                        }
                        
                    }
                }
            }
        }
    }

    func trainerID(){
        var db = Firestore.firestore()
        db.collection("QRCODE").whereField("MemberID", isEqualTo: 0).addSnapshotListener { (snap, error) in
            if let _snap = snap{
                print("Here")
                for doc in _snap.documents{
                    print(doc.documentID)
                    print(doc.data())
                    self.db.collection("QRCODE").document(doc.documentID).delete()
                }
            }
        }
    }
        */
    
    func getAllMystudent(){
        print("=====")
        print(currentMemberID)
        if let _currentMemberID = self.currentMemberID{
            print("=====")
            print(_currentMemberID)
            let dbref = db.collection("trainer").document(_currentMemberID)
            //获取所有学生ID
            dbref.collection("trainee").getDocuments { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取所有学生时发生错误", err: err.localizedDescription)
                } else {
                    if let studentDocs = snap?.documents{
                        for studentDoc in studentDocs{
                            print(studentDoc)
                            if let studentType = studentDoc.data() as? [String:String]{
                                if studentType["Type"] == "General"{
                                    self.myStudentListGeneral.append(studentDoc.documentID)
                                    print(self.myStudentListGeneral)
                                } else if studentType["Type"] == "Multiple"{
                                    self.myStudentListMultiple.append(studentDoc.documentID)
                                } else {
                                    AppDelegate.showError(title: "获取所有学生时发生错误", err: "无效的学生类别")
                                }
                            } else {
                                AppDelegate.showError(title: "获取所有学生时发生错误", err: "无法转换数据")
                            }
                        }
                    } else {
                        AppDelegate.showError(title: "获取所有学生时发生错误", err: "无法获取数据")
                    }
                }
            }
        }
    }
    
    class func refresh() {
        if let cvc = AppDelegate.getCurrentVC() as? refreshableVC{
            cvc.refresh()
        }
    }
    
    func login()->(){
        print("Login")
        if let vc = AppDelegate.getCurrentVC() as? DefaultViewController{
            vc.startLoading()
        }
        
        self.db = Firestore.firestore()
        if let cuser = Auth.auth().currentUser{
            db.collection("users").document(cuser.uid).getDocument { (snap, err) in
                if let vc = AppDelegate.getCurrentVC() as? DefaultViewController{
                    vc.endLoading()
                }
                if let err = err{
                    AppDelegate.showError(title: "读取用户时发生错误", err: err.localizedDescription)
                } else {
                    print(snap)
                    if let document = snap?.data() as? NSDictionary{
                        self.UserDoc = document
                        print(document)
                        if let Usergroup = document.value(forKey: "Type") as? String{
                            self.usergroup = Usergroup
                            
                            switch Usergroup{
                            case "student":
                                //获取我的所有学生
                                if let userdoc = self.UserDoc, let memberid = userdoc["MemberID"] as? String{
                                    self.currentMemberID = memberid
                                    self.db.collection("student").document(memberid).getDocument(completion: { (snap, err) in
                                        if let err = err{
                                            AppDelegate.showError(title: "读取用户时发生错误", err: err.localizedDescription)
                                        } else {
                                            if let studentdocument = snap?.data() as? NSDictionary{
                                                self.StudentDoc = studentdocument
                                                AppDelegate.resetMainVC(with: "student")
                                            }
                                        }
                                    })
                                }
                            case "super":
                                self.currentMemberID = "1000"
                                AppDelegate.resetMainVC(with: "super")
                            case "mississauga":
                                self.currentMemberID = "0"
                                AppDelegate.resetMainVC(with: "admin")
                            case "waterloo":
                                self.currentMemberID = "0"
                                AppDelegate.resetMainVC(with: "admin")
                            case "scarborough":
                                self.currentMemberID = "0"
                                AppDelegate.resetMainVC(with: "admin")
                            case "trainer":
                                if let userdoc = self.UserDoc, let memberid = userdoc["MemberID"] as? String{
                                    self.currentMemberID = memberid
                                    self.getAllMystudent()
                                    AppDelegate.resetMainVC(with: "trainer")
                                }
                            default:
                                AppDelegate.showError(title: "登陆发生错误", err:"无法确定用户组", handler: self.signout)
                            }
                            
                            
                            
                        }
                    } else {
                        AppDelegate.showError(title: "登陆发生错误", err:"未找到用户", handler: self.signout)
                    }
                }
            }
            
        } else {
            print("else")
            AppDelegate.resetMainVC(with: "login")
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //Special()
        //trainerID()
        
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
        trainerViewController.allStudentDic = self.allStudent as! NSDictionary
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
                                if let doc = snap?.documents[0].data(){
                                    print(doc)
                                }
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
        print(title)
        print(err)
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
        print(ID)
        AppDelegate.AP().window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: ID)
        
        AppDelegate.AP().window?.rootViewController = initialViewController
        AppDelegate.AP().window?.makeKeyAndVisible()
    }
}

