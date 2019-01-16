//
//  UIViewController+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XFBackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)xf_NavigationShouldPopOnBackButton;
@end

@interface UIViewController (XFCategory) <XFBackButtonHandlerProtocol>

@property (nonatomic, strong) id xf_Parameters;

- (void)xf_SetNavigationTitleText:(NSString *)text;
- (void)xf_SetNavigationTitleTextFont:(UIFont *)font;
- (void)xf_SetNavigationTitleTextColor:(UIColor *)color;
- (void)xf_SetNavigationLeftItems:(NSArray *)items;
- (void)xf_SetNavigationRightItems:(NSArray *)items;

@end
