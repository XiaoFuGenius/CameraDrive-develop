//
//  NotificationCenter+Extension.swift
//  Demo-Swift
//
//  Created by 胡文峰 on 2019/1/14.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

import Foundation

//MARK:- 存在问题，用法未生效
//enum XFNotification: String {
//    case notiName1
//    case notiName2
//
//    var stringValue: String {
//        return "XF" + rawValue
//    }
//
//    var notificationName: NSNotification.Name {
//        return NSNotification.Name(stringValue)
//    }
//}
//
//extension NotificationCenter {
//    static func post(customeNotification name: XFNotification, object: Any? = nil) {
//        NotificationCenter.default.post(name: name.notificationName, object: object)
//    }
//}
