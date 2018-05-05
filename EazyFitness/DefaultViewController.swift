//
//  DefaultViewController.swift
//  Cardigin
//
//  Created by Luke on 2018/2/1.
//  Copyright © 2018年 cardigin. All rights reserved.
//

import UIKit

class DefaultViewController: UIViewController {
    
    var loadingView:UIVisualEffectView!
    var loadingIndicator:UIActivityIndicatorView!
    
    
    lazy var timer = Timer()
    override func viewDidLoad() {
        loadingView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        loadingView.frame = CGRect(x: self.view.frame.width/2-50, y: self.view.frame.height/2-50, width: 100, height: 100)
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadingIndicator.frame = CGRect(x: self.view.frame.width/2-20, y: self.view.frame.height/2-20, width: 40, height: 40)
        loadingView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        
        loadingView.layer.cornerRadius = 10
        loadingView.clipsToBounds = true
        loadingView.isHidden = true

        super.viewDidLoad()
    }
    
    
    func startLoading() -> (){
        
        loadingView.isHidden = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        self.view.addSubview(loadingView)
        self.view.addSubview(loadingIndicator)
    }
    
    func endLoading() -> (){
        loadingView.isHidden = true
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.loadingView.removeFromSuperview()
        self.loadingIndicator.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class DefaultCollectionViewController: UICollectionViewController {
    
    var loadingView:UIVisualEffectView!
    var loadingIndicator:UIActivityIndicatorView!
    
    
    lazy var timer = Timer()
    override func viewDidLoad() {
        loadingView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        loadingView.frame = CGRect(x: self.view.frame.width/2-50, y: self.view.frame.height/2-50, width: 100, height: 100)
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadingIndicator.frame = CGRect(x: self.view.frame.width/2-20, y: self.view.frame.height/2-20, width: 40, height: 40)
        loadingView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        
        loadingView.layer.cornerRadius = 10
        loadingView.clipsToBounds = true
        loadingView.isHidden = true
        
        super.viewDidLoad()
    }
    
    
    func startLoading() -> (){
        
        loadingView.isHidden = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        self.view.addSubview(loadingView)
        self.view.addSubview(loadingIndicator)
    }
    
    func endLoading() -> (){
        loadingView.isHidden = true
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.loadingView.removeFromSuperview()
        self.loadingIndicator.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class DefaultTableViewController: UITableViewController {
    
    var loadingView:UIVisualEffectView!
    var loadingIndicator:UIActivityIndicatorView!
    
    
    lazy var timer = Timer()
    override func viewDidLoad() {
        loadingView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        loadingView.frame = CGRect(x: self.view.frame.width/2-50, y: self.view.frame.height/2-50, width: 100, height: 100)
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadingIndicator.frame = CGRect(x: self.view.frame.width/2-20, y: self.view.frame.height/2-20, width: 40, height: 40)
        loadingView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        
        loadingView.layer.cornerRadius = 10
        loadingView.clipsToBounds = true
        loadingView.isHidden = true
        
        super.viewDidLoad()
    }
    
    
    func startLoading() -> (){
        
        loadingView.isHidden = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        self.view.addSubview(loadingView)
        self.view.addSubview(loadingIndicator)
    }
    
    func endLoading() -> (){
        loadingView.isHidden = true
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.loadingView.removeFromSuperview()
        self.loadingIndicator.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
