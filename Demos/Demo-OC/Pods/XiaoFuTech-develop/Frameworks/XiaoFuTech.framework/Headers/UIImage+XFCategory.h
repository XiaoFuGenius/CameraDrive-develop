//
//  UIImage+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XFCategory)

#pragma mark - 旋转相关
/**
 修正图片的方向
 @return 重新修正方向的图片
 */
- (UIImage *)xf_fixOrientation;

/**
 按给定方向旋转图片
 @param orientation 旋转方向
 @return 完成旋转的图片
 */
- (UIImage *)xf_updateOrientation:(UIImageOrientation)orientation;

/**
  垂直翻转
 @return 完成翻转的图片
 */
- (UIImage *)xf_flipVertical;

/**
 水平翻转
 @return 完成翻转的图片
 */
- (UIImage *)xf_flipHorizontal;

/**
 将图片旋转degrees角度
 @param degrees 角度值
 @return 完成旋转的图片
 */
- (UIImage *)xf_imageRotatedByDegrees:(CGFloat)degrees;

/**
 将图片旋转radians弧度
 @param radians 弧度值
 @return 完成旋转的图片
 */
- (UIImage *)xf_imageRotatedByRadians:(CGFloat)radians;

#pragma mark - 图片处理相关 颜色
/**
 用颜色创建图片
 @param color 颜色
 @param size 尺寸
 @return 创建完成的图片
 */
+ (UIImage *)XF_ImageWithColor:(UIColor *)color size:(CGSize)size;

/**
 修改图片颜色，仅保留透明度信息
 @param tintColor 修改的颜色
 @return 修改完成的图片
 */
- (UIImage *)xf_ImageWithTintColor:(UIColor *)tintColor;

/**
 修改图片颜色，保留灰度信息 + 保留透明度信息
 @param tintColor 修改的颜色
 @return 修改完成的图片
 */
- (UIImage *)xf_ImageWithGradientTintColor:(UIColor *)tintColor;

/**
 修改图片颜色
 @param tintColor 修改的颜色
 @return 修改完成的图片
 备注：会自动增加保留透明度信息
 */
- (UIImage *)xf_ImageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

#pragma mark - 图片关键数据获取相关
/**
 获取灰度图
 @return 当前图片的灰度图
 */
- (UIImage *)xf_convertToGrayImage;

/**
 取图片上某个像素点的颜色值
 @param point 像素点
 @param alpha 修改该颜色的透明度
 @return 获取修改完成的颜色值
 */
- (UIColor *)xf_ColorAtPixelPoint:(CGPoint)point Alpha:(CGFloat)alpha;

/**
 判断图片是否偏黑
 @return 判定结果
 */
- (BOOL)xf_isBlackColor;

#pragma mark - 截图相关
/**
 代码截图
 @param view 支持UIView及其子类
 @param cropRect 裁剪区域
 @return 裁剪完成的图片
 */
+ (UIImage *)XF_Captured:(id)view CropRect:(CGRect)cropRect;
+ (UIImage *)XF_CapturedView:(UIView *)view;
+ (UIImage *)XF_CapturedScrollView:(UIScrollView *)scrollView;
+ (UIImage *)XF_CapturedTableView:(UITableView *)tableView;

/**
 修改图片尺寸
 @param scale 缩放比例
 @return 修改完成的图片
 */
- (UIImage *)xf_imageToScale:(float)scale;
- (UIImage *)xf_imageAutoSize:(CGSize)size;
- (UIImage *)xf_imageByScalingToSize:(CGSize)size;

#pragma mark - 待分析
- (UIImage *)xf_grayImage;
- (UIImage *)xf_getSubImageWithRect:(CGRect)rect;

#pragma mark - 高斯模糊，需要整理
+ (UIImage *)XF_CoreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;
+ (UIImage *)XF_BoxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;
+ (UIImage *)XF_BlurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;
- (UIImage *)xf_blurryWithBlurLevel:(CGFloat)blur;
- (UIImage *)xf_applyLightEffect;
- (UIImage *)xf_applyExtraLightEffect;
- (UIImage *)xf_applyDarkEffect;
- (UIImage *)xf_applyTintEffectWithColor:(UIColor *)tintColor;
- (UIImage *)xf_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor
              saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
