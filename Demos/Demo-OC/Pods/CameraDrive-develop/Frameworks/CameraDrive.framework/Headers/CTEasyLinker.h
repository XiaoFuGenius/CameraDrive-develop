//
//  CTEasyLinker.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CTNetworkStatusHandler)(CTBleResponseCode code, int type, NSString *ssid,
                 NSString *password, NSString *ip);

// 简化 连接 流程；
@interface CTEasyLinker : NSObject
/**
 设置 首选 联网模式，1：优先sta，2：强制ap；
 注：默认：1，优先sta，备选ap
 */
@property (nonatomic, assign) NSInteger smartMode;

/**
 场景：5G网络
 sta确认连接之前，是否进行5G网络判断；
 注1：YES：启用5G网络判断，默认 NO；
 注2：版本要求：蓝牙 1.0.11+ ，固件 1.2.7+
 注3：蓝牙 1.1.0+ 固件 1.3.0+ 支持2.4g下的11+信道（低于该版本，“2.4g，11+信道”会被误判为5g）
 */
@property (nonatomic, assign) BOOL verify5GEnabled;

/**
 场景：星巴克，公共验证类wifi
 sta模式 连接成功后，是否ping分配给设备的ip地址;
 注：YES：启用ping检查，默认 NO；
 */
@property (nonatomic, assign) BOOL staPingEnabled;

/**
 STA模式 (ssid & pwd) 缓存
 公共WiFi模式，存储连接成功的ssid和pwd；
 注：YES：启用缓存，默认 NO；
 */
@property (nonatomic, assign) BOOL staCachesStored;

/**
 STA 模式下会忽略的 ssid 字符串数组
 全匹配 ssid 开头字符串，匹配成功，判定为测试仪热点，不做为STA模式可用wifi处理
 注：默认过滤 ”CFY_“ 开头的ssid，可以设置 nil 来关闭过滤；
 */
@property (nonatomic, strong) NSArray<NSString *> *ssidIgnored;

/**
 iOS 11+ 支持应用内连接指定热点
 注：默认：NO；
 */
@property (nonatomic, assign) BOOL hotspotEnabled;

/**
 设备已准备好 可以启动 AP 联网模式；
 注：方法“NetworkStatusCheckOnly:Response”会触发该回调；
 注：
 */
@property (nonatomic, copy) void(^preparedForAP)(NSString *ssid, NSString *password);

/**
 设备已准备好 可以启动 STA 联网模式；
 注：方法“NetworkStatusCheckOnly:Response”会触发该回调；
 */
@property (nonatomic, copy) void(^preparedForSTA)(NSString *ssid);

/**
 AP 联网模式，失败回调；
 */
@property (nonatomic, copy) void(^responseForAP)(CTBleResponseCode code);

/** 较”CTBleHelper“，wifiStatus -101：5g检查，判定为5g网络，-102：ping检查，判定为公共验证类wifi；
 STA 联网模式，失败回调；
 注：方法“NetworkStatusCheckOnly:Response”会触发该回调，含“5G网络”检测；
 注：方法“STA:Password”会触发该回调，含”Ping“检测；
 注：wifiStatus -3：未搜索到ssid（设备固件版本可能过旧），-2：命令请求失败或超时，-1：密码错误
 */
@property (nonatomic, copy) void(^responseForSTA)(CTBleResponseCode code, int wifiStatus, NSString *ip);

/**
 设备 联网进程 执行完成回调；
 注：方法“NetworkStatusCheckOnly:Response”会触发该回调；
 */
@property (nonatomic, copy) void(^networkLinkResponse)(CTBleResponseCode code, int type, NSString *ip);

/** 可选
 STA，启动回调
 */
@property (nonatomic, copy) void(^staStartResponse)(void);

/** 可选
 5G网络检测，启动和结束回调
 */
@property (nonatomic, copy) void(^verify5GResponse)(BOOL isStart, CTBleResponseCode code);

