//
//  CTBleHelper.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 手机蓝牙的 启停状态 变化通知
 通知对象userInfo 为“蓝牙是否打开”的布尔值，同[CTBleHelper BlePowerdOn]；
 注[Key]：BlePowerdOn
 */
extern NSNotificationName const _Nullable CT_iPhone_BleUpdate;

/** 手机蓝牙 已扫描到的设备列表 更新通知
 通知对象userInfo 为“已扫描到的周围设备”列表数组，元素为“设备信息字典”；
 注[Main Key]：Devices
 注[Sub Key]：Name，BindID，RSSI
 */
extern NSNotificationName const _Nullable CT_Device_ScanUpdate;

/** 设备与手机的 蓝牙连接状态 变化通知
 通知对象userInfo 为“手机与设备蓝牙连接的状态”，同[CTBleHelper ConnectStatus]；
 注[Key]：ConnectStatus， Msg
 */
extern NSNotificationName const _Nullable CT_Device_BleUpdate;

/** 设备 电池状态（充电，电量）变化通知
 通知对象userInfo 为“设备电池状态”字典；
 注[Key]：Success，IsCharge，Battery
 */
extern NSNotificationName const _Nullable CT_Device_BatteryUpdate;

typedef NS_ENUM(NSInteger, CTBleResponseCode) {
    CTBleResponseOK = 0,        // base code - succeed
    CTBleResponseError = -1,    // base code - failed
};
typedef void(^CTResponseHandler)(CTBleResponseCode code, NSString * _Nullable msg);

@interface CTBleHelper : UIViewController

#pragma mark >>> 手机蓝牙状态 <<<
/**
 手机蓝牙的启停状态
 @return 当前蓝牙状态
 注1：初次安装应用，首次调用该方法会激活应用向用户请求蓝牙权限
 注2：该方法必须为Sdk中最先调用的方法，重要！
 注3：默认值 -1，用户未授权或Sdk内部蓝牙模块未初始化；0 手机蓝牙未开启，1 手机蓝牙已开启；
 */
+ (int)BlePowerdOn;

#pragma mark >>> 设备缓存数据 <<<
/**
 清除最近连接设备的缓存数据；
 注：调用以保证内部的“设备首次连接”判定逻辑；
 */
+ (void)CleanDeviceCache;

/**
 已连接 目标设备 的相关信息
 @return 设备信息对象实例
 注[Key]：Name，BindID，
 BleVersionString，CoreVersionString，BleVersion，CoreVersion，
 MAC，
 IsCharge，Battery，
 */
+ (NSDictionary *_Nullable)DeviceInfoCache;

#pragma mark >>> 蓝牙扫描 <<<
/**
 开始扫描
 注：无超时，需要手动停止
 */
+ (void)StartScan;

/**
 停止扫描
 */
+ (void)StopScan;

#pragma mark >>> 蓝牙连接 <<<
/**
 与 目标设备 的蓝牙建立连接
 @param Name 目标设备 的 Name
 @param BindID 目标设备的 BindID
 注1：Name 或 BindID，不能同时为空
 注2：连接结果见 CT_Device_BleUpdate 通知
 */
+ (void)ConnectByName:(NSString *_Nullable)Name BindID:(NSString *_Nullable)BindID;

/**
 与 目标设备 的蓝牙连接状态
 @return 状态  -2：连接已断开，-1：连接失败，0：未连接，1：连接中，2：已连接
 注：状态 1：不会有回调；
 */
+ (int)ConnectStatus;

/**
 断开与 目标设备 的蓝牙连接
 */
+ (void)Disconnect;

/**
 发送 设备关机 命令
 @param response 请求回调
 */
+ (void)Shutdown:(nullable CTResponseHandler)response;

/**
 发送 等待设备轻按电源按钮确认操作
 @param response 请求回调
 注：应用时建议设定超时处理
 */
+ (void)Bind:(nullable CTResponseHandler)response;

#pragma mark >>> WiFi连接 <<<

/**
 获取 设备 当前的 网络连通 状态
 @param response 请求回调
 注：type -2：请求失败，-1：未知类型码，0：联网状态待定，1：STA，2：AP
 */
+ (void)NetworkStatus:(nullable void(^)(CTBleResponseCode code, int type,
                                        NSString * _Nullable ssid,
                                        NSString * _Nullable password,
                                        NSString * _Nullable ip))response;

/**
 请求 设备 启动热点模式
 @param response 请求回调
 */
