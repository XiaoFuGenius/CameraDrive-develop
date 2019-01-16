//
//  UIDevice+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XFDeviceType) {
    XFDeviceType_Unspecified = 0,
    XFDeviceType_Simulator,
    XFDeviceType_iPhone,
    XFDeviceType_iPad,
    XFDeviceType_iPodTouch,
    XFDeviceType_AppleTV,
    XFDeviceType_iPhoneX,  // 包含：iPhone X，iPhone XS，iPhone XS Max，iPhone XR
};

@interface UIDevice (XFCategory)

///获取CurrentDevice数据的字典形式
+ (NSDictionary *)XF_CurrentDeviceDict;

#pragma mark - Hardware layer
/**
 获取设备硬件型号 (需要借助 Wikipedia 及时更新)
 @return 设备硬件型号字符串
 */
+ (NSString *)XF_DeviceTypeString;

/**
 获取设备硬件型号，基本判定
 @return 硬件型号对应的枚举值
 */
+ (XFDeviceType)XF_DeviceType;

/**
 获取设备界面类型，基本判定
 @return 界面类型对应的枚举值
 */
+ (UIUserInterfaceIdiom)XF_DeviceInterfaceIdiom;

#pragma mark - Software layer
///获取当前系统版本
+ (NSString *)XF_SystemVersion;

@end
