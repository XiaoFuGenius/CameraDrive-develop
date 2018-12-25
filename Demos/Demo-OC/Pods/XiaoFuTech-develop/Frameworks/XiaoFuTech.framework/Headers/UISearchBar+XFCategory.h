//
//  UISearchBar+XFCategory.h
//  XiaoFuTech
//
//  Created by xiaofutech on 2018/7/4.
//  Copyright © 2018年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (XFCategory)

- (UITextField *)xf_GetTextField;

- (UIButton *)xf_GetCancelButton;

- (void)xf_SetNewBackgroundColor:(UIColor *)backgroundColor;

- (void)xf_RemoveTapGestureRecognizer;

@end
