//
//  AddCourseViewController.swift
//  EazyFitness
//
//  Created by Luke on 2018/7/29.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

class AddCourseViewController: DefaultViewController {
    
    var model: AddCourseDataModel!
    @IBOutlet weak var masterTableView: UITableView!
    @IBOutlet weak var AddCourseCollectionView: UICollectionView!
    @IBOutlet weak var addCourseBtn: UIButton!
    override func reload() {
        super.reload()
    }

    override func refresh() {
        super.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        masterTableView.delegate = self
        AddCourseCollectionView.delegate = self
        masterTableView.dataSource = self
        AddCourseCollectionView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addCourse(_ sender: Any) {
        for courseReady in self.model.courseReadyList {
            addthisCourse(courseReady: courseReady)
        }
        _ = self.navigationController?.popViewController(animated: true)
        if let cvc = self.navigationController?.topViewController as? refreshableVC {
            cvc.refresh()
        }
    }
    
    func addthisCourse(courseReady: courseReadyItem){
        EFStudent.addCourse(of: self.model.studentList, date: courseReady.date, amount: courseReady.amount, note: courseReady.note, trainer: self.model.trainer.ref, status: courseStatus.waitForStudent)
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

extension AddCourseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.courseReadyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCoureseCourseCell", for: indexPath) as! AddCoureseCourseCell
        return cell
    }
    
    
}

extension AddCourseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 500
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "常用的时间组合"
        } else {
            return "添加课程"
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCourseMasterCell") as! AddCourseMasterCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCourseCustumTimeCell") as! AddCourseCustumTimeCell
            return cell
        }
    }
    
    
}
