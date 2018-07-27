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
    
    var myRequestedUrl: URL?
    var myLoadedUrl: URL?
    
    var urlDidLoad: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homepage.delegate = self
        self.home()
        // Do any additional setup after loading the view.
    }
    
    func home(){
        let url:URL = URL(string:"https://yinluke9.wixsite.com/eazyfitnessapp")!
        let request:URLRequest = URLRequest(url:url)
        homepage.loadRequest(request)
        homepage.scalesPageToFit = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        AppDelegate.showError(title: "网页加载时出现问题", err: error.localizedDescription)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.absoluteURL == URL(string:"https://yinluke9.wixsite.com/eazyfitnessapp")!.absoluteURL {
            return true
        } else {
            urlDidLoad = request.url?.absoluteURL
            self.performSegue(withIdentifier: "show", sender: self)
            return false
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //ActivityViewController.startLoading()
        myRequestedUrl = webView.request?.mainDocumentURL
        
        print("webViewDidStartLoad: \(myRequestedUrl)")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //ActivityViewController.endLoading()
        myLoadedUrl = webView.request?.mainDocumentURL
        print("webViewDidFinishLoad: \(myLoadedUrl)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UINavigationController {
            if let dvc = vc.topViewController as? WelcomeWebViewController {
                dvc.url = self.urlDidLoad?.absoluteURL
            }
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
