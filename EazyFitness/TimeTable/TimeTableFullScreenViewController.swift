//
//  TimeTableFullScreenViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/1.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class TimeTableFullScreenViewController: DefaultViewController, UIScrollViewDelegate {
    var showDate:Date!
    var StudentCourseList: [String: [ClassObj]]!
    let _refreshControl = UIRefreshControl()
    @IBOutlet weak var noCourseLabel: UIView!
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
    
    override func refresh() {
        self.startLoading()
        noCourseLabel.isHidden = true
        if let existTimetable = timetable{
            existTimetable.removeFromSuperview()
        }
        timetable = TimeTableView(frame: CGRect(x: 0, y: 0, width: timetableView.frame.width, height: timetableView.frame.height))
        TimeTable.makeTimeTabel(on: timetable!, with: self.StudentCourseList, startoftheweek: showDate.startOfWeek(), handeler: self.resizeViews)
        timetableView.addSubview(timetable!)
    }
    
    override func viewDidLoad() {
        noCourseLabel.isHidden = true
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
            noCourseLabel.isHidden = false
        } else {
            noCourseLabel.isHidden = true
            self.endLoading()
            self.timetableView.contentSize = CGSize(width: self.view.frame.width, height: maxHeight)
            self.timetable?.frame = CGRect(x: (self.timetable?.frame.minX)!, y: (self.timetable?.frame.minY)!, width: self.view.frame.width, height: maxHeight)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? TimeTableFullScreenViewController{
            dvc.showDate = Calendar.current.date(byAdding: .day, value: 7, to: self.showDate)
            if self.title == "本周"{
                dvc.title = "下周"
            } else {
                dvc.title = "下\(self.title ?? "周")"
            }
            dvc.StudentCourseList = self.StudentCourseList
        }
    }

}

//
//  TimeTableViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/29.
//  Copyright © 2018年 luke. All rights reserved.
//
