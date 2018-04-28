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
    
    static let Red = HexColor.init(red: 255, green: 114, blue: 118)
    static let Purple = HexColor.init(red: 247, green: 106, blue: 218)
    static let Orenge = HexColor.init(red: 255, green: 171, blue: 77)
    static let Blue = HexColor.init(red: 0, green: 185, blue: 227)
    static let Green = HexColor.init(red: 135, green: 232, blue: 115)
    
    static let colorList = [Red, Purple, Orenge, Blue, Green]
    
    
    static let Pirmary = HexColor.init(red: 188, green: 2, blue: 0)
    
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
