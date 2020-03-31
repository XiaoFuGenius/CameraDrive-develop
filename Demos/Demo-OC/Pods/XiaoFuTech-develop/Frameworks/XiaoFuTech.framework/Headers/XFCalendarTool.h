//
//  XFCalendarTool.h
//  MorningDay
//
//  Created by 胡钧昱 on 2019/3/11.
//  Copyright © 2019 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XFCalendarTool : NSObject

+ (XFCalendarTool *)Shared;

#pragma mark ======== 公历 ========
@property (nonatomic, assign, readonly) NSDate *date;               // 当前日期
@property (nonatomic, assign, readonly) NSInteger day;              // 当前 公历日
@property (nonatomic, assign, readonly) NSInteger month;            // 当前 公历月
@property (nonatomic, assign, readonly) NSInteger year;             // 当前 公历年
@property (nonatomic, assign, readonly) NSInteger weekday;          // 今天是星期几
@property (nonatomic, assign, readonly) NSInteger firstWeekday;     // 当前月第一天是星期几
@property (nonatomic, assign, readonly) NSInteger weekOfYear;       // 当前年的第几周
@property (nonatomic, assign, readonly) NSInteger weekOfMonth;      // 当前月的第几周
@property (nonatomic, assign, readonly) NSInteger days;             // 当前月总天数

- (NSInteger)convertDateToDay:(NSDate *)date;   // 公历日
- (NSInteger)convertDateToMonth:(NSDate *)date;  // 公历月
- (NSInteger)convertDateToYear:(NSDate *)date;  // 公历年
- (NSInteger)convertDateToWeekday:(NSDate *)date;  // 星期几
- (NSInteger)convertDateToFirstWeekday:(NSDate *)date;  // 公历月第一天是星期几
- (NSInteger)convertDateToWeekOfYear:(NSDate *)date;  // 公历年的第几周
- (NSInteger)convertDateToWeekOfMonth:(NSDate *)date;  // 公历月的第几周
- (NSInteger)convertDateToDays:(NSDate *)date;  // 公历月的总天数

/**
 根据date获取 偏移 指定天数 的date
 @param date 指定日期
 @param offsetDays 偏移天数
 @return 目标日期
 */
- (NSDate *)getDateFrom:(NSDate *)date offsetDays:(NSInteger)offsetDays;

/**
 根据date获取 偏移 指定月数 的date
 @param date 指定日期
 @param offsetMonths 偏移月数
 @return 目标日期
 */
- (NSDate *)getDateFrom:(NSDate *)date offsetMonths:(NSInteger)offsetMonths;

/**
 根据date获取 偏移 指定年数 的date
 @param date 指定日期
 @param offsetYears 偏移年数
 @return 目标日期
 */
- (NSDate *)getDateFrom:(NSDate *)date offsetYears:(NSInteger)offsetYears;

/**
 获取 指定年 第一天的日期
 @param year 指定年
 @return 日期
 */
- (NSDate *)getFirstDayInSpecificYear:(NSInteger)year;

/**
 获取 指定年 最后一天的日期
 @param year 指定年
 @return 日期
 */
- (NSDate *)getLastDayInSpecificYear:(NSInteger)year;

/**
 获取 A、B 日期之前的差额
 @param dateAlpha 日期A
 @param dateBeta 日期B
 @param type 差额类型：1，秒数；2，分钟数；3，小时数；4，天数；5，星期数；6，月数；7，年数；
 @return 相应类型下的 差额，向左取整
 */
- (NSInteger)getTimeIntervalFrom:(NSDate *)dateAlpha To:(NSDate *)dateBeta Type:(NSInteger)type;

#pragma mark ======== 农历 ========
@property (nonatomic, strong) NSString *lunarDay;       // 当前 农历日
@property (nonatomic, strong) NSString *lunarMonth;     // 当前 农历月
@property (nonatomic, strong) NSString *lunarYear;      // 当前 农历年
@property (nonatomic, strong) NSString *lunarZodiac;    // 生肖

- (NSString *)convertDateToLunarDay:(NSDate *)date;  // 农历日
- (NSString *)convertDateToLunarMonth:(NSDate *)date;  // 农历月
- (NSString *)convertDateToLunarYear:(NSDate *)date;  // 农历年
- (NSString *)convertDateToLunarZodiac:(NSDate *)date;  // 农历年的生肖

@end

NS_ASSUME_NONNULL_END
