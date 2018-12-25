//
//  XFAppWindow.h
//  XiaoFuTechHelper
//
//  Created by xiaofutech on 2017/9/27.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XFAppWindowAnimation) {
    XFAppWindowAnimationNone = 0,
    XFAppWindowAnimationFade,
    XFAppWindowAnimationHorizon,
    XFAppWindowAnimationVertical,
};

typedef id (^XFLoginCtrInit)(void);
typedef id (^XFRootCtrInit)(void);

@interface XFAppWindow : NSObject

/**
 初始化

 @param windowLevel windowLevel
 */
+ (void)InitAppWindow:(UIWindowLevel)windowLevel;

/**
 Login & Root Window初始化

 @param init 是否首次初始化，NO用于语言切换等场景下进行时使用
 @param loginCtr 登录控制器，可以是控制器对象或者字符串名
 @param rootCtr 根控制器，可以是控制器对象或者字符串名
 */
+ (void)AppWindowInit:(BOOL)init LoginCtr:(XFLoginCtrInit)loginCtr RootCtr:(XFRootCtrInit)rootCtr;

/**
 是否显示 Login Window

 @param show YES-显示，NO-隐藏
 */
+ (void)ShowLoginWindow:(BOOL)show AnimType:(XFAppWindowAnimation)animType;

/**
 LoginWindow & RootWindow 都收起键盘
 */
+ (void)EndEditing;

+ (UIWindow *)LoginWindow;

+ (UIWindow *)RootWindow;

@end
