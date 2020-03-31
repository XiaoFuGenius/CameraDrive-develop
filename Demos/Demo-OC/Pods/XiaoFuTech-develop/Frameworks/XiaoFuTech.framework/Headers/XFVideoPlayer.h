//
//  XFVideoPlayer.h
//  XiaoFuTech
//
//  Created by 胡钧昱 on 2018/11/21.
//  Copyright © 2018 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XFVideoPlayer : NSObject

/**
 控制台输出日志 打开
 */
+ (void)LogEnabled;

/**
 设置展示 Window 的显示层级
 PlayWithUrl:InView:方法，参数 view 设置为 nil 时会加载一个 window 来展示视频播放视图
 @param windowLevel 展示 window 的显示层级
 */
+ (void)SetWindowLevel:(UIWindowLevel)windowLevel;

/**
 视频播放. 支持类型 [@".mov", @".mp4", @".mpv", @".3gp"]
 @param url 视频播放地址 支持 网络 & 本地
 @param view 视频播放控制器 上一级控制器的视图
 */
+ (void)PlayWithUrl:(nullable NSString *)url InView:(nullable UIView *)view;

@end

NS_ASSUME_NONNULL_END
