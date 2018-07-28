//
//  ActivityViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/7/23.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import UICircularProgressRing
class ActivityViewController: UIViewController {
    
    @IBOutlet weak var circle: UICircularProgressRing!
    static var started:Bool {
        set { (newValue)
            
            if newValue != ActivityViewController._started {
                ActivityViewController._started = newValue
                if newValue {
                    ActivityViewController.startLoading()
                } else {
                    ActivityViewController.endLoading()
                }
            }
        }
        get {
            return ActivityViewController._started
        }
    }
    
    static var _started = false
    
    static var shared: ActivityViewController?
    
    static var callStart = 0{
        didSet {
            print("正在载入：\(ActivityViewController.callEnd)/\(ActivityViewController.callStart)")
            if ActivityViewController.callStart != 0 {
                ActivityViewController.updateLabel()
            }
        }
    }
    static var callEnd = 0{
        didSet {
            print("正在载入：\(ActivityViewController.callEnd)/\(ActivityViewController.callStart)")
            if ActivityViewController.callEnd != 0 {
                ActivityViewController.updateLabel()
            }
        }
    }

    @IBOutlet weak var baseView: UIView!
    //@IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIVisualEffectView!
    
    var activityLabelString = "" {
        didSet {
            activityLabel.text = activityLabelString
        //labelBackgroundView.isHidden = activityLabelString == ""
            
        }
    }
    @IBOutlet weak var stopLoading: UIButton!
    
    @IBAction func stopLoadingBtn(_ sender: Any) {
        ActivityViewController.started = false
        self.dismiss(animated: false, completion: nil)
    }
    
    class func updateLabel(){
        if ActivityViewController.callStart != ActivityViewController.callEnd {
            ActivityViewController.started = true
            let progressValue = Int(Float(ActivityViewController.callEnd)/Float(ActivityViewController.callStart)*100)
            ActivityViewController.shared?.circle.startProgress(to: UICircularProgressRing.ProgressValue(progressValue), duration: Double(progressValue)*0.005)
            ActivityViewController.shared?.activityLabelString = "正在载入：%\(progressValue) (\(ActivityViewController.callEnd)/\(ActivityViewController.callStart))"
        } else {
            ActivityViewController.started = false
            ActivityViewController.callStart = 0
            ActivityViewController.callEnd = 0
            ActivityViewController.endLoading()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityLabel.text = activityLabelString
        baseView.layer.cornerRadius = 16
        labelBackgroundView.layer.cornerRadius = 4
        labelBackgroundView.clipsToBounds = true
        baseView.clipsToBounds = true
        
        circle.maxValue = 100
        
        //activityView.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func startLoading(){
        shared?.dismiss(animated: false, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let shared = storyboard.instantiateViewController(withIdentifier: "activity") as? ActivityViewController{
            ActivityViewController.shared = shared
            shared.view.backgroundColor = .clear
            shared.modalPresentationStyle = .overCurrentContext
            AppDelegate.cvc?.present(shared, animated: false, completion: nil)
        }
    }
    
    class func endLoading(){
        ActivityViewController.shared?.dismiss(animated: false, completion: nil)
        if let vc = AppDelegate.getTopViewController() as? ActivityViewController{
            vc.dismiss(animated: false, completion: nil)
        }
        AppDelegate.reload()
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
