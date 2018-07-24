//
//  trainerCourseVC.swift
//  EazyFitness
//
//  Created by Luke on 2018-06-08.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit
import MaterialComponents
import Firebase

enum trainerCourseVCMode {
    case thisCourse
    case nextCourse
}

class trainerCourseVC: DefaultCollectionViewController, UICollectionViewDelegateFlowLayout, QRCodeReaderViewControllerDelegate {
    
    var thisTrainer:EFTrainer!
    
    let _refreshControl = UIRefreshControl()
    
    var nextCourse:[String: EFCourse] = [:]
    var thisCourse:[String: EFCourse] = [:]
    var studentCourseForCourse:[String: [EFStudentCourse]] = [:]
    
    @IBOutlet weak var scanButton: UIBarButtonItem!
    var thisMode:trainerCourseVCMode = .thisCourse {
        didSet {
            scanButton.isEnabled = thisMode == .thisCourse
        }
    }
    
    override func refresh() {
        thisTrainer.download()
        self.reload()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.refresh()
    }
    
    override func reload() {
        studentCourseForCourse = [:]
        self.title = (thisMode == .thisCourse ? "当前课程" : "之后的课程")
        
        for theStudentRef in self.thisTrainer.trainee{
            if let thisStudent = DataServer.studentDic[theStudentRef.documentID]{
                for efStudentCourse in thisStudent.courseDic.values{
                    efStudentCourse.parent = thisStudent.ref.documentID
                    //通过课程引用取得课程
                    if let theCourse = DataServer.courseDic[efStudentCourse.courseRef.documentID]{
                        
                        if self.studentCourseForCourse[theCourse.ref.documentID] == nil {
                            self.studentCourseForCourse[theCourse.ref.documentID] = [efStudentCourse]
                        } else {
                            self.studentCourseForCourse[theCourse.ref.documentID]?.append(efStudentCourse)
                        }
                        
                        //如果课程发生在未来
                        if theCourse.date > Date(){
                            
                            //获取下一节课
                            //比较时间并将最接近当前时间的课程放入 self.nextCourse
                            if enumService.toMultiCourseStataus(list: theCourse.traineesStatus) != .decline{
                                self.nextCourse[theCourse.ref.documentID] = theCourse
                            }
                        } else {
                            //获取当前课程
                            //取得 theCourse 结束的时间
                            if let theCourseEndTime = Calendar.current.date(byAdding: .minute, value: 30*theCourse.amount, to: theCourse.date){
                                //如果当前时间在theCourse开始和结束之间，则放入 self.thisCourse
                                let statusList = theCourse.traineesStatus
                                let multiStatus = enumService.toMultiCourseStataus(list: statusList)
                                if theCourse.date < Date() && Date() < theCourseEndTime && enumService.ifCourseValid(s: multiStatus) {
                                    self.thisCourse[theCourse.ref.documentID] = theCourse
                                }
                            }
                        }
                    } else {
                        let message = MDCSnackbarMessage()
                        message.text = "读取课\(efStudentCourse.courseRef.documentID)程发生错误"
                        MDCSnackbarManager.show(message)
                    }
                }
            }
        }
        
        self.collectionView?.reloadData()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        let title = NSLocalizedString("下拉刷新", comment: "下拉刷新")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.collectionView!.refreshControl = self._refreshControl
        self.collectionView!.addSubview(self._refreshControl)
        
        collectionView?.register(UINib.init(nibName: "EFViewHeaderCellWithTrainerCourse", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "EFViewHeaderCellWithTrainerCourse")
        
        collectionView?.register(UINib.init(nibName: "EFViewCellWithTrainerCourseStudentStatus", bundle: nil), forCellWithReuseIdentifier: "EFViewCellWithTrainerCourseStudentStatus")
        
        if let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.estimatedItemSize = CGSize(width: (collectionView?.frame.width)! - 2*12 , height: 300)
            flowlayout.sectionHeadersPinToVisibleBounds = true
        }

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        /*
         if collectionView.numberOfItems(inSection: section) == 0{
         return CGSize(width: 0, height: 0)
         } else {
         
         }
         */
        return CGSize(width: (collectionView.frame.width) - 2*12 , height: 222)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (thisMode == .thisCourse ? thisCourse.count : nextCourse.count)
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return (thisMode == .thisCourse ?
            thisCourse.values.sorted(by: { (a, b) -> Bool in
            return a.date < b.date
        })[section].traineeRef.count
            :
            nextCourse.values.sorted(by: { (a, b) -> Bool in
            return a.date < b.date
        })[section].traineeRef.count)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EFViewHeaderCellWithTrainerCourse", for: indexPath) as! EFViewHeaderCellWithTrainerCourse
        
        let theCourse = (thisMode == .thisCourse ?
            thisCourse.values.sorted(by: { (a, b) -> Bool in
                return a.date < b.date
            })[indexPath.section]
            :
            nextCourse.values.sorted(by: { (a, b) -> Bool in
                return a.date < b.date
            })[indexPath.section]
        )
        cell.DateLabel.text = theCourse.date.DateString
        cell.TimeLabel.text = theCourse.date.TimeString
        cell.TextLabel.text = theCourse.note
        cell.BarRightLabel.text = enumService.toDescription(e: enumService.toMultiCourseStataus(list: theCourse.traineesStatus))
        cell.TitleLabel.text = (thisMode == .thisCourse ? "当前上课" : "\(theCourse.date.descriptDate())的课")
        cell.TitleBarColor = enumService.toColor(d: enumService.toMultiCourseStataus(list: theCourse.traineesStatus))
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EFViewCellWithTrainerCourseStudentStatus", for: indexPath) as! EFViewCellWithTrainerCourseStudentStatus
        cell.vc = self
        cell.reportBtn.isHidden = thisMode == .nextCourse
        let theCourse = (thisMode == .thisCourse ?
            thisCourse.values.sorted(by: { (a, b) -> Bool in
                return a.date < b.date
            })[indexPath.section]
            :
            nextCourse.values.sorted(by: { (a, b) -> Bool in
                return a.date < b.date
            })[indexPath.section]
        )
        if let studentCourse = studentCourseForCourse[theCourse.ref.documentID]{
            cell.reportBtn.isHidden = false
            cell.studentCourse = studentCourse[indexPath.row]
            cell.StatusFootNote.text = enumService.toDescription(e: studentCourse[indexPath.row].status)
            cell.StatusLabel.text = (DataServer.studentDic[studentCourse[indexPath.row].parent]?.name ?? "无法找到该学生")
            cell.statusCircleColor = enumService.toColor(e: studentCourse[indexPath.row].status)
            if thisMode == .thisCourse && studentCourse[indexPath.row].status == .approved {
                cell.statusCircleColor = nil
                cell.StatusFootNote.text = "学生尚未扫码"
            }
            if thisMode == .nextCourse && studentCourse[indexPath.row].status == .waitForStudent {
                cell.statusCircleColor = nil
            }
        } else {
            cell.reportBtn.isHidden = true
        }
        
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    //scan QRCode
    @IBAction func scanBtn(_ sender: Any) {
        if thisMode == .thisCourse {
            scan.scanCard(_vc: self)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
        
        let charset = CharacterSet(charactersIn: ".#$[]")
        if result.value.rangeOfCharacter(from: charset) != nil {

            AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0101#)", of: self)
        } else {
            ActivityViewController.callStart += 1
            Firestore.firestore().collection("QRCODE").document(result.value).getDocument { (snap, err) in
                if let err = err{

                    AppDelegate.showError(title: "未知错误", err: err.localizedDescription, of: self)
                } else {
                    if let doc = snap?.data(){
                        if let _numberValue = doc["MemberID"] as? Int{
                            var i = 0
                            print("self.thisCourse.values")
                            print(self.studentCourseForCourse)
                            for thisOneCourse in self.thisCourse.values {
                                
                                if let thisCourseStudentCourseList = self.studentCourseForCourse[thisOneCourse.ref.documentID]{
                                    print("thisCourseStudentCourseList")
                                    print(thisCourseStudentCourseList)
                                    for studentCourse in thisCourseStudentCourseList {
                                        if studentCourse.parent == "\(_numberValue)"{
                                            i += 1
                                            print(i)
                                            self.recordACourse(thatStudentCourse: studentCourse , thatCourseRef: thisOneCourse.ref)
                                            
                                        }
                                    }
                                }
                            }
                            
                            if i == 0 {
                                AppDelegate.showError(title: "录入失败", err: "没有找到与之对应的学生", of: self, handler: self.refresh)
                            } else {
                                AppDelegate.showError(title: "录入成功", err: "已成功录入\(i)项记录", of: self, handler: self.refresh)
                            }
                            
                        } else {

                            AppDelegate.showError(title: "二维码无效", err: "请对准 EAZY Fitness® 会员卡背面的二维码重试(#0103#)", of: self)
                        }
                    }
                }
                ActivityViewController.callEnd += 1
            }
        }
    }
    
    func recordACourse(thatStudentCourse:EFStudentCourse, thatCourseRef:DocumentReference){
        
        if thatStudentCourse.ready{
            thatStudentCourse.status = .scaned
            thisTrainer.finishACourse(By: thatCourseRef)
            thatStudentCourse.upload {
                //self.refresh()
            }
        } else {
            AppDelegate.showError(title: "数据错误", err: "请稍后再试")
            self.refresh()
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        dismiss(animated: true, completion: nil)
    }

}
