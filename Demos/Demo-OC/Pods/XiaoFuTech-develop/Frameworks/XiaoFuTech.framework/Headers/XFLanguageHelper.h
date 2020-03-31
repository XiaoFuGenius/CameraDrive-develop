//
//  XFLanguageHelper.h
//  XiaoFuTech
//
//  Created by 胡钧昱 on 2018/2/25.
//  Copyright © 2018年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>


#define XFLanguageString(key) [XFLanguageHelper GetStringByKey:key]

@interface XFLanguageHelper : NSObject

/**
 初始化
 @param tableName 多语言本地支持文件
 备注：
 [NSLocale preferredLanguages] // 手机系统首选语言列表
 [NSBundle mainBundle].localizations // App本地化语言列表
 [[NSBundle mainBundle].preferredLocalizations objectAtIndex:0] // 系统当前首选语言
 */
+ (void)InitLanguageHelper:(NSString *)tableName;

/**
 获取当前设置的语言信息字典
 */
+ (NSDictionary *)AppLanguage;

/**
 根据具体语言简写，获取对应的语言类型码
 */
+ (NSInteger)LanguageCodeViaKey:(NSString *)key;

/**
 获取当前设置的语言类型码
 备注：包含类型-1，跟随系统；
 */
+ (NSInteger)LanguageCode;

/**
 获取当前设置的语言类型码
 备注：移除 类型-1，跟随系统；获取与-1等同语言的Code
 */
+ (NSInteger)LanguageCodeWithoutAuto;

/**
 设置应用显示语言
 @param code 语言类型码
 @param completion 设置完成后可执行的Block
 备注：-1，跟随系统
 */
+ (void)SetAppLanguageViaCode:(NSInteger)code Completion:(void (^)(void))completion;

/**
 根据key来显示当前选择好的语言
 @param key 关键词
 @return 根据当前已选择的语言版本显示语言
 */
+ (NSString *)GetStringByKey:(NSString *)key;

@end
