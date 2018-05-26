//
//  AppDelegate.swift
//  EazyFitness
//
//  Created by Luke on 2018-03-15.
//  Copyright © 2018 luke. All rights reserved.
//
//  总完成课时会把取消的可加进去
//  取消的课时间会被重写
//  刷新不完整
//  有时候已过期
//
//
//
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging
import FirebaseAuthUI
import FirebaseGoogleAuthUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var ds:DataServer?
    
    var studentList:[DocumentReference] = []

    //教练
    var messageListener:[ListenerRegistration] = []
    
    var authUI: FUIAuth? = nil
    var db: Firestore!
    
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
    
    class func refresh() {
        if let cvc = AppDelegate.getCurrentVC() as? refreshableVC{
            cvc.refresh()
        }
    }
    
    class func reload() {
        if let cvc = AppDelegate.getCurrentVC() as? refreshableVC{
            cvc.reload()
        }
    }
    
    class func startLoading() {
        if let cvc = AppDelegate.getCurrentVC() as? refreshableVC{
            cvc.startLoading()
        }
    }
    
    class func endLoading() {
        if let cvc = AppDelegate.getCurrentVC() as? refreshableVC{
            cvc.endLoading()
        }
    }
    
    func dataServerDidFinishInit(){
        
        for listener in self.messageListener{
            listener.remove()
        }
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        if let ds = self.ds{
            Firestore.firestore().collection("users").document(ds.uid).updateData(["loginDevice" : uuid])
        }
        
        self.startListener()
        if let cvc = AppDelegate.getCurrentVC() as? refreshableVC{
            cvc.endLoading()
        }
        //Update All Data
        self.ds!.download()
        if Auth.auth().currentUser == nil{
            if let cvc = AppDelegate.getCurrentVC() as? LoginViewController{
                cvc.performSegue(withIdentifier: "loginPassword", sender: cvc)
            } else {
                AppDelegate.resetMainVC(with: "loginPassword")
            }
        } else {
            switch self.ds!.usergroup {
            case .student:
                AppDelegate.resetMainVC(with: "student")
            case .trainer:
                AppDelegate.resetMainVC(with: "trainer")
            case .admin:
                AppDelegate.resetMainVC(with: "admin")
            default:
                AppDelegate.resetMainVC(with: "login")
            }
        }
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //云消息
        Messaging.messaging().delegate = self
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self

        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        
        self.authUI?.providers = providers
        
        self.applicationDidStart()
        return true
    }
    
    func applicationDidStart(){
        if let currentUser = Auth.auth().currentUser{
            DataServer.initfunc(uid: currentUser.uid)
        } else {
            AppDelegate.resetMainVC(with: "login")
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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        for listener in self.messageListener{
            listener.remove()
        }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        for listener in self.messageListener{
            listener.remove()
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        if Auth.auth().currentUser == nil  && AppDelegate.AP().ds == nil{
            self.applicationDidStart()
        } else if AppDelegate.AP().ds != nil{
            self.startListener()
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.\
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if Auth.auth().currentUser == nil{
            self.applicationDidStart()
        } else if AppDelegate.AP().ds != nil{
            self.startListener()
        }
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
        if let currentUser = Auth.auth().currentUser{
            Firestore.firestore().collection("users").document(currentUser.uid).addSnapshotListener { (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取通知消息时发生错误", err: err.localizedDescription)
                } else {
                    let uuid = UIDevice.current.identifierForVendor!.uuidString
                    if let data = snap!.data(){
                        if let onlineID = data["loginDevice"] as? String, onlineID != uuid{
                            self.signout()
                            AppDelegate.showError(title: "您被强制登出", err: "您的账号已在另外一部设备登录，请尽快与管理员联系")
                        }
                    }
                }
            }
            Firestore.firestore().collection("Message").whereField("uid", isEqualTo: ds!.uid).addSnapshotListener{ (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取通知消息时发生错误", err: err.localizedDescription)
                } else {
                    var bages = [0,0,0,0]
                    for doc in snap!.documents{
                        let bageID = doc.data()["bage"] as! Int
                        bages[bageID] += 1
                    }
                    for i in 0...3 {
                        AppDelegate.setBadges(notificationValue: bages[i], for: i)
                    }
                }
            }
        }
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
    
    
    
    class func showError(title:String, err:String, of cvc:UIViewController, handler:(()->())? = nil){
        print(title)
        print(err)
        let alert: UIAlertController = UIAlertController(title: title, message: err, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: {_ in
            self.endLoading()
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
            self.endLoading()
            if let _handler = handlerAgree{
                _handler()
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: "Default action"), style: .cancel, handler: {_ in
            self.endLoading()
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
        
        //为不同的 ViewCointroller 赋初始值
        if let ivc = initialViewController as? StudentTabBarController{
            print("StudentVC")
            ivc.thisStudent = DataServer.studentDic[AppDelegate.AP().ds!.memberID]
            AppDelegate.AP().window?.rootViewController = ivc
            AppDelegate.AP().window?.makeKeyAndVisible()
            
        } else if let ivc = initialViewController as? TrainerTabBarController {
            print("trainerMyStudentVC")
            print(DataServer.trainerDic)
            ivc.thisTrainer = DataServer.trainerDic[AppDelegate.AP().ds!.memberID]
            AppDelegate.AP().window?.rootViewController = ivc
            AppDelegate.AP().window?.makeKeyAndVisible()
            
        } else {
            print("else")
            AppDelegate.AP().window?.rootViewController = initialViewController
            AppDelegate.AP().window?.makeKeyAndVisible()
        }
    }
    
    class func refHandler(dic:[String:Any]) -> DocumentReference {
        return (dic["ref"]! as! DocumentReference)
    }
}

