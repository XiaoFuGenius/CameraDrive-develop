//
//  XFQuickHelper.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/25.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFQuickHelper : NSObject

///把一个Block放入主线程
+ (void)GCDPutOneBlockIntoMainThreadIsNew:(BOOL)isNew DelayTime:(double)delayTime Block:(void(^)(void))block;
///把一个Block放入子线程
+ (void)GCDPutOneBlockIntoGlobalThreadIsNew:(BOOL)isNew DelayTime:(double)delayTime Block:(void(^)(void))block;

///将一个具体日期转成指定格式的时间字符串
+ (NSString *)GetDateFormatterStrByDate:(NSDate *)date DateFomatString:(NSString *)dateFormat;
///将一个具体日期转换为秒数(默认微秒，自带6位小数)（距1970）
+ (double)GetTimeSince1970ByDateString:(NSString *)dateString DateFormatter:(NSString *)dateFormat;

/**
 打开 系统/应用 设置
 @param type 0-自己，1-蓝牙，2-WiFi
 */
+ (void)XF_ApplicationOpenSettingsType:(int)type;

///打开一个URL，可以是网址，也可以是Scheme
+ (void)OpenUrl:(NSString *)openUrl;

@end
