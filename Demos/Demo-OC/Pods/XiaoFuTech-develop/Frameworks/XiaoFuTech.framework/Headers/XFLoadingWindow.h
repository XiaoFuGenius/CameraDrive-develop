//
//  XFLoadingWindow.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/27.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFLoadingWindow : NSObject

/**
 初始化

 @param windowLevel windowLevel
 */
+ (UIWindow *)InitLoadingWindow:(UIWindowLevel)windowLevel;

/**
 显示LoadingWindow

 @param timeOut 设置超时
 @param lock 是否锁屏，不锁屏的情况要注意在合适的地方调用隐藏方法
 @param hide 是否隐藏状态栏，此属性用作配合当前视图状栏态的显示状态
 @param statusBarStyle 状态栏类型
 @param cancel 点击取消按钮后执行的代码块，nil则不显示取消按钮
 */
+ (void)ShowTimeOut:(NSTimeInterval)timeOut ScreenLock:(BOOL)lock StatusBarHide:(BOOL)hide
     StatusBarStyle:(UIStatusBarStyle)statusBarStyle CancelBlock:(void (^)(void))cancel;

/**
 显示LoadingWindow

 @param timeOut 设置超时
 @param cancel 点击取消按钮后执行的代码块，nil则不显示取消按钮
 */
+ (void)ShowTimeOut:(NSTimeInterval)timeOut CancelBlock:(void (^)(void))cancel;


/**
 快捷显示LoadingWindow
 @param screenLock 是否锁屏
 */
+ (void)ShowSreenLock:(BOOL)screenLock;

/**
 快捷显示LoadingWindow
 */
+ (void)Show;

/**
 隐藏LoadingWindow
 */
+ (void)Hide;


@end
