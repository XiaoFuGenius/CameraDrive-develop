//
//  UIColor+Extension.swift
//  Demo-Swift
//
//  Created by 胡文峰 on 2019/1/13.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

import Foundation

func XFColor(rgbValue: Int, alpha: CGFloat) -> UIColor {
    let red = ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
    let green = ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0
    let blue = ((CGFloat)(rgbValue & 0xFF))/255.0
    return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
}

extension UIColor {

    // .XF_Red
    class var XF_Red: UIColor {
        return XFColor(rgbValue: 0xff0000, alpha: 1.0)
    }

    // .XF_Green
    class var XF_Green: UIColor {
        return XFColor(rgbValue: 0x00ff00, alpha: 1.0)
    }

    // .XF_Blue
    class var XF_Blue: UIColor {
        return XFColor(rgbValue: 0x0000ff, alpha: 1.0)
    }

    // .XF_f6Gray
    class var XF_f6Gray: UIColor {
        return XFColor(rgbValue: 0xf6f6f6, alpha: 1.0)
    }

}
