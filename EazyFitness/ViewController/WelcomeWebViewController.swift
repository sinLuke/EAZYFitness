//
//  WelcomeWebViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018-07-27.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

class WelcomeWebViewController: UIViewController {
    
    var url: URL!
    var urlDidLoad: URL?
    @IBOutlet weak var webView: UIWebView!

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let request:URLRequest = URLRequest(url:url)
        webView.loadRequest(request)
        webView.scalesPageToFit = true
        // Do any additional setup after loading the view.
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        AppDelegate.showError(title: "网页加载时出现问题", err: error.localizedDescription)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.absoluteURL == url.absoluteURL {
            return true
        } else {
            self.performSegue(withIdentifier: "loadnew", sender: self)
            return false
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WelcomeWebViewController {
            vc.url = urlDidLoad
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
