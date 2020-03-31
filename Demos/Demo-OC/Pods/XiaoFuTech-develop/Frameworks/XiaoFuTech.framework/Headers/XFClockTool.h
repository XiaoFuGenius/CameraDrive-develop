//
//  XFClockTool.h
//  MorningDay
//
//  Created by 胡钧昱 on 2019/3/18.
//  Copyright © 2019 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const XFNotis_ClockTool_TimeUpdate;
extern NSNotificationName const XFNotis_ClockTool_DayFlipped;

@interface XFClockTool : NSObject
@property (nonatomic, strong, readonly) NSDate *date;  // 当前时间
@property (nonatomic, assign) BOOL is24HourClock;  // 是否24小时制
@property (nonatomic, strong, readonly) NSArray *clockArray;  // 当前时钟数组 @[@"h1", @"h2", @"m1", @"m2", @"s1", @"s2"]
@property (nonatomic, assign, readonly) BOOL isAfternoon;  // 是否下午，基于 is24HourClock = NO;

+ (XFClockTool *)Shared;
@end

NS_ASSUME_NONNULL_END
