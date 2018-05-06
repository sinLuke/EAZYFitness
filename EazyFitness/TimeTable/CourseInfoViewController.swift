//
//  CourseInfoViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/1.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class CourseInfoViewController: DefaultViewController, UIScrollViewDelegate {

    @IBOutlet weak var noCourseLabel: UIView!
    var collectionRef: [String: CollectionReference]!
    var 用来加课的refrence: CollectionReference!
    let _refreshControl = UIRefreshControl()
    var _gesture:UIGestureRecognizer!
    @IBOutlet weak var timetableView: UIScrollView!
    var timetable:TimeTableView?
    @IBOutlet weak var courseNoteField: UITextField!
    @IBOutlet weak var courseAmount: UILabel!
    @IBOutlet weak var courseDatePicker: UIDatePicker!
    @IBOutlet weak var courseDate: UILabel!
    
    var 准备增加:Int = 3
    
    @IBOutlet weak var viewContainer: UIView!
    var PickedDate:Date?
    
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
        let calendar = Calendar.current
        let nextweek = calendar.date(byAdding: .day, value: 7, to: Date())
        TimeTable.makeTimeTable(on: timetable!, withRef: collectionRef, startoftheweek: (nextweek?.startOfWeek())!, handeler: self.resizeViews)
        timetableView.addSubview(timetable!)
    }
    
    @IBAction func datePicked(_ sender: Any) {
        if let datepicker = sender as? UIDatePicker{
            PickedDate = datepicker.date
        } else {
            PickedDate = courseDatePicker.date
        }
        let dateformater = DateFormatter()
        dateformater.dateStyle = .medium
        dateformater.timeStyle = .none
        let timeformater = DateFormatter()
        timeformater.dateStyle = .none
        timeformater.timeStyle = .short
        self.courseDate.text = "\(dateformater.string(from: PickedDate!)) \(PickedDate!.getThisWeekDayLongName()) \(timeformater.string(from: PickedDate!))"
    }
    
    @objc func dismissKeyboard(){
        self.courseNoteField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.courseNoteField.resignFirstResponder()
        if self.courseNoteField.text == ""{
            self.courseNoteField.isEnabled = false
        } else {
            self.courseNoteField.isEnabled = true
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendar = Calendar.current
        let nextday = calendar.date(byAdding: .day, value: 1, to: Date())
        
        self._gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(_gesture)
        courseDatePicker.minimumDate = nextday
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.timetableView.refreshControl = self._refreshControl
        self.timetableView.addSubview(self._refreshControl)
        
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOpacity = 0.15
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: -1)
        viewContainer.layer.shadowRadius = 3
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    
    
    func resizeViews(maxHeight:CGFloat)->(){
        print(maxHeight)
        if maxHeight == 0{
            noCourseLabel.isHidden = false
            self.view.bringSubview(toFront: noCourseLabel)
            self.endLoading()
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
    
    
    @IBAction func 用户按了填加这个没有最大的(_ sender: Any) {
        if let cMEmeberId = AppDelegate.AP().currentMemberID{
            用来加课的refrence.addDocument(data: ["Note" : courseNoteField.text ?? "无备注", "Amount": 准备增加, "Date": self.courseDatePicker.date, "Approved":false, "Record":false, "trainer":cMEmeberId])
            self.refresh()
        } else {
            AppDelegate.showError(title: "添加课程时遇到错误", err: "无法获取教练ID")
        }
    }
    
    @IBAction func 减少(_ sender: Any) {
        准备增加 = 准备增加 - 1
        if 准备增加 == 0 {
            减少按钮.isHidden = true
        }
        courseAmount.text = prepareCourseNumber(准备增加)
    }
    
    @IBAction func 增加(_ sender: Any) {
        准备增加 = 准备增加 + 1
        courseAmount.text = prepareCourseNumber(准备增加)
    }
    
    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    
    @IBOutlet weak var 增加按钮: UIButton!
    @IBOutlet weak var 减少按钮: UIButton!
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
