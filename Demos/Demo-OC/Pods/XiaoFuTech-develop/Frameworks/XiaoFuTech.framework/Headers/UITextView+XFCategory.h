//
//  UITextView+XFCategory.h
//  XiaoFuTech
//
//  Created by 胡钧昱 on 2017/11/26.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (XFCategory)

@property (nonatomic, strong) NSString *xf_placeholder;

+ (UITextView *)XF_TextViewColor:(UIColor *)color Font:(UIFont *)font
                       TextColor:(UIColor *)textColor Frame:(CGRect)frame;

- (void)xf_updatePlaceholderShowStatus;
- (void)xf_updatePlaceholderBounds:(CGRect)bounds;
- (void)xf_setPlaceholderFont:(UIFont *)font;
- (void)xf_setPlaceholderColor:(UIColor *)color;

@end
