//
//  UIAlertController+XFCategory.h
//  XiaoFuTech
//
//  Created by 胡钧昱 on 2018/7/4.
//  Copyright © 2018年 EternalTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (XFCategory)

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *messageFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *messageColor;

///获取默认设置
- (void)xf_GetConfigSettings;
///所有分类新建的属性的设置都需要下面这个方法来更新
- (void)xf_UpdateAlertController:(NSString *)title Message:(NSString *)message;

@end
