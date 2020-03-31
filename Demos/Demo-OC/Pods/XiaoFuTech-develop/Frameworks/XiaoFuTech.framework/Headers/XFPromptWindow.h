//
//  XFPromptWindow.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/27.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFPromptWindow : NSObject

/**
 初始化

 @param windowLevel windowLevel
 */
+ (void)InitPromptWindow:(UIWindowLevel)windowLevel;


/**
 自定义显示PromptWindow

 @param msg 需要显示的文本
 @param duration 持续时间
 @param lock 是否需要锁屏
 @param hide 需要需要隐藏状态栏
 @param statusBarStyle 状态栏类型
 */
+ (void)ShowMsg:(NSString *)msg Duration:(NSTimeInterval)duration
     ScreenLock:(BOOL)lock StatusBarHide:(BOOL)hide StatusBarStyle:(UIStatusBarStyle)statusBarStyle;

/**
 自定义显示PromptWindow

 @param msg 需要显示的文本
 @param duration 自定义显示时间
 */
+ (void)ShowMsg:(NSString *)msg Duration:(NSTimeInterval)duration;

/**
 快捷显示PromptWindow

 @param msg 需要显示的文本
 */
+ (void)ShowMsg:(NSString *)msg;

/**
 隐藏PromptWindow
 */
+ (void)Hide;

@end
