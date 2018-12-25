//
//  UIColor+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (XFCategory)

///获取一个随机颜色
+ (UIColor *)XF_GetArc4randomColor:(float)alpha;

///将一个颜色字符串转成UIColor
+ (UIColor *)XF_ColorWithHexString:(NSString *)hexString;
+ (UIColor *)XF_ColorwithHexString:(NSString *)hexString Alpha:(CGFloat)alpha;
+ (NSString *)XF_HexStringWithColor:(UIColor *)color HasAlpha:(BOOL)hasAlpha;

- (int)xf_GetRed;
- (int)xf_GetGreen;
- (int)xf_GetBlue;
- (CGFloat)xf_GetAlpha;

///获取颜色color对应的整数值int
- (int)xf_GetIntValue;

///获取颜色color对应的浮点数值double
- (double)xf_GetDoubleValue;

//判断颜色是不是亮色 - 未验证
- (BOOL)xf_IsLightColor;

//获取RGB值 - 未验证
- (void)xf_GetRGBComponents:(CGFloat [3])components;


@end
