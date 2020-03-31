//
//  XFGraphicViewHelper.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/27.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFGraphicViewHelper : NSObject

///顺时针绘制...
+ (UIView *)DrawGraphicViewPoints:(NSArray <NSArray <NSNumber *>*>*)points Frame:(CGRect)frame
                        LineWidth:(CGFloat)lineWidth
                      StrokeColor:(UIColor *)strokeColor FillColor:(UIColor *)fillColor;

///顺时针绘制...仅针对直线
+ (UIView *)DrawGraphicLinePoints:(NSArray <NSArray <NSNumber *>*>*)points Frame:(CGRect)frame
                        LineWidth:(CGFloat)lineWidth
                      StrokeColor:(UIColor *)strokeColor SmoothHT:(BOOL)smoothHT;

@end
