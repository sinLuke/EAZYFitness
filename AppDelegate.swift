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
    
    static var notificationValue = 0
    //教练
    var messageListener:[ListenerRegistration] = []
    
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
        print(currentMemberID)
        if let _currentMemberID = self.currentMemberID{
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
                self.startListener()
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
                    if let document = snap?.data() as? NSDictionary{
                        self.UserDoc = document
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
                                AppDelegate.resetMainVC(with: "admin")
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        for listener in self.messageListener{
            listener.remove()
        }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.startListener()
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.\
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.startListener()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        for listener in self.messageListener{
            listener.remove()
        }
    }
    
    func startListener(){
        for listener in self.messageListener{
            listener.remove()
        }
        if usergroup == "student"{
            let messageListener0 = Firestore.firestore().collection("student").document(self.currentMemberID!).collection("Message").document("Last").addSnapshotListener({ (snap, err) in
                AppDelegate.notificationValue = 0
                AppDelegate.checkUserMessage(currentMemberID: self.currentMemberID!, Message: "Message", byStudent: false)
                AppDelegate.checkUserMessage(currentMemberID: self.currentMemberID!, Message: "AdminMessage", byStudent: false)
            })
            let messageListener1 = Firestore.firestore().collection("student").document(self.currentMemberID!).collection("AdminMessage").document("Last").addSnapshotListener({ (snap, err) in
                AppDelegate.notificationValue = 0
                AppDelegate.checkUserMessage(currentMemberID: self.currentMemberID!, Message: "Message", byStudent: false)
                AppDelegate.checkUserMessage(currentMemberID: self.currentMemberID!, Message: "AdminMessage", byStudent: false)
            })
            self.messageListener.append(messageListener0)
            self.messageListener.append(messageListener1)
        } else if usergroup == "trainer"{
            for studentID in self.myStudentListGeneral{
                let messageListener = Firestore.firestore().collection("student").document(studentID).collection("Message").document("Last").addSnapshotListener({ (snap, err) in
                    AppDelegate.notificationValue = 0
                    for studentID in self.myStudentListGeneral{
                        AppDelegate.checkUserMessage(currentMemberID: studentID, Message: "Message", byStudent: true)
                    }
                })
                self.messageListener.append(messageListener)
            }
        }
    }
    
    class func checkUserMessage(currentMemberID:String, Message:String, byStudent:Bool){
        Firestore.firestore().collection("student").document(currentMemberID).collection(Message).whereField("byStudent", isEqualTo: byStudent).whereField("Read", isEqualTo: false).getDocuments(completion: { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取消息时发生错误", err: err.localizedDescription)
            } else {
                AppDelegate.notificationValue += snap!.documents.count
                AppDelegate.setBadges(notificationValue: AppDelegate.notificationValue, for: 1)
            }
        })
    }
    
    
    class func setBadges(notificationValue:Int, for item:Int){
        if let cvc = AppDelegate.getCurrentVC(){
            if let tbc = cvc.tabBarController{
                if let theItems = tbc.tabBar.items{
                    if notificationValue > 0{
                        theItems[item].badgeValue = "\(notificationValue)"
                    } else {
                        theItems[item].badgeValue = nil
                    }
                }
            }
        }
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
    
    class func showSelection(title:String, text:String, of cvc:UIViewController, handlerAgree:(()->())? = nil, handlerDismiss:(()->())? = nil){
        print(title)
        print(text)
        let alert: UIAlertController = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "Default action"), style: .`default`, handler: {_ in
            if let _handler = handlerAgree{
                _handler()
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: "Default action"), style: .cancel, handler: {_ in
            if let _handler = handlerDismiss{
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

