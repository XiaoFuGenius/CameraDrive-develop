//
//  UITextField+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (XFCategory)

+ (UITextField *)XF_TextFieldColor:(UIColor *)color Placeholder:(NSString *)placeholder
                              Font:(UIFont *)font TextColor:(UIColor *)textColor
                             Frame:(CGRect)frame;

- (void)xf_SetPlaceholderTextFont:(UIFont *)font;
- (void)xf_SetPlacehodlerTextColor:(UIColor *)color;

@end
