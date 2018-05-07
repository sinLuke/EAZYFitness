//
//  WelcomeViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/24.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import WebKit

class WelcomeViewController: DefaultViewController, UIWebViewDelegate {

    @IBOutlet weak var homepage: UIWebView!
    
    var ref:DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url:URL = URL(string:"https://www.eazy.fitness/")!
        let request:URLRequest = URLRequest(url:url)
        homepage.loadRequest(request)
        homepage.scalesPageToFit = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.startLoading()
        self.view.isUserInteractionEnabled = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.endLoading()
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
