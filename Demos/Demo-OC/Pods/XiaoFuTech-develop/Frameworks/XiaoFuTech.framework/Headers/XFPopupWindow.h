//
//  XFPopupWindow.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/27.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFPopupWindow : NSObject

/**
 初始化

 @param windowLevel windowLevel
 */
+ (void)InitPopupWindow:(UIWindowLevel)windowLevel;

+ (void)UpdateBasicUIStatusBarHide:(BOOL)hide StatusBarStyle:(UIStatusBarStyle)style;

+ (void)ShowBlock:(void (^)(UIView *basicView))block;

+ (void)HideBlock:(void (^)(UIWindow* window))block;

+ (void)HideAll;

@end
