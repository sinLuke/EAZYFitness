//
//  AddCoureseCourseCell.swift
//  EazyFitness
//
//  Created by Luke on 2018/7/29.
//  Copyright © 2018 luke. All rights reserved.
//

import UIKit

class AddCoureseCourseCell: UICollectionViewCell {
    @IBOutlet weak var smallTopLabel: UILabel!
    @IBOutlet weak var MiddleCentalLabel: UILabel!
    @IBOutlet weak var BottomLabel: UILabel!
    @IBOutlet weak var fullTimeLabel: UILabel!
    
    var indexRow: Int?
    
    var model: AddCourseDataModel?
    var theCourse: courseReadyItem?
    func reload(){
        let dateformater = DateFormatter()
        dateformater.dateStyle = .medium
        dateformater.timeStyle = .none
        let timeformater = DateFormatter()
        timeformater.dateStyle = .none
        timeformater.timeStyle = .short
        if let theCourse = theCourse {
            self.smallTopLabel.text = "\(AppDelegate.prepareCourseNumber(theCourse.amount))课时"
            if self.fullTimeLabel != nil {
                self.fullTimeLabel.text = dateformater.string(from: theCourse.date)
            }
            self.BottomLabel.text = timeformater.string(from: theCourse.date)
            self.MiddleCentalLabel.text = "\(theCourse.date.getThisWeekDayLongName())"
        }
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        if let model = self.model, let indexRow = self.indexRow {
            model.courseReadyList.remove(at: indexRow)
            model.reload()
        }
    }
}
