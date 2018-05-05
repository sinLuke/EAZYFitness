//
//  CourseInfoViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/1.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class CourseInfoViewController: DefaultViewController {

    var collectionRef: [String: CollectionReference]!
    let _refreshControl = UIRefreshControl()
    @IBOutlet weak var timetableView: UIScrollView!
    var timetable:TimeTableView?
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let theTop = timetable?.topView{
            timetable?.bringSubview(toFront: theTop)
            if scrollView.contentOffset.y >= 0{
                theTop.layer.shadowColor = UIColor.black.cgColor
                theTop.layer.shadowOpacity = 0.15
                theTop.layer.shadowOffset = CGSize(width: 0, height: 1)
                theTop.layer.shadowRadius = 3
                if scrollView.contentOffset.y != 0{
                    theTop.clipsToBounds = false
                } else {
                    theTop.clipsToBounds = true
                }
                theTop.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: theTop.frame.width, height: theTop.frame.height)
                
            }else {
                theTop.clipsToBounds = true
                theTop.frame = CGRect(x: 0, y: 0, width: theTop.frame.width, height: theTop.frame.height)
            }
        }
    }
    
    func refresh() {
        self.startLoading()
        if let existTimetable = timetable{
            existTimetable.removeFromSuperview()
        }
        timetable = TimeTableView(frame: CGRect(x: 0, y: 0, width: timetableView.frame.width, height: timetableView.frame.height))
        TimeTable.makeTimeTable(on: timetable!, withRef: collectionRef, handeler: self.resizeViews)
        timetableView.addSubview(timetable!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.timetableView.refreshControl = self._refreshControl
        self.timetableView.addSubview(self._refreshControl)
        
        
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    
    
    func resizeViews(maxHeight:CGFloat)->(){
        if maxHeight == 0{
            self.endLoading()
        } else {
            self.endLoading()
            self.timetableView.contentSize = CGSize(width: self.view.frame.width, height: maxHeight)
            self.timetable?.frame = CGRect(x: (self.timetable?.frame.minX)!, y: (self.timetable?.frame.minY)!, width: self.view.frame.width, height: maxHeight)
        }
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
