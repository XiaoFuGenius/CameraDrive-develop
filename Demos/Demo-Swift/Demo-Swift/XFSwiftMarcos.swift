//
//  XFSwiftMarcos.swift
//  Demo-Swift
//
//  Created by 胡文峰 on 2019/1/13.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

import Foundation

func XF_AppBundleId() -> NSString {
    return XFUIAdaptationHelper.appBundleId()! as NSString
}

func XF_AppShortVersion() -> NSString {
    return XFUIAdaptationHelper.appShortVersion()! as NSString
}

func XF_AppBuildVersion() -> NSString {
    return XFUIAdaptationHelper.appBuildVersion()! as NSString
}

func XF_Is_Simulator() -> Bool {
    return UIDevice.xf_DeviceType()==XFDeviceType.simulator
}

func XF_Is_iPad() -> Bool {
    return UIDevice.xf_DeviceType()==XFDeviceType.iPad
}

func XF_Is_iPhoneX() -> Bool {
    return UIDevice.xf_DeviceType()==XFDeviceType.iPhoneX
}

func XF_SysVersion() -> CGFloat {
    return XFUIAdaptationHelper.sysVersion()
}

func XFFont(fontSize: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize)
}

func XFFont_bold(fontSize: CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize: fontSize)
}

/// 打开 系统/应用 设置
///
/// - Parameter type: 0-自己，1-蓝牙，2-WiFi
func XF_ApplicationOpenSettings(type: Int) {
    var urlString: NSString = NSString.init(string: UIApplication.openSettingsURLString)

    if type==1 || type==2 {
        if #available(iOS 10.0, *) {
            if type==1 {  // 蓝牙
                urlString = "+isuBvoLk0Yiom+zE/seXWlQ61KndZ37+Nvoncux4Dg="
            } else if type==2 {  // WiFi
                urlString = "jQhHpJ9VKHSuHiR5IhA4gfdeNW6UJznZBCmDQE0+Iug="
            }
        } else {
            // Fallback on earlier versions
            if type==1 {  // 蓝牙
                urlString = "kPA0CM7evkwDf8Z6cFz3MRnN4AiXJMulSCc0m/dTSvM="
            } else if type==2 {  // WiFi
                urlString = "tpc9U7wbJZEVbQnLoj+ErA=="
            }
        }
        urlString = urlString.xf_DecryptAES128()! as NSString
    }

    let url = URL.init(string: urlString as String)
    if !UIApplication.shared.canOpenURL(url!) {
        NSLog("打开系统设置失败，请手动打开")
        return;
    }

    //XFQuickHelper.openUrl(urlString as String)
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    } else {
        // Fallback on earlier versions
        UIApplication.shared.openURL(url!)
    }

}
