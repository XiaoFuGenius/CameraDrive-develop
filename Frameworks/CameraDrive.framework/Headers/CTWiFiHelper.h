//
//  CTWiFiHelper.h
//  CameraTool
//
//  Created by xiaofutech on 2016/12/30.
//  Copyright © 2016年 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTWiFiHelper : NSObject

/**
 获取手机当前连接WiFi的ssid
 @return ssid，有可能会获取失败，失败会返回一个空字符串
 */
+ (NSString *)SSID;

/**
 获取本机IP地址
 @return ip
 */
+ (NSString *)LocalIP;

/**
 获取当前WiFi路由分配的IP地址
 @return ip
 */
+ (NSDictionary *)IPAddresses;

/**
 获取当前WiFi路由分配的IP地址
 @param preferIPv4 是否优先ipv4
 @return ip
 */
+ (NSString *)IPAddress:(BOOL)preferIPv4;

/**
 获取当前手机连接WiFi的网关IP地址
 @return ip
 */
+ (NSString *)GatewayIPAddress;

/**
 获取当前连接WiFi的相关信息
 @return 信息字典（广播地址，本机地址，子网掩码地址，端口地址）
 */
+ (NSMutableDictionary *)LocalInfoForCurrentWiFi;

@end
