//
//  TimeTableView.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/30.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class TimeTableView: UIView {
    
    let MaxWidth:CGFloat! = nil
    let MaxHeight:CGFloat! = nil
    
    let eachTimeScopeHeight:CGFloat = 50
    
    var startTime:Int = 0
    var timeScope:Int = 0
    
    var viewForEachDay:[UIView] = []
    var topView:UIView?
    var background:UIView!
    var DayLabele:[UILabel] = []
    var timeScopeLabelList:[UILabel] = []
    var CourseViewList:[CourseBlock] = []

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
