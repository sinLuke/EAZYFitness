//
//  CourseBlock.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/1.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class CourseBlock: UIView {
    
    var startOfTheWeek:Date!
    var superView:TimeTableView!
    
    var courseID:String!
    var startTime:Date!
    var duration:Int!
    
    func adjectSelfFream(){
        
        let startTimeInt = Calendar.current.component(.hour, from: startTime)*100 + Calendar.current.component(.minute, from: startTime)
        
        let value1 = CGFloat((startTimeInt/100)*100 + (startTimeInt%100)*100/60)-CGFloat(superView.startTime*100)
        let height = CGFloat(duration)*CGFloat(superView.eachTimeScopeHeight)/2
        self.frame = CGRect(x: 0, y: (value1)*superView.eachTimeScopeHeight/100 + superView.eachTimeScopeHeight/2, width: (superView.frame.width-TimeTable.LEFTWIDTH)/7, height: height)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func tapBlurButton(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
    }

}
