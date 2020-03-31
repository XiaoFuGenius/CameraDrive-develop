//
//  UITextField+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by 胡钧昱 on 2017/9/25.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (XFCategory)

+ (UITextField *)XF_TextFieldColor:(UIColor *)color Placeholder:(NSString *)placeholder
                              Font:(UIFont *)font TextColor:(UIColor *)textColor
                             Frame:(CGRect)frame;

- (void)xf_SetPlaceholderTextFont:(UIFont *)font;
- (void)xf_SetPlacehodlerTextColor:(UIColor *)color;

@end
