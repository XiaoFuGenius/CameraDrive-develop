//
//  XFImageHelper.h
//  XiaoFuTech
//
//  Created by xiaofutech on 2017/11/19.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XFImageHelper : NSObject

/**
 设定相关配置
 @param settings 配置字典，
 字典示例：
 @{@"logEnable":@(NO), /// 内部运行监测日志，输出至控制台
   @"cachesMaxSize":@(40.0f*1000*1000), /// 运行内存缓存上限
   @"threadMaxNum":@(8), /// 图片下载线程数上限
 }
 @return 配置完成后的字典
 */
+ (NSDictionary *)ConfigSettings:(NSDictionary *)settings;

/**
 有网状态下自动下载图片数据并填充
 @param imageView 待填充图片控件
 @param url 图片下载地址
 */
+ (void)DownloadImageFillView:(UIImageView *)imageView Url:(NSString *)url;

/**
 有网状态下自动下载图片数据并填充
 @param imageView 待填充图片控件
 @param placeholderImage 占位图片
 @param url 图片下载地址
 */
+ (void)DownloadImageFillView:(UIImageView *)imageView PlaceholderImage:(UIImage *)placeholderImage
                          Url:(NSString *)url;

/**
 有网状态下自动下载图片数据并填充
 @param imageView 待填充图片控件
 @param placeholderImage 占位图片
 @param completed 下载完成回调
 @param url 图片下载地址
 */
+ (void)DownloadImageFillView:(UIImageView *)imageView PlaceholderImage:(UIImage *)placeholderImage
                      Url:(NSString *)url
                Completed:(void (^)(UIImageView *imageView, UIImage *image))completed;

/**
 获取 XFImageHelper 创建的图片文件夹 的物理内存占用值
 @return 当前物理内存占用值
 */
+ (long long)GetAllCachesSize;

/**
 清除 XFImageHelper 创建的图片文件夹，同时删除所有缓存数据
 @param completed 清除完成回调
 */
+ (void)DeleteAllCachesCompleted:(void (^)(BOOL success, long long cachesSize))completed;

@end
