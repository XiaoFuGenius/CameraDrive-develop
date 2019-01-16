//
//  XFSettingsBundleHelper.h
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/11/13.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^XFSettingsBundleReadHandler)(BOOL reset);

@interface XFSettingsBundleHelper : NSObject

/**
 控制台输出日志 打开
 */
+ (void)LogEnabled;

/**
 Settings.bundle 文件是否加载
 @return 检查结果
 */
+ (BOOL)IsBundleInstalled;

/**
 读取 Settings.bundle 文件
 @param completion 内容变更回调：Settings.bundle
 注：1.需要配合指定的 Settings.bundle 文件使用.
 2.当前支持，server_preference，version_preference
 */
+ (void)ReadSettingsBundleCompletion:(XFSettingsBundleReadHandler)completion;

/**
 服务器地址编号，根据 Settings.bundle 中的 Root.plist 设置
 @return 地址编号：0 正式环境（文件未加载及默认值 0）
 */
+ (NSInteger)ServerNumber;

@end

NS_ASSUME_NONNULL_END
