//
//  CTCameraHelper.h
//  CameraTool
//
//  Created by xiaofutech on 2016/12/30.
//  Copyright © 2016年 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 接口回调类型，
 @param status 回调状态值 ~> 0：成功，状态正常；
 @param description 回调描述字符串；
 */
typedef void(^CTCameraStatusHandler)(NSInteger status, NSString *description);

@interface CTCameraHelper : NSObject

#pragma mark >>> 常规配置项 <<<
@property (nonatomic, assign) int       renderingBitrate;  // “视频流渲染”码率 600~1200，码率会影响图像清晰度和流畅度；默认 600；
@property (nonatomic, assign) int       ledMode;  // 切换"灯光模式"；0-标准光(表皮层)，1-偏振光(基底层)；默认 0；
// 以下属性，“摄像头” 成功启动后，变更无效
@property (nonatomic, assign) CGSize    renderingSize;  // “视频流渲染”视图的长宽；默认 16:9 图像质量 1280*720；
@property (nonatomic, assign) BOOL      isRetroflexion;  // “视频流渲染”时是否"镜像"处理；YES - "镜像"处理，可用于C端用户；默认 NO；
@property (nonatomic, strong) NSString  *ip;  // “视频流”数据传输的“网络地址”；
@property (nonatomic, assign) int       port;  // “视频流”数据传输的”端口号“，默认 1000；

#pragma mark >>> 初始化 配置 <<<
/**
 配置 “视频流”渲染视图 承载视图
 @param bearerView 承载视图
 @param handler 配置完成回调
 注：启动“摄像头”之前调用，一般在 viewDidLoad 或 viewDidAppear 中调用；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)loadBearerView:(UIView *)bearerView Handler:(CTCameraStatusHandler)handler;

/**
 释放 “视频流”渲染视图 承载视图
 @param handler 释放完成回调
 注：关闭“摄像头”之后调用，一般在 viewDidDisappear 中调用；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)unloadBearerView:(CTCameraStatusHandler)handler;

#pragma mark >>> 摄像头 启停 <<<
/**
 启动摄像头
 @param handler ”摄像头“启动状态回调；
 注：”摄像头“意外关闭也会触发 handler 回调；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)start:(CTCameraStatusHandler)handler;

/**
 关闭摄像头
 @param handler “摄像头”关闭回调；
 注：建议合理使用 handler 回调进行交互；
 */
- (void)stop:(CTCameraStatusHandler)handler;

#pragma mark >>> 图像采集 <<<
/**
 图像采集
 @param rgbFilePath 标准光(表皮层) 图像地址
 @param plFilePath 偏振光(基底层) 图像地址
 @param handler 采集完成回调
 */
- (void)captureRgbFilePath:(NSString *)rgbFilePath PlFilePath:(NSString *)plFilePath
                   Handler:(CTCameraStatusHandler)handler;

#pragma mark >>> 共享实例 <<<

/**
 取得 CTCameraHelper 的共享实例
 @return CTCameraHelper 的共享实例
 */
+ (CTCameraHelper *)SharedCameraHelper;

@end
