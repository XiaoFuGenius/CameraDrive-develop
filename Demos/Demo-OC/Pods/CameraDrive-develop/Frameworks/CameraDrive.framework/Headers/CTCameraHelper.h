//
//  CTCameraHelper.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 接口回调类型，
 @param status 回调状态值 ~> 0：成功，状态正常；-1：失败；
 @param description 回调描述字符串；
 */
typedef void(^CTCameraStatusHandler)(NSInteger status, NSString * _Nullable description);

/**
 因 蓝条检测 触发的摄像头重启通知
 */
extern NSNotificationName const _Nullable CT_Camera_RestartByBSD;

@interface CTCameraHelper : NSObject

#pragma mark >>> 常规配置项 <<<
@property (nonatomic, assign) int       renderingBitrate;  // “视频流渲染”码率 600~1200，码率会影响图像清晰度和流畅度；默认 600；
@property (nonatomic, assign) int       ledMode;  // 切换"灯光模式"；0-标准光(表皮层)，1-偏振光(基底层)；默认 0；
@property (nonatomic, strong) NSString  * _Nullable ip;  // “视频流”数据传输的“网络地址”；
@property (nonatomic, assign) int       port;  // “视频流”数据传输的”端口号“，默认 1000；
// 以下属性，“loadBearerView” 成功调用后，变更无效
@property (nonatomic, assign) BOOL      isRetroflexion;  // “视频流渲染”时是否"镜像"处理；YES - "镜像"处理，可用于C端用户；默认 NO；
@property (nonatomic, assign, readonly) BOOL isBlueStripConfirmed;  // 未成功激活摄像头时，触发原因是否为 蓝条检测

#pragma mark >>> 初始化 配置 <<<
/**
 配置 “视频流”渲染视图 承载视图
 @param bearerView 承载视图
 @param handler 配置完成回调
 注：启动“摄像头”之前调用，一般在 viewDidLoad 或 viewDidAppear 中调用；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)loadBearerView:(UIView *_Nullable)bearerView
               Handler:(nullable CTCameraStatusHandler)handler;

/**
 释放 “视频流”渲染视图 承载视图
 @param handler 释放完成回调
 注：关闭“摄像头”之后调用，一般在 viewDidDisappear 中调用；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)unloadBearerView:(nullable CTCameraStatusHandler)handler;

#pragma mark >>> 摄像头 启停 <<<
/**
 启动摄像头
 @param handler ”摄像头“启动状态回调；
 注：”摄像头“意外关闭也会触发 handler 回调；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)start:(nullable CTCameraStatusHandler)handler;

/**
 关闭摄像头
 @param handler “摄像头”关闭回调；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)stop:(nullable CTCameraStatusHandler)handler;

#pragma mark >>> 图像采集 <<<
/**
 图像采集
 @param rgbFilePath 标准光(表皮层) 图像地址
 @param plFilePath 偏振光(基底层) 图像地址
 @param handler 采集完成回调
 */
- (void)captureRgbFilePath:(NSString *_Nullable)rgbFilePath
                PlFilePath:(NSString *_Nullable)plFilePath
                   Handler:(nullable CTCameraStatusHandler)handler;

#pragma mark >>> 共享实例 <<<

/**
 取得 CTCameraHelper 的共享实例
 @return CTCameraHelper 的共享实例
 */
+ (CTCameraHelper *_Nullable)SharedCameraHelper;

@end
