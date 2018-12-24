//
//  CTHotspotHelper.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTHotspotHelper : NSObject

/**
 仅支持系统 11.0+
 @param ssid wifi名称
 @param pwd wifi密码
 @param completion 完成回调
 */
+ (void)TryHotspotSSID:(NSString *)ssid Pwd:(NSString *)pwd
            Completion:(void(^)(BOOL success, NSError *error))completion;

/**
 检测手机是否已成功获取 设备热点模式 分配的IP地址
 @param confirmed 检测完成回调
 */
+ (void)IPAddressConfirmed:(void(^)(BOOL success))confirmed;

@end

NS_ASSUME_NONNULL_END
