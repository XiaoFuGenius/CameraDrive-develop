//
//  XFBuglySdkHelper.h
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/19.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XFBuglySdkHelper : NSObject

/**
 初始化并注册到 BuglySdk
 @param appKey appid，必填
 @param secret appSecret，可为空
 @param debugEnable 日志开关
 注：pod 'Bugly'
 注2：修改 appid & appSecret 时，注意同步修改 < 自动上载 DYSM >脚本 中的值
*/
+ (void)RegisterAppKey:(NSString *)appKey secret:(NSString *)secret debugEnable:(BOOL)debugEnable;

@end

NS_ASSUME_NONNULL_END
