//
//  CTEasyCamera.h
//  CameraDrive
//
//  Created by 胡文峰 on 2019/1/2.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTEasyCamera : NSObject

@property (nonatomic, assign) NSTimeInterval cameraStartTimeout;        // 启动超时 时间设定 默认 10s，自定义>=10.0s，可设定超大值以关闭超时处理
@property (nonatomic, assign) NSTimeInterval cameraCaptureTimeout;      // 拍照超时 时间设定 默认 10s，自定义>=10.0s，可设定超大值以关闭超时处理
@property (nonatomic, assign, readonly) BOOL cameraIsStarting;          // 摄像头是否正在启动
@property (nonatomic, assign, readonly) BOOL cameraIsCapturing;         // 摄像是否头正在采集图像

@property (nonatomic, assign) BOOL ignoredAppActivedStatus;             // 中断内部代码针对 应用前后台操作 的回应
@property (nonatomic, assign, readonly) BOOL appIsActived;              // 应用是否已激活 "applicationDidBecomeActive"
@property (nonatomic, assign, readonly) BOOL cameraIsActived;           // 摄像头是否已打开
@property (nonatomic, assign, readonly) BOOL cameraIsRestart;           // 摄像头是否正在重启

@property (nonatomic, copy) void(^startLoadingHnadler)(void);           // 摄像头启动时会触发的 Loading 启动代码
@property (nonatomic, copy) void(^startTimeoutHandler)(void);           // 摄像头启动超时会触发的回调代码，实现后超时不会回调 startHandler
@property (nonatomic, copy) void(^captureTimeoutHandler)(void);         // 摄像头采集图像超时会触发的回调代码，实现后超时不会回调 captureHandler

#pragma mark >>> 摄像头 启停 <<<
/** 较”CTCameraHelper“，增加了超时处理，应用激活状态变更时的摄像头启停处理
 启动摄像头
 @param handler ”摄像头“启动状态回调；
 注：”摄像头“意外关闭也会触发 handler 回调；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)start:(nullable CTCameraStatusHandler)handler;

/** 较”CTCameraHelper“，对增加的 超时处理+应用激活状态变更时的摄像头启停处理 进行移除
 关闭摄像头
 @param handler “摄像头”关闭回调；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)stop:(nullable CTCameraStatusHandler)handler;

#pragma mark >>> 图像采集 <<<
/** 较”CTCameraHelper“，增加了超时处理
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
 取得 CTEasyCamera 的共享实例
 @return CTEasyCamera 的共享实例
 */
+ (CTEasyCamera *_Nullable)SharedEasyCamera;

@end

NS_ASSUME_NONNULL_END