/** 可选
 Ping检测，启动和结束回调
 */
@property (nonatomic, copy) void(^staPingResponse)(BOOL isStart, CTBleResponseCode code);

/** 可选
 AP，启动回调
 */
@property (nonatomic, copy) void(^apStartResponse)(void);

/** 可选
 Hotspot，启动和结束回调
 */
@property (nonatomic, copy) void(^hotspotResponse)(BOOL isStart, CTBleResponseCode code);

/** 可选
 AP模式，热点连接成功后的IP地址检测，启动和结束回调
 */
@property (nonatomic, copy) void(^verifyIpAddressResponse)(BOOL isStart, CTBleResponseCode code);

/** 较”CTBleHelper“，连接后会自动获取版本号，若失败，则断开蓝牙连接，返回失败；
 与 目标设备 的蓝牙建立连接
 @param Name 目标设备 的 Name
 @param BindID 目标设备的 BindID
 注1：Name 或 BindID，不能同时为空
 注2：连接结果见 CT_Device_BleUpdate 通知
 */
+ (void)ConnectByName:(NSString *)Name BindID:(NSString *)BindID;

/** 较“CTBleHelper”，”checkOnly=NO“表示，查询成功后会自动开启联网进程；
 获取 设备 当前的 网络连通 状态
 @param checkOnly 是否仅查询状态
 @param response response 请求回调，仅”checkOnly=YES“才会调用
 注：type -2：请求失败，-1：未知类型码，0：联网状态待定，1：STA，2：AP
 */
+ (void)NetworkStatusCheckOnly:(BOOL)checkOnly Response:(nullable CTNetworkStatusHandler)response;

/**
 请求 设备 启动热点模式
 */
+ (void)AP;

/** 较”CTBleHelper“，wifiStatus -101：5g检查，判定为5g网络，-102：ping检查，判定为公共验证类wifi；
 确认连接公共wifi
 @param ssid 指定的 ssid
 @param password 指定 ssid 的密码
 */
+ (void)STA:(NSString *)ssid Password:(NSString *)password;

/** 较”CTBleHelper“，“status”->“code”，“value”可直接引用，范围 1~100；
 蓝牙固件升级，升级期间，会多次调用 response
 @param firmware 蓝牙升级数据包
 @param response 升级状态回调
 */
+ (void)UpdateBLE:(NSData *)firmware Response:(void(^)(CTBleResponseCode code, int value, NSString *msg))response;

/** 较”CTBleHelper“，“status”->“code”，“value”可直接引用，范围 1~100；
 核心固件升级，升级期间，会多次调用 response
 @param firmware 核心升级数据包
 @param response 升级状态回调
 */
+ (void)UpdateCore:(NSData *)firmware Response:(void(^)(CTBleResponseCode code, int value, NSString *msg))response;

#pragma mark >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

/**
 获取当前已缓存的 sta模式下 所有成功连接过的 wifi 数据
 @return 已缓存的wifi数据
 注[Key]：SSID，Password
 注：需要设置属性 staCachesStored = YES;
 */
+ (NSArray <NSDictionary *>*)STACaches;

/**
 获取手机当前连接的 wifi 的密码，如果存在
 @param ssid 想要获取密码的ssid
 @return ssid 对应的密码
 注：需要设置属性 staCachesStored = YES;
 */
+ (NSString *)STACachesContains:(NSString *)ssid;

/**
 清除已缓存的 sta模式下 成功连接过的特定 wifi 数据
 @param caches 指定的wifi数据
 注：需要设置属性 staCachesStored = YES;
 */
+ (void)STACachesCleaned:(NSArray <NSDictionary *>*)caches;

#pragma mark >>> LIFE CYCLE <<<
/**
 取得 CTEasyLinker 的共享实例
 @return CTEasyLinker 的共享实例
 */
+ (CTEasyLinker *)SharedEsayLinker;

@end

NS_ASSUME_NONNULL_END
