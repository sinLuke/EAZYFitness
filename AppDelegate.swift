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
import MaterialComponents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var ds:DataServer?
    var superUID:String!
    var studentList:[DocumentReference] = []
    
    var thisUser:EFData!

    //教练
    var messageListener:[ListenerRegistration] = []
    
    var authUI: FUIAuth? = nil
    var db: Firestore!
    
    var listener:ListenerRegistration?

    var window: UIWindow?
    
    static var cvc: UIViewController? {
        didSet{
            ActivityViewController.startLoading()
        }
    }
    
    static var token:String?
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

    func dataServerDidFinishInit(){
        getSuperUID()
        for listener in self.messageListener{
            listener.remove()
        }
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        
        
        self.startListener()
        
        //Update All Data
        self.ds!.download()
        if Auth.auth().currentUser == nil{
            if let cvc = AppDelegate.getCurrentVC() as? LoginViewController{
                cvc.performSegue(withIdentifier: "loginPassword", sender: cvc)
            } else {
                AppDelegate.resetMainVC(with: "loginPassword")
            }
        } else {
            if let ds = self.ds{
                Firestore.firestore().collection("users").document(ds.uid).updateData(["loginDevice" : uuid])
            }
            switch self.ds!.usergroup {
            case .student:
                AppDelegate.resetMainVC(with: "student")
            case .trainer:
                AppDelegate.resetMainVC(with: "trainer")
            case .admin:
                AppDelegate.resetMainVC(with: "admin")
            }
        }
    }
    
    class func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
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
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        for listener in self.messageListener{
            listener.remove()
        }
        if let _ds = ds {
            ActivityViewController.callStart += 1
            Firestore.firestore().collection("Message").whereField("uid", isEqualTo: _ds.uid).getDocuments{ (snap, err) in
                if let err = err {
                    AppDelegate.showError(title: "获取通知消息时发生错误", err: err.localizedDescription)
                } else {
                    var bages = [0,0,0,0]
                    var bagesTotal = 0
                    for doc in snap!.documents{
                        let bageID = doc.data()["bage"] as! Int
                        bages[bageID] += 1
                        bagesTotal += 1
                    }
                    for i in 0...3 {
                        AppDelegate.setBadges(notificationValue: bages[i], for: i)
                    }
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                        
                    }
                    application.registerForRemoteNotifications()
                    application.applicationIconBadgeNumber = bagesTotal
                    completionHandler(UIBackgroundFetchResult.newData)
                }
                ActivityViewController.callEnd += 1
            }
        } else {
            completionHandler(UIBackgroundFetchResult.noData)
        }
        
    }
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window!.tintColor = HexColor.Pirmary
        FirebaseApp.configure()
        
        //云消息
        Messaging.messaging().delegate = self
        AppDelegate.token = Messaging.messaging().fcmToken
        
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self

        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        
        self.authUI?.providers = providers
        
        self.applicationDidStart()
        return true
    }
    
    class func SandNotification(to recieverUID:String, with message:String, and title:String?){
        if let currentUser = Auth.auth().currentUser{
            Database.database().reference().child("notification/\(recieverUID)/\(currentUser.uid)").setValue(["message": message, "title":title ?? "", "Date":Date().description])
        }
    }
    
    func applicationDidStart(){
        if let currentUser = Auth.auth().currentUser{
            Auth.auth().languageCode = "cn"
            if let token = AppDelegate.token{
                
                //设置云消息token
                Database.database().reference().child("users/\(currentUser.uid)/notificationTokens").setValue(token)
                
                //读取新的用户名等信息
                ActivityViewController.callStart += 1
                Firestore.firestore().collection("users").document(currentUser.uid).getDocument { (snap, err) in
                    if let snap = snap {
                        if let data = snap.data(){
                            if let firstName = data["firstName"] as? String,
                                let lastName = data["lastName"] as? String{
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = "\(firstName) \(lastName)"
                                changeRequest?.commitChanges(completion: nil)
                            }
                        }
                    }
                    ActivityViewController.callEnd += 1
                }
                
                
            }
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
            if let currentUser = Auth.auth().currentUser{
                try firebaseAuth.signOut()
                Database.database().reference().child("users/\(currentUser.uid)/notificationTokens").removeValue()
            }
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
                    var bagesTotal = 0
                    for doc in snap!.documents{
                        let bageID = doc.data()["bage"] as! Int
                        bages[bageID] += 1
                        bagesTotal += 1
                    }
                    for i in 0...3 {
                        AppDelegate.setBadges(notificationValue: bages[i], for: i)
                    }
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                        
                    }
                    UIApplication.shared.registerForRemoteNotifications()
                    UIApplication.shared.applicationIconBadgeNumber = bagesTotal
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
        /*
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let currentViewController = AppDelegate.getCurrentVCFrom(_rootViewController: rootViewController)
        return currentViewController
 */
        return AppDelegate.cvc
    }
    
    class func getCurrentVCFrom(_rootViewController:UIViewController?) -> UIViewController?{
        /*
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
        */
        return AppDelegate.cvc
    }
    
    
    
    class func showError(title:String, err:String, of cvc:UIViewController, handler:(()->())? = nil){
        print(title)
        print(err)
        let alert: MDCAlertController = MDCAlertController(title: title, message: err)
        alert.addAction(MDCAlertAction(title: "确定", handler: {_ in

            if let _handler = handler{
                _handler()
            }
        }))
        
        cvc.present(alert, animated: true)
    }
    
    class func showSelection(title:String, text:String, of cvc:UIViewController, handlerAgree:(()->())? = nil, handlerDismiss:(()->())? = nil){
        print(title)
        print(text)
        let alert: MDCAlertController = MDCAlertController(title: title, message: text)
        alert.addAction(MDCAlertAction(title: "确定", handler: {_ in

            if let _handler = handlerAgree{
                _handler()
            }
        }))
        alert.addAction(MDCAlertAction(title: "取消", handler: {_ in

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
    
    func getSuperUID(){
        ActivityViewController.callStart += 1
        Firestore.firestore().collection("admin").document("all").getDocument { (snap, err) in
            self.superUID = snap?.data()!["uid"] as? String
            ActivityViewController.callEnd += 1
        }
    }
    
    class func resetMainVC(with ID: String){
        print(ID)
        AppDelegate.AP().window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: ID)
        
        //为不同的 ViewCointroller 赋初始值
        if let ivc = initialViewController as? StudentTabBarController{
            AppDelegate.AP().thisUser = DataServer.studentDic[AppDelegate.AP().ds!.memberID]
            ivc.thisStudent = AppDelegate.AP().thisUser as! EFStudent
            UIView.transition(with: AppDelegate.AP().window!, duration: 0.3, options: .transitionFlipFromRight, animations: {
                AppDelegate.AP().window?.rootViewController = ivc
            })
            AppDelegate.AP().window?.makeKeyAndVisible()
            
        } else if let ivc = initialViewController as? TrainerTabBarController {
            AppDelegate.AP().thisUser = DataServer.trainerDic[AppDelegate.AP().ds!.memberID]
            ivc.thisTrainer = AppDelegate.AP().thisUser as! EFTrainer
            
            UIView.transition(with: AppDelegate.AP().window!, duration: 0.3, options: .transitionFlipFromRight, animations: {
                AppDelegate.AP().window?.rootViewController = ivc
            })
                
            
            AppDelegate.AP().window?.makeKeyAndVisible()
            
        } else {
            UIView.transition(with: AppDelegate.AP().window!, duration: 0.3, options: .transitionFlipFromRight, animations: {
                AppDelegate.AP().window?.rootViewController = initialViewController
            })
            AppDelegate.AP().window?.makeKeyAndVisible()
        }
    }
    
    class func refHandler(dic:[String:Any]) -> DocumentReference {
        return (dic["ref"]! as! DocumentReference)
    }
}

