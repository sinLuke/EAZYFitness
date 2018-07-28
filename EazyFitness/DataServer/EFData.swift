//
//  EFData.swift
//  EazyFitness
//
//  Created by Luke on 2018/5/16.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class EFData: NSObject {
    let ref:DocumentReference
    var ready = false
    init(with ref:DocumentReference){
        self.ref = ref
        super.init()
        self.download()
    }
    func download(){
        
    }
    func upload(handler: (()->())? = nil){
        
    }
}
