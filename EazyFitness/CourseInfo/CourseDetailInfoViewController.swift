//
//  CourseDetailInfoViewController
//  EazyFitness
//
//  Created by Luke on 2018-07-05.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

class CourseDetailInfoViewController: DefaultViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    let _refreshControl = UIRefreshControl()
    var thisCourse: EFCourse!
    var thisStudentCourse: EFStudentCourse!
    
    var isEditable = false
    var isDeletable = false
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getTranerName()
        
        let title = NSLocalizedString("下拉返回", comment: "下拉返回")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.tableView.refreshControl = self._refreshControl
        self.tableView.addSubview(self._refreshControl)
        
        self.isEditable = false
        self.isDeletable = false
        
        if let ds = AppDelegate.AP().ds {
            if ds.usergroup == .admin  {
                if ds.region == .All {
                    self.isEditable = true
                    self.isDeletable = true
                } else {
                    self.isEditable = true
                    self.isDeletable = true
                }
            } else if ds.usergroup == .trainer {
                if Calendar.current.date(byAdding: .day, value: 1, to: Date())! < thisCourse.date {
                    self.isEditable = true
                    self.isDeletable = true
                } else {
                    self.isEditable = false
                    self.isDeletable = false
                }
            }
        }

        self.reload()
        
        // Do any additional setup after loading the view.
    }
    
    var fullName = ""
    
    func getTranerName() {
        thisCourse.trainerRef?.getDocument(completion: { (snap, err) in
            if let snap = snap {
                if let firstName = snap.data()?["firstName"] as? String, let lastName = snap.data()?["lastName"] as? String{
                    self.fullName = "\(firstName) \(lastName)"
                }
            }
            self.reload()
        })
        if let trainreRef = thisCourse.trainerRef {
            let newtrainer = EFTrainer.setTrainer(with: trainreRef)
        }
    }
    
    override func reload() {
        /*if thisCourse == nil {
            if let courseREF = thisStudentCourse.courseRef{
                if let thisCourse = DataServer.courseDic[courseREF.documentID]{
                    self.thisCourse = thisCourse
                    thisCourse.download()
                    return
                } else {
                    self.dismiss(animated: true) {
                        DataServer.courseDic[courseREF.documentID] = EFCourse.setCourse(with: courseREF)
                        AppDelegate.showError(title: "无法读取课程", err: "请稍后重试")
                    }
                }
            }
            if thisStudentCourse == nil {
                self.dismiss(animated: true) {
                    AppDelegate.showError(title: "无法读取课程", err: "数据为空")
                }
            } else {
                
            }
        }*/
        self.tableView.reloadData()
    }
    
    func prepareCourseNumber(_ int:Int) -> String{
        let float = Float(int)/2.0
        if int%2 == 0{
            return String(format: "%.0f", float)
        } else {
            return String(float)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var a = 2
        if self.isDeletable {
            a = a + 1
        }
        if self.isEditable {
            a = a + 1
        }
        return a
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return thisCourse?.traineeRef.count ?? 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "课程信息"
        } else if section == 1{
            return "学生信息"
        } else {
            return ""
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "时间"
                cell.detailTextLabel?.text = thisCourse.date.descriptDate()
            case 1:
                cell.textLabel?.text = "课时长度"
                cell.detailTextLabel?.text = "\(self.prepareCourseNumber(thisCourse.amount)) 课时"
            case 2:
                cell.textLabel?.text = "备注"
                cell.detailTextLabel?.text = thisCourse.note ?? "无备注"
            default:
                cell.textLabel?.text = "教练"
                cell.detailTextLabel?.text = self.fullName
            }
        case 1:
            let theTraineeRef = thisCourse.traineeRef[indexPath.row]
            if let theStudent = DataServer.studentDic[theTraineeRef.documentID]{
                cell.textLabel?.text = theStudent.name
                
                if let thisStudentCourse = theStudent.courseDic[thisCourse.ref.documentID]{
                    cell.detailTextLabel?.text = enumService.toDescription(e: thisStudentCourse.status)
                    cell.detailTextLabel?.textColor = enumService.toColor(e: thisStudentCourse.status)
                } else {
                    cell.detailTextLabel?.text = "状态未知"
                }
                
            } else {
                cell.textLabel?.text = "学生未知"
                cell.detailTextLabel?.text = "状态未知"
            }
        case 2:
            if self.isEditable {
                cell.textLabel?.text = "更该课程时间"
                cell.detailTextLabel?.text = ""
                cell.textLabel?.textColor = UIColor.red
            } else {
                cell.textLabel?.text = "删除该课程"
                cell.detailTextLabel?.text = ""
                cell.textLabel?.textColor = UIColor.red
            }
        default:
            cell.textLabel?.text = "删除该课程"
            cell.detailTextLabel?.text = ""
            cell.textLabel?.textColor = UIColor.red
        }
        return cell
        
            
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            if self.isEditable {
                if let course = self.thisCourse {
                    let timeSelectorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TimeSelectorViewController") as! TimeSelectorViewController
                    timeSelectorVC.TimeDate = course.date
                    timeSelectorVC.thisCourse = course
                    self.present(timeSelectorVC, animated: true, completion: nil)
                }
            } else {
                
                self.dismiss(animated: true, completion: nil)
                thisCourse.delete()
            }
        default:
            
            self.dismiss(animated: true, completion: nil)
            thisCourse.delete()
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
