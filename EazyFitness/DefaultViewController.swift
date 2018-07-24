//
//  DefaultViewController.swift
//  Cardigin
//
//  Created by Luke on 2018/2/1.
//  Copyright © 2018年 cardigin. All rights reserved.
//

import UIKit
import MaterialComponents
extension UIView{
    var isVisible:Bool {
        set {
            self.isHidden = (newValue == false)
        }
        get {
            return (self.isHidden == false)
        }
    }
}

class DefaultViewController: UIViewController, refreshableVC {
    func refresh() {
        
    }
    
    func reload() {
        
    }
    
    
    lazy var timer = Timer()
    override func viewDidLoad() {

        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default //user global variable
        self.navigationController?.navigationBar.tintColor = HexColor.Pirmary //user global variable
        tabBarController?.tabBar.barTintColor = UIColor.white
        tabBarController?.tabBar.tintColor = HexColor.Pirmary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        AppDelegate.cvc = self
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
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

class DefaultCollectionViewController: UICollectionViewController, refreshableVC {
    func refresh() {
    }
    
    func reload() {
        self.collectionView?.reloadData()
    }
    
    
    var loadingView:UIVisualEffectView!
    var loadingIndicator:UIActivityIndicatorView!
    
    
    lazy var timer = Timer()
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default //user global variable
        self.navigationController?.navigationBar.tintColor = HexColor.Pirmary //user global variable
        tabBarController?.tabBar.barTintColor = UIColor.white
        tabBarController?.tabBar.tintColor = HexColor.Pirmary
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        AppDelegate.cvc = self
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
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

class DefaultTableViewController: UITableViewController, refreshableVC {
    func refresh() {
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    
    var loadingView:UIVisualEffectView!
    var loadingIndicator:UIActivityIndicatorView!
    
    
    lazy var timer = Timer()
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default //user global variable
        self.navigationController?.navigationBar.tintColor = HexColor.Pirmary //user global variable
        tabBarController?.tabBar.barTintColor = UIColor.white
        tabBarController?.tabBar.tintColor = HexColor.Pirmary
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let message = MDCSnackbarMessage()
        AppDelegate.cvc = self
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
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
