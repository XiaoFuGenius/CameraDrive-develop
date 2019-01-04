//
//  CTSwiftLinker.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/12/27.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 手机蓝牙的 启停状态 变化通知
 通知对象userInfo 为“蓝牙是否打开”的布尔值，同[CTBleHelper BlePowerdOn]；
 注[Key]：BlePowerdOn
 */
extern NSNotificationName const _Nullable CTSwift_iPhone_BleUpdate;

/** 设备与手机的 蓝牙连接状态 变化通知
 通知对象userInfo 为“手机与设备蓝牙连接的状态”，同[CTBleHelper ConnectStatus]；
 注[Key]：ConnectStatus， Msg
 */
extern NSNotificationName const _Nullable CTSwift_Device_BleUpdate;

/** 设备 电池状态（充电，电量）变化通知
 通知对象userInfo 为“设备电池状态”字典；
 注[Key]：Success，IsCharge，Battery
 */
extern NSNotificationName const _Nullable CTSwift_Device_BatteryUpdate;



typedef NS_ENUM(NSInteger, CTSwiftBleLinkStatus) {
    CTSwiftBleLinkDevicePoweredOn = 0,  // 设备 已开机 -> 已发现 1+ 台设备(未判定目标设备蓝牙信号强度)

    //CTSwiftBleLinkDeviceMultiple,       // 设备 搜索到多台设备 - 无效de枚举值
    CTSwiftBleLinkDeviceNotFound,       // 设备 未发现 -> 设备未开机，或目标设备蓝牙信号强度弱

    CTSwiftBleLinkDeviceSucceed,        // 设备 已连接
    CTSwiftBleLinkDeviceFailed,         // 设备 未成功连接
};  // 蓝牙连接状态回调
typedef void(^CTSwiftBleLinkResponse)(CTSwiftBleLinkStatus status, NSString *description);

typedef NS_ENUM(NSInteger, CTSwiftNetworkLinkStatus) {
    CTSwiftNetworkLinkCheckStatus = 0,  // 开始检查设备当前联网状态

    CTSwiftNetworkLinkSTA,              // STA模式 开启连接进程
    CTSwiftNetworkLink5gChecking,       // STA模式 开始5g网络检测
    CTSwiftNetworkLink5gConfirmed,      // STA模式 判定当前网络为5G模式
    CTSwiftNetworkLinkWiFiStart,        // STA模式 设备开始尝试连接指定WiFi
    CTSwiftNetworkLinkStaFailed,        // STA模式 连接命令请求失败
    CTSwiftNetworkLinkPwdError,         // STA模式 密码错误
    CTSwiftNetworkLinkSsidNotFound,     // STA模式 设备固件版本旧或其他原因，设备未搜索到指定wifi的ssid
    CTSwiftNetworkLinkPingChecking,     // STA模式 开始ping检测
    CTSwiftNetworkLinkPingFailed,       // STA模式 手机未ping通设备当前ip

    CTSwiftNetworkLinkAP,               // AP模式 开启连接进程
    CTSwiftNetworkLinkHotspotStart,     // AP模式 开始尝试应用内连接设备热点
    CTSwiftNetworkLinkIpAddrChecking,   // AP模式 开始连接成功后的IP地址检测
    CTSwiftNetworkLinkApFailed,         // AP模式 连接命令请求失败

    CTSwiftNetworkLinkSucceed,          // 设备 已联网
    CTSwiftNetworkLinkFailed,           // 设备 未成功联网
};  // 网络连接状态回调
typedef void(^CTSwiftNetworkLinkResponse)(CTSwiftNetworkLinkStatus status, NSString *description);

// STA & AP 模式，需要用户交互的联网提示框
typedef void(^CTSwiftAlertShowHandler)(int type, NSString *ssid);  // type 当前联网模式 1：STA，2：AP
typedef void(^CTSwiftAlertActionCanceled)(void);        // 提示框 取消 回调
typedef void(^CTSwiftAlertActionConfirmed)(NSString *password);  // 提示框 确认 回调

// 配置 CTConfig & CTEasyLinker
typedef void(^CTSwiftReconfigureHandler)(void);



@interface CTSwiftLinker : NSObject
@property (nonatomic, assign, readonly) int type; // 当前联网模式 1：STA，2：AP - 设备成功联网后可获取（成功前获取，值不可信）
@property (nonatomic, strong, readonly) NSString *ip;  // 设备ip地址 - 设备成功联网后可获取（成功前获取，值不可信）

@property (nonatomic, copy) CTSwiftReconfigureHandler configHandler;

@property (nonatomic, copy) CTSwiftBleLinkResponse bleResponse;
@property (nonatomic, copy) CTSwiftNetworkLinkResponse networkResponse;

@property (nonatomic, copy) CTSwiftAlertShowHandler alertShowHandler;
@property (nonatomic, copy, readonly) CTSwiftAlertActionCanceled canceledHandler;
@property (nonatomic, copy, readonly) CTSwiftAlertActionConfirmed confirmedHandler;

/**
 CTSwiftLinker 共享实例
 @return 实例对象
 */
+ (CTSwiftLinker *)SharedLinker;

/**
 开启设备连接！
 */
+ (void)Start;

/**
 连接中取消需调用该方法！
 */
+ (void)Stop;

@end

NS_ASSUME_NONNULL_END
