//
//  XFAppDelegate.h
//  Demo-OC
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (CGFloat)GetWidth;
+ (CGFloat)GetHeight;
+ (void)XF_ApplicationOpenSettingsType:(int)type;

@end

NS_ASSUME_NONNULL_END
