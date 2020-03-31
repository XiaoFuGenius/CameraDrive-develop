//
//  XFUIAdaptationHelper.h
//  XiaoFuTech
//
//  Created by 胡钧昱 on 2018/1/19.
//  Copyright © 2018年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFUIAdaptationHelper : NSObject

+ (CGFloat)SysVersion;

+ (NSString *)AppBundleId;

+ (NSString *)AppShortVersion;

+ (NSString *)AppBuildVersion;

+ (CGFloat)Width;

+ (CGFloat)Height;

+ (CGFloat)SafeTop;

+ (CGFloat)SafeBottom;

+ (CGFloat)NavigationBarHeight;

/**
 iPhone缩放比例，基准为：375 * 667
 @return 缩放比
 */
+ (CGFloat)Scale;

/**
 iPad缩放比例，基准为：768 * 1024
 @return 缩放比
 */
+ (CGFloat)Scale4iPad;

@end
