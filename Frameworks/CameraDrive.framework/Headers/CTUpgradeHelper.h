//
//  CTUpgradeHelper.h
//  CameraDrive
//
//  Created by 胡文峰 on 2019/1/2.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CTUpgradeSignType) {
    CTUpgradeSignTypeUpToDate = 0,  // 版本已经最新
    CTUpgradeSignTypeOptional,  // 有可选升级版本
    CTUpgradeSignTypeRequired,  // 有强制升级版本
};

typedef NS_ENUM(NSInteger, CTUpgradeResponseSignType) {
    CTUpgradeResponseSignTypeBleDownloading = 0,  // 蓝牙固件升级数据包下载中
    CTUpgradeResponseSignTypeBleUpgrading,  // 蓝牙固件升级中
    CTUpgradeResponseSignTypeBleUpgradeError,  // 蓝牙固件升级进程失败

    CTUpgradeResponseSignTypeCoreDownloading,  // 核心固件升级数据包下载中
    CTUpgradeResponseSignTypeCoreUpgrading,  // 核心固件升级中
    CTUpgradeResponseSignTypeCoreUpgradeError,  // 核心固件升级进程失败

    CTUpgradeResponseSignTypeFirmwareUpgradeError,  // 固件升级失败
};

/**
 升级数据包，下载状态回调
 @param status -1，下载错误；0，下载中，1，下载完成；
 @param progress 下载进度
 @param data 数据包
 */
typedef void(^CTUpgradeDownloadCallback)(NSInteger status, NSInteger progress, NSData * _Nullable data);

/**
 升级数据包，下载回调
 @param url 固件下载地址
 @param callback 下载状态回调
 */
typedef void(^CTUpgradeDownloadHandler)(NSString *url, CTUpgradeDownloadCallback callback);

/**
 固件升级回调
 @param isOK - NO，升级失败；YES，升级中；
 @param signType 升级状态标志
 @param progress - 升级进度
 @param msg 状态说明
 */
typedef void(^CTUpgradeResponseHandler)(BOOL isOK, CTUpgradeResponseSignType signType,
                                        NSInteger progress, NSString *msg);

@interface CTUpgradeHelper : NSObject

/* BLE */
@property (nonatomic, strong) NSString *bleUrl;
@property (nonatomic, assign) NSInteger bleVersionOptional;  // 优先级高于 String
@property (nonatomic, assign) NSInteger bleVersionRequired;  // 优先级高于 String
@property (nonatomic, strong) NSString *bleVersionStringOptional;
@property (nonatomic, strong) NSString *bleVersionStringRequired;
@property (nonatomic, assign, readonly) CTUpgradeSignType bleUpgradeSign;
@property (nonatomic, strong, readonly) NSData *bleData;

/* CORE */
@property (nonatomic, strong) NSString *coreUrl;
@property (nonatomic, assign) NSInteger coreVersionOptional;  // 优先级高于 String
@property (nonatomic, assign) NSInteger coreVersionRequired;  // 优先级高于 String
@property (nonatomic, strong) NSString *coreVersionStringOptional;
@property (nonatomic, strong) NSString *coreVersionStringRequired;
@property (nonatomic, assign, readonly) CTUpgradeSignType coreUpgradeSign;
@property (nonatomic, strong, readonly) NSData *coreData;

/* COMMON */
@property (nonatomic, copy) CTUpgradeDownloadHandler downloadHandler;

/* upgrade start */
@property (nonatomic, assign, readonly) CTUpgradeSignType upgradeSign;  // 一键升级，综合考虑 蓝牙 + 核心 固件升级信息

/**
 固件升级工具类实例
 @return 实例对象
 需要，在成功连接设备前，更新固件升级信息；
 建议，提前缓存最新的固件升级数据包；
 */
+ (CTUpgradeHelper *)SharedUpgradeHelper;

/**
 蓝牙固件升级，完成后自动关机
 @param response 升级 进度/结果 回调
 */
- (void)bleUpgradeStartResponse:(CTUpgradeResponseHandler)response;

/**
 核心固件升级，完成后自动关机
 @param response 升级 进度/结果 回调
 */
- (void)coreUpgradeStartResponse:(CTUpgradeResponseHandler)response;

/**
 一键升级，先核心后蓝牙，完成后自动关机
 @param response 升级 进度/结果 回调
 注1：设备当前版本要求 ble，2.0.0+；core，3.0.0+；
 注2：设备成功联网后调用
 */
- (void)upgradeStartResponse:(CTUpgradeResponseHandler)response;

@end

NS_ASSUME_NONNULL_END
