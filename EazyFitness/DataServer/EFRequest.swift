//
//  EFRequest.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class EFRequest: EFData {
    
    var title:String!
    var sander:EFData!
    var text:String!
    var date:Date!
    
    var canceled = false
    
    override func download() {
        
    }
    override func upload() {
        
    }
    func cancel(){
        if self.canceled == false {
            ref.delete()
            self.canceled = true
        }
    }
    func approve(){
        if self.canceled == false {
            ref.delete()
            self.canceled = true
        }
    }
}