+ (void)AP:(nullable void(^)(CTBleResponseCode code, NSString * _Nullable ssid,
                             NSString * _Nullable password))response;

/**
 验证 设备 是否能够搜索到指定的 ssid - 2018.3.12，场景：5G网络判断
 @param ssid 指定的 ssid，手机当前连接的 ssid
 @param response 请求回调
 注1：status  -1：验证失败，0：验证成功
 注2：最低版本要求，Ble 1.0.2 & Core 1.2.7
 注3：内部会启动主控芯片
 */
+ (void)STA_VerifiedSSID:(NSString*_Nullable)ssid
                Response:(nullable void(^)(CTBleResponseCode code, int status,
                                           NSString * _Nullable msg))response;

/**
 确认连接公共wifi
 @param ssid 指定的 ssid
 @param password 指定 ssid 的密码
 @param response 请求回调
 注：wifiStatus -3：未搜索到ssid（设备固件版本可能过旧），-1：密码错误，0：请求成功
 */
+ (void)STA:(NSString *_Nullable)ssid Password:(NSString *_Nullable)password
   Response:(nullable void(^)(CTBleResponseCode code, int wifiStatus,
                              NSString * _Nullable ip))response;

#pragma mark >>> 电量信息、mac地址信息、蓝牙/核心 固件版本信息 <<<

/**
 获取 设备 的 充电状态&电量 信息
 */
+ (void)Battery:(nullable void(^)(CTBleResponseCode code, BOOL isCharge, int battery))response;

/**
 获取 设备 的 MAC 信息
 */
+ (void)MAC:(nullable void(^)(CTBleResponseCode code, NSString * _Nullable mac))response;

/**
 获取 设备 的 蓝牙&核心 固件版本信息
 注：内部会启动主控芯片
 */
+ (void)Version:(nullable void(^)(CTBleResponseCode code,
                                  NSString * _Nullable ble,
                                  NSString * _Nullable core,
                                  long bleValue, long coreValue))response;

#pragma mark >>> 蓝牙、核心 固件升级相关 <<<

/**
 蓝牙固件升级，升级期间，会多次调用 response
 @param firmware 蓝牙升级数据包
 @param response 升级状态回调
 */
+ (void)UpdateBLE:(NSData *_Nullable)firmware
         Response:(nullable void(^)(int status, int value))response;

/**
 核心固件升级，升级期间，会多次调用 response
 @param firmware 核心升级数据包
 @param response 升级状态回调
 */
+ (void)UpdateCore:(NSData *_Nullable)firmware
          Response:(nullable void(^)(int status, int value))response;

#pragma mark >>> 设备状态配置 <<<

/**
 关闭OV788芯片，该api不建议使用，未来可能会移除
 */
+ (void)CloseOV788Chip:(CTResponseHandler)response;

/**
 检测 设备 校准状态
 @param response 请求回调
 注1：status -1：未知状态码，0：不需要校准，1：需要校准，2：已校准
 注2：最低版本要求，Ble 2.1.0 & Core 3.1.0
 */
+ (void)CalibrateStatusCheck:(nullable void(^)(CTBleResponseCode code, int status,
                                               NSString * _Nullable msg))response;

/**
 图像校准
 @param command 校准命令 1：校准(ave>250)，2：校准(ave<=250)，3：清除(回滚)
 @param response 请求回调
 注1：status = 0, 校准成功
 注2：最低版本要求，Ble 2.1.0 & Core 3.1.0
 */
+ (void)CalibrateCommand:(int)command
                Response:(nullable void(^)(CTBleResponseCode code, int status,
                                           NSString * _Nullable msg))response;

/**
 RestartNVDS 一键恢复 校准配置文件
 @param response 请求回调
 注1：status = 0, 恢复成功
 注2：最低版本要求，Ble 2.1.0 & Core 3.1.0
 */
+ (void)CalibrateRestartNVDS:(nullable void(^)(CTBleResponseCode code, int status,
                                               NSString * _Nullable msg))response;

/**
 无线&有线 模式 设置
 @param command 设置命令，
 -1：混合模式（旧设备），-2：无线模式（旧设备），-3：有线模式（旧设备）
  1：混合模式（新设备）， 2：无线模式（新设备）， 3：有线模式（新设备）
 @param response 请求回调
 注：最低版本要求，Ble 2.1.0 & Core 3.1.0
 */
+ (void)SetWiredModeCommand:(int)command
                   Response:(nullable void(^)(CTBleResponseCode code,
                                              NSString * _Nullable msg))response;

@end
