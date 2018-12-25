//
//  UIView+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XFCategory)

+ (UIView *)XF_ViewWithColor:(UIColor *)color Frame:(CGRect)frame;


/**
 创建带有渐变的LableView
 */
+ (UIView *)XF_GradientEffectLabelViewText:(NSString *)text Font:(UIFont *)font
                                 TextColor:(UIColor *)textColor Frame:(CGRect)frame
                              EffectColors:(NSArray<UIColor *> *)colors
                                 Locations:(NSArray<NSNumber *> *)locations
                                StartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint;

#pragma mark - Quartz2D
/**
 简单全视图填充颜色
 @param color 填充的颜色
 */
- (void)xfQuartz2D_FillColor:(UIColor *)color;

/**
 绘制正方形网格图
 @param spacing 网格间距
 @param strokeWidth 网格线宽
 @param strokeColor 网格线颜色
 @param fillColor 填充颜色
 */
- (void)xfQuartz2D_AddGridPatternSpacing:(CGFloat)spacing
                             StrokeWidth:(CGFloat)strokeWidth
                             StrokeColor:(UIColor *)strokeColor
                               FillColor:(UIColor *)fillColor;

/** 线性渐变
 在当前上下文对象中绘制径向渐变，需要在 drawRect: 方法中调用
 @param colors 渐变颜色数组
 @param locations 关键点数组，与渐变颜色数组配合，数组个数相同
 @param startPoint 渐变起始点
 @param endPoint 渐变终点
 @param clipToRects 裁剪区域设置
 @param options 渐变填充方式
 */
- (void)xfQuartz2D_AddColorGradientEffectLinearColors:(NSArray<UIColor *> *)colors
                                            Locations:(NSArray<NSNumber *> *)locations
                                           StartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint
                                          ClipToRects:(NSArray<NSValue *> *)clipToRects
                                              Options:(CGGradientDrawingOptions)options;
/** 径向渐变
 在当前上下文对象中绘制径向渐变，需要在 drawRect: 方法中调用
 @param colors 渐变颜色数组
 @param locations 关键点数组，与渐变颜色数组配合，数组个数相同
 @param startPoint 渐变起始点
 @param startRadius 渐变半径
 @param endPoint 渐变终点
 @param endRadius 渐变半径
 @param clipToRects 裁剪区域设置
 @param options 渐变填充方式
 */
- (void)xfQuartz2D_AddColorGradientEffectRadialColors:(NSArray<UIColor *> *)colors
                                            Locations:(NSArray<NSNumber *> *)locations
                                           StartPoint:(CGPoint)startPoint
                                          StartRadius:(CGFloat)startRadius
                                             EndPoint:(CGPoint)endPoint
                                            EndRadius:(CGFloat)endRadius
                                          ClipToRects:(NSArray<NSValue *> *)clipToRects
                                              Options:(CGGradientDrawingOptions)options;

#pragma mark - Other Quick Methods
///利用UIView，生成一张渐变颜色的图片，colors；UIColor对象—渐变颜色数组，locations；NSNumber对象-颜色渐变关键位置(取值范围0-1)
+ (UIImage *)XF_GenerateColorGradientEffectImageColors:(NSArray <UIColor *>*)colors
                                             Locations:(NSArray <NSNumber *>*)locations
                                            StartPoint:(CGPoint)startPoint
                                              EndPoint:(CGPoint)endPoint Size:(CGSize)size;

///添加阴影效果，视图的clipsToBounds属性值必须为NO，阴影颜色，阴影偏移量，阴影半径，阴影透明度
- (void)xf_AddShadowEffectColor:(UIColor *)color Offset:(CGSize)offset
                         Radius:(CGFloat)radius Opacity:(CGFloat)opacity;
///添加阴影效果，视图的clipsToBounds属性值必须为NO，阴影颜色，阴影偏移量，阴影路径，阴影透明度
- (void)xf_AddShadowEffectColor:(UIColor *)color Offset:(CGSize)offset
                           Path:(UIBezierPath *)path Opacity:(CGFloat)opacity;

///添加颜色渐变效果，colors；UIColor对象—渐变颜色数组，locations；NSNumber对象-颜色渐变关键位置(取值范围0-1)
- (CAGradientLayer *)xf_AddColorGradientEffectColors:(NSArray <UIColor *>*)colors
                                           Locations:(NSArray <NSNumber *>*)locations
                                          StartPoint:(CGPoint)startPoint
                                            EndPoint:(CGPoint)endPoint Frame:(CGRect)frame;

///边框虚线化
- (CAShapeLayer *)xf_AddDashLineBorderWidth:(CGFloat)borderWidth BorderColor:(UIColor *)borderColor
                                DashPattren:(CGFloat)dashPattern IsRound:(BOOL)isRound;

///获取某个像素点的颜色值
- (UIColor *)xf_ColorAtPixelPoint:(CGPoint)point Alpha:(CGFloat)alpha;

///通过自身生成Image图片
- (UIImage *)xf_TransformToImage;

///找到承载当前视图的控制器
- (UIViewController *)xf_FindViewController;
///找到承载当前视图的Window
- (UIWindow *)xf_FindWindow;
///计算出当前视图相对于手机屏幕的绝对位置
- (CGRect)xf_GetRelativeFrame;

#pragma mark - basics
- (CGFloat)xf_GetX;
- (CGFloat)xf_GetY;
- (CGFloat)xf_GetWidth;
- (CGFloat)xf_GetHeight;
- (CGFloat)xf_GetTop;
- (CGFloat)xf_GetBottom;
- (CGFloat)xf_GetLeft;
- (CGFloat)xf_GetRight;
- (void)xf_SetX:(CGFloat)x;
- (void)xf_SetY:(CGFloat)y;
- (void)xf_SetWidth:(CGFloat)width;
- (void)xf_SetHeight:(CGFloat)height;

@end
