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
    
    var thisTrainer:EFTrainer!
    var studentListToManageCourse:[EFStudent] = []
    var StudentCourseList:[String:[EFCourse]] = [:]
    
    let _refreshControl = UIRefreshControl()
    var _gesture:UIGestureRecognizer!
    @IBOutlet weak var timetableView: UIScrollView!
    var timetable:TimeTableView?
    
    
    @IBOutlet weak var titleLabel: UILabel!
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
    
    
    @IBAction func copyCourse(_ sender: Any) {
        AppDelegate.showSelection(title: "请注意", text: "将本周的课程复制至下周将会删除下周7天已有的所有课程", of: self, handlerAgree: askIfWantToCopyAllStudent, handlerDismiss: nil)
    }
    
    func askIfWantToCopyAllStudent(){
        AppDelegate.showSelection(title: "是否要复制所有人的课程", text: "请注意，所有的学生下周已有的课程将会被删除，如果只想复制该学生的课程，请按取消。复制所有的课程并不会复制多人课，如果需要复制多人课请返回上一页并选取上课的学生。", of: self, handlerAgree: copyAllCourseFromThisWeel, handlerDismiss: copyThisCourseFromThisWeel)
    }
    
    func copyThisCourseFromThisWeel(){
        var ref:[DocumentReference] = []
        for stduent in self.studentListToManageCourse{
            ref.append(stduent.ref)
        }
        self.copyCourseFromThisWeel(ref:ref)
    }
    
    func copyCourseFromThisWeel(ref:[DocumentReference]){
        ActivityViewController.callStart += 1
        Firestore.firestore().collection("course").whereField("date", isGreaterThan: Date().startOfWeek()).getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取课程时发生错误", err: err.localizedDescription, of: self)
            } else {
                for doc in snap!.documents{
                    ActivityViewController.callStart += 1
                    doc.reference.collection("trainee").getDocuments(completion: { (snap2, err2) in
                        if let err = err2 {
                            AppDelegate.showError(title: "获取课程时发生错误", err: err.localizedDescription, of: self)
                        } else {
                            if snap2!.count == ref.count{
                                var allSame = true
                                for doc2 in snap2!.documents{
                                    if let studentRef = doc2.data()["ref"] as? DocumentReference{
                                        if let sid = studentRef.parent.parent?.documentID{
                                            var contain = false
                                            for _ref in ref{
                                                if sid == _ref.documentID{
                                                    contain = true
                                                }
                                            }
                                            if contain == false {
                                                allSame = false
                                            }
                                        }
                                    }
                                }
                                if allSame {
                                    if let cMEmeberId = AppDelegate.AP().ds?.memberID{
                                        let courseRef:DocumentReference!
                                        if ref.count == 1 {
                                            courseRef = Firestore.firestore().collection("course").addDocument(data: ["type": enumService.toString(e: courseType.general), "note" : doc.data()["note"] ?? "无备注", "amount": doc.data()["amount"], "date": (Calendar.current.date(byAdding: .day, value: 7, to: (doc.data()["date"] as! Date)))])
                                        } else {
                                            courseRef = Firestore.firestore().collection("course").addDocument(data: ["type": enumService.toString(e: courseType.multiple), "note" : doc.data()["note"] ?? "无备注", "amount": doc.data()["amount"], "date": (Calendar.current.date(byAdding: .day, value: 7, to: (doc.data()["date"] as! Date)))])
                                        }
                                        for _ref in ref{
                                            let studentRecordRef = _ref.collection("CourseRecorded").addDocument(data: ["ref": courseRef, "status":enumService.toString(e: courseStatus.waitForStudent), "trainer":Firestore.firestore().collection("trainer").document(cMEmeberId)])
                                            courseRef.collection("trainee").addDocument(data: ["ref" : studentRecordRef])
                                        }
                                    }
                                }
                            }
                        }
                        ActivityViewController.callEnd += 1
                    })
                }
            }
            ActivityViewController.callEnd += 1
        }

        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        ActivityViewController.callStart += 1
        Firestore.firestore().collection("course").whereField("Date", isLessThan: nextWeek!.endOfWeek()).whereField("Date", isGreaterThan: nextWeek!.startOfWeek()).getDocuments { (snap, err) in
            if let err = err {
                AppDelegate.showError(title: "获取课程时发生错误", err: err.localizedDescription, of: self)
            } else {
                for doc in snap!.documents{
                    ActivityViewController.callStart += 1
                    doc.reference.collection("trainee").getDocuments(completion: { (snap2, err2) in
                        if let err = err2 {
                            AppDelegate.showError(title: "获取课程时发生错误", err: err.localizedDescription, of: self)
                        } else {
                            if snap2!.count == ref.count{
                                var allSame = true
                                for doc2 in snap2!.documents{
                                    if let studentRef = doc2.data()["ref"] as? DocumentReference{
                                        if let sid = studentRef.parent.parent?.documentID{
                                            var contain = false
                                            for _ref in ref{
                                                if sid == _ref.documentID{
                                                    contain = true
                                                }
                                            }
                                            if contain == false {
                                                allSame = false
                                            }
                                        }
                                    }
                                }
                                if allSame {
                                    for doc in snap!.documents{
                                        (doc.data()["Student"] as! DocumentReference).delete()
                                        doc.reference.delete()
                                    }
                                }
                            }
                        }
                        ActivityViewController.callEnd += 1
                    })
                }
            }
            ActivityViewController.callEnd += 1
        }
        
    }
    
    func copyAllCourseFromThisWeel(){
        for studentsRef in AppDelegate.AP().studentList{
            self.copyCourseFromThisWeel(ref: [studentsRef])
        }
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
        if let existTimetable = timetable{
            existTimetable.removeFromSuperview()
        }
        timetable = TimeTableView(frame: CGRect(x: 0, y: 0, width: timetableView.frame.width, height: timetableView.frame.height))
        let calendar = Calendar.current
        let nextweek = calendar.date(byAdding: .day, value: 7, to: Date())
        TimeTable.makeTimeTabel(on: timetable!, with: StudentCourseList, startoftheweek: (nextweek?.startOfWeek())!, handeler: self.resizeViews)
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
        ActivityViewController.isViewEnable = true
        if self.studentListToManageCourse.count == 1{
            titleLabel.text = "添加单人课"
        } else {
            titleLabel.text = "添加多人课"
        }
        let calendar = Calendar.current
        let nextday = calendar.date(byAdding: .day, value: 1, to: Date())
        
        self._gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(_gesture)
        courseDatePicker.minimumDate = Date()
        
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

        } else {
            noCourseLabel.isHidden = true

            self.timetableView.contentSize = CGSize(width: self.view.frame.width, height: maxHeight)
            self.timetable?.frame = CGRect(x: (self.timetable?.frame.minX)!, y: (self.timetable?.frame.minY)!, width: self.view.frame.width, height: maxHeight)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func 用户按了填加这个没有最大的(_ sender: Any) {
        EFStudent.addCourse(of: self.studentListToManageCourse, date: self.courseDatePicker.date, amount: 准备增加, note: courseNoteField.text ?? "无备注", trainer: thisTrainer.ref, status: courseStatus.waitForStudent)
        for student in studentListToManageCourse{
            student.download()
        }
        _ = self.navigationController?.popViewController(animated: true)
        if let cvc = self.navigationController?.topViewController as? refreshableVC {
            cvc.refresh()
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
