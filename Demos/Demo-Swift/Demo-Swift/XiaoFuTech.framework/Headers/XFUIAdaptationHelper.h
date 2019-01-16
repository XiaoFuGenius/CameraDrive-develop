//
//  XFUIAdaptationHelper.h
//  XiaoFuTech
//
//  Created by xiaofutech on 2018/1/19.
//  Copyright © 2018年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFUIAdaptationHelper : NSObject

+ (CGFloat)SysVersion;

+ (NSString *)AppBundleId;

+ (NSString *)AppShortVersion;

+ (NSString *)AppBuildVersion;

+ (CGFloat)Width;

+ (CGFloat)Height;

+ (CGFloat)Scale;

+ (CGFloat)SafeTop;

+ (CGFloat)SafeBottom;

+ (CGFloat)Scale4iPad;

@end
