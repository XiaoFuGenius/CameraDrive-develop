//
//  UILabel+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by 胡钧昱 on 2017/9/25.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (XFCategory)

+ (UILabel *)XF_LabelWithColor:(UIColor *)color Text:(NSString *)text Font:(UIFont *)font
                     TextColor:(UIColor *)textColor Frame:(CGRect)frame;


/**
 高度自适应
 @param lineNum 行数
 */
- (void)xf_FitMutiLine:(int)lineNum;

@end
