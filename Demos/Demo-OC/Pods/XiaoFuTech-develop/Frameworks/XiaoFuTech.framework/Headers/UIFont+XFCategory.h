//
//  UIFont+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (XFCategory)

/**
 获取系统拥有的所有字体的名称数组

 @return 字体名称数组
 */
+ (NSArray *)XF_GetAllFontNames;


/**
 获取导入的自定义字体的名称
 并注册自定义字体到系统字体库，在程序启动后调用一次即可
 适用字体类型：ttf，otf

 @param path 字体文件存放路径，
 @return 自定义字体的名称
 */
+ (NSString *)XF_GetCustomFontNameWithPath:(NSString *)path;


/**
 获取导入的自定义字体的名称数组
 并注册自定义字体到系统字体库，在程序启动后调用一次即可
 适用字体类型：ttc

 @param path 字体文件存放路径
 @return 自定义字体的名称数组
 */
+ (NSArray *)XF_GetCustomFontNameArrayWithPath:(NSString *)path;

@end
