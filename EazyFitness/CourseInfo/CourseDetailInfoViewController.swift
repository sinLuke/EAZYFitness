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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        refreshControl.endRefreshing()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = NSLocalizedString("下拉返回", comment: "下拉返回")
        _refreshControl.attributedTitle = NSAttributedString(string: title)
        _refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        _refreshControl.tintColor = HexColor.Pirmary
        
        self.tableView.refreshControl = self._refreshControl
        self.tableView.addSubview(self._refreshControl)
        
        

        // Do any additional setup after loading the view.
    }
    
    override func reload() {
        if thisCourse == nil {
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
        }
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return thisCourse?.traineeRef.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "课程信息"
        } else {
            return "学生信息"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = "时间"
                cell?.detailTextLabel?.text = thisCourse.date.descriptDate()
            case 1:
                cell?.textLabel?.text = "课时长度"
                cell?.detailTextLabel?.text = "\(self.prepareCourseNumber(thisCourse.amount)) 课时"
            case 2:
                cell?.textLabel?.text = "备注"
                cell?.detailTextLabel?.text = thisCourse.note ?? "无备注"
            default:
                cell?.textLabel?.text = "教练"
                thisCourse.trainerRef?.getDocument(completion: { (snap, err) in
                    if let snap = snap {
                        if let firstName = snap.data()?["firstName"] as? String, let lastName = snap.data()?["lastName"] as? String{
                            cell?.detailTextLabel?.text = "\(firstName) \(lastName)"
                        }
                    }
                })
                
                
                if let trainreRef = thisCourse.trainerRef {
                    
                    let newtrainer = EFTrainer.setTrainer(with: trainreRef)
                    newtrainer.download()
                    DataServer.trainerDic[trainreRef.documentID] = newtrainer
                    
                    cell?.detailTextLabel?.text = newtrainer.name
                }
            }
        } else {
            let theTraineeRef = thisCourse.traineeRef[indexPath.row]
            if let theStudent = DataServer.studentDic[theTraineeRef.documentID]{
                cell?.textLabel?.text = theStudent.name
                
                if let thisStudentCourse = theStudent.courseDic[thisCourse.ref.documentID]{
                    cell?.detailTextLabel?.text = enumService.toDescription(e: thisStudentCourse.status)
                } else {
                    cell?.detailTextLabel?.text = "状态未知"
                }
                
            } else {
                cell?.textLabel?.text = "学生未知"
                cell?.detailTextLabel?.text = "状态未知"
            }
        }
        return cell!
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
