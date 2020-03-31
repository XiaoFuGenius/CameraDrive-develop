//
//  UIButton+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by 胡钧昱 on 2017/9/25.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIButtonInsideLayoutAdaptiveAlignment) {
    UIButtonInsideLayoutAdaptiveAlignmentBlend = 0,  // 图片和标题完全居中，且标题覆盖于图片之上
    UIButtonInsideLayoutAdaptiveAlignmentVertical,  // 图标和标题在竖直方向上排列，上图下标题
    UIButtonInsideLayoutAdaptiveAlignmentVerticalFlip,  // 图标和标题在竖直方向上排列，上标题下图
    UIButtonInsideLayoutAdaptiveAlignmentHorizontal,  // 图标和标题在水平方向上排列，左图右标题
    UIButtonInsideLayoutAdaptiveAlignmentHorizontalFlip,  // 图标和标题在水平方向上排列，左标题右图
};

@interface UIButton (XFCategory)


/**
 快速创建一个 UIButton 控件, 所有参数都可以填nil
 */
+ (UIButton *)XF_ButtonWithColor:(UIColor *)color Image:(NSString *)image Title:(NSString *)title
                            Font:(UIFont *)font TitleColor:(UIColor *)titleColor Target:(id)target
                          Action:(SEL)action Frame:(CGRect)frame;

/**
 设置 UIButton 的背景色，采用将颜色转换为图片的方法，因为需要 Button 的 Size，所以，方法调用必须在 UIButton 的 Frame 设置之后
 */
- (void)xf_SetBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

#pragma mark - 自适应设定 UIButton 的 imageEdgeInsets 和 titleEdgeInsets 属性
/**
 自适应设定 UIButton 的 imageEdgeInsets 和 titleEdgeInsets 属性
 @param alignment 图片和标题的布局方式，居中覆盖，竖直方向，水平方向
 @param spacing 图片和标题的内间距
 @param offset 偏移量，也可以直接设置 contentEdgeInsets 属性的 top 和 left 值
 补充：1.设定合适的 Frame 很重要，2.不支持文字和图片的动态变化，或者保证动态变化的文字和图片的大小保持不变，
 */
- (void)xf_InsideLayoutAdaptiveAlignment:(UIButtonInsideLayoutAdaptiveAlignment)alignment
                                 Spacing:(CGFloat)spacing Offset:(CGPoint)offset;

#pragma mark - 设置虚线边框
/**
 设置虚线边框，因为需要 UIButton 的 Size，所以，方法调用必须在 UIButton 的 Frame 设置之后
 @param borderWidth 线的粗细
 @param borderColor 线的颜色
 @param dashPattern 决定线的单元长度
 @param isRound 是否圆形
 */
- (void)xf_SetDashLineBorderWidth:(CGFloat)borderWidth BorderColor:(UIColor *)borderColor
                      DashPattren:(CGFloat)dashPattern IsRound:(BOOL)isRound;

#pragma mark - 设置边框颜色
/**
 设置按钮的borderColor状态,最多四种
 Normal，Highlighted，Selected，Selected | Highlighted
 */
- (void)xf_SetBorderColor:(UIColor *)borderColor forState:(UIControlState)state;

/**
 更新按钮的borderColor状态，跟随在 sender.selected 属性设置之后
 */
- (void)xf_UpdateBorderStatus;



@end
