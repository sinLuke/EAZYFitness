//
//  HexColor.swift
//  Cardigin
//
//  Created by Luke on 2018/1/28.
//  Copyright © 2018年 cardigin. All rights reserved.
//

import UIKit

class HexColor: UIColor {
    
    static let lightColor = HexColor.init(red: 250, green: 250, blue: 250)
    static let weekEndColor = HexColor.init(red: 255, green: 250, blue: 250)
    static let weekEndLightColor = HexColor.init(red: 250, green: 245, blue: 245)
    
    static let Red = HexColor.init(red: 167, green: 56, blue: 62)
    static let Purple = HexColor.init(red: 52, green: 17, blue: 38)
    static let Orenge = HexColor.init(red: 170, green: 91, blue: 57)
    static let Blue = HexColor.init(red: 69, green: 119, blue: 163)
    static let Green = HexColor.init(red: 55, green: 139, blue: 46)
    static let Yellow = HexColor.init(red: 169, green: 170, blue: 57)
    
    static let White = HexColor.init(red: 255, green: 255, blue: 255)
    static let Black = HexColor.init(red: 0, green: 0, blue: 0)
    static let Gray = HexColor.init(red: 128, green: 128, blue: 128)
    
    static let colorList = [Red, Purple, Orenge, Blue, Green]
    
    
    static let Pirmary = HexColor.init(red: 129, green: 22, blue: 32)
    
    static let lightRed = HexColor.init(red: 255, green: 230, blue: 230)
    static let lightYellow = HexColor.init(red: 255, green: 255, blue: 230)
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
