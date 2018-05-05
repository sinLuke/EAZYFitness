//
//  StudentCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/1.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase

class StudentCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var DateTimeLabel: UILabel!
    var vc:trainerMyStudentVC!
    var MemberID:String!
    
    @IBAction func manageTimeTable(_ sender: Any) {
        vc.studentMemberID = MemberID
        vc.studentTimeTableRef = Firestore.firestore().collection("student").document(MemberID).collection("CourseRecorded")
        vc.performSegue(withIdentifier: "studentTimetable", sender: self)
    }
}
