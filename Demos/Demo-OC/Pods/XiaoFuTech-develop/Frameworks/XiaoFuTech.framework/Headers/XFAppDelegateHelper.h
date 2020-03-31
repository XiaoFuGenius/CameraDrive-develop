//
//  XFAppDelegateHelper.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/26.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const XF_ScreenLockStatusChangedNotification;

@interface XFAppDelegateHelper : NSObject

/**
 初始化操作1

 @param Block 自定义初始化操作代码块
 */
+ (void)ConfigBlock:(void (^)(void))Block;

@end
