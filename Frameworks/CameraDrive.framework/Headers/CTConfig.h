//
//  CTConfig.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

// 蓝牙固件升级状态码
#define     OTA_CONNECT_OK                      0x01
#define     OTA_CONNECT_ERROR                   0x02
#define     OTA_CMD_IND_FW_INFO                 0x03
#define     OTA_CMD_IND_FW_DATA                 0x04
#define     OTA_CMD_REQ_VERIFY_FW               0x05
#define     OTA_CMD_REQ_EXEC_FW                 0x06
#define     OTA_RSP_SUCCESS                     0x07
#define     OTA_RSP_PKT_CHECKSUM_ERROR          0x08
#define     OTA_RSP_PKT_LEN_ERROR               0x09
#define     OTA_RSP_DEVICE_NOT_SUPPORT_OTA      0x0A
#define     OTA_RSP_FW_SIZE_ERROR               0x0B
#define     OTA_RSP_FW_VERIFY_ERROR             0x0C
#define     OTA_RSP_PROGRESS                    0x0D
#define     OTA_DISCONNECT                      0x0E
#define     OTA_OK                              0x0F

// 核心固件升级状态码
#define     CORE_OTA_AP                                 0x01
#define     CORE_OTA_SEND_UPDATE                        0x02
#define     CORE_OTA_SOCKET_LINSTEN                     0x03
#define     CORE_OTA_SOCKET_ACCPET                      0x04
#define     CORE_OTA_SOCKET_SEND_LENGTH                 0x05
#define     CORE_OTA_SOCKET_SEND_DATA                   0x06
#define     CORE_OTA_SOCKET_SEND_PROGRESS               0x07
#define     CORE_OTA_DATA_CRC                           0x08
#define     CORE_OTA_DATA_UPDATE                        0x09
#define     CORE_OTA_OK                                 0x0a
#define     CORE_OTA_ERROR_AP                           0x0b
#define     CORE_OTA_ERROR_SEND_UPDATE                  0x0c
#define     CORE_OTA_ERROR_SOCKET_LINSTEN               0x0d
#define     CORE_OTA_ERROR_SOCKET_ACCPET_TIMEOUT        0x0e
#define     CORE_OTA_ERROR_SOCKET_DISCONNECT            0x0f
#define     CORE_OTA_ERROR_DATA_CRC                     0x10
#define     CORE_OTA_ERROR_DATA_UPDATE                  0x11

typedef void(^CTConfigDebugLogHandler)(NSString *log);
typedef void(^CTConfigBlueStripDetectionHandler)(UIImage *blueStripImage);

@interface CTConfig : NSObject

#pragma mark >>> 常规配置项 <<<
/**
 debug开关
 开启以后，终端会输出debug日志，默认 关闭；
 */
@property (nonatomic, assign) BOOL debugEnable;

/**
 debug日志类型开关
 注：0：默认(类名)，1(具体方法)，2(附加当前线程)
 */
@property (nonatomic, assign) NSInteger debugLogType;

/**
 debug log handler
 赋值后，内部方法会在适当时机调用，并返回关键日志；
 */
@property (nonatomic, copy) CTConfigDebugLogHandler debugLogHandler;

/**
 蓝条检测 开关
 开启以后，摄像头启动时，对 前十帧图像 执行 蓝条检测 算法，默认关闭；
 对该Block赋值即意味着开启蓝条检测，同时，对于检测到的蓝条图片，会通过Block回传
 */
@property (nonatomic, copy) CTConfigBlueStripDetectionHandler blueStripDetectionHandler;

/**
 热点模式，信道指定（STA模式，信道由产生WiFi信号的路由器本身决定）
 -1 随机信道，1 - 13 指定信道(不建议选择 12，13 信道)，默认随机信道；
 另：当前 Android 默认 信道9
 */
@property (nonatomic, assign) NSInteger channelSetting;

/**
 指定的 分隔字符串数组
 拆分 设备 的蓝牙识别字符串，拆分成 Name 和 BindID；默认 @[@"!@"]；
 */
@property (nonatomic, strong) NSArray *splitStrings;

/**
 蓝牙扫描时，外围设备的保活时间，默认 2s，自定义时间 >2s
 超过保活时间即被视为该外围设备已失活，将从已扫描到的设备列表中移除；
 注1：-1 指定，不执行 相关的保活逻辑，设备扫描到一次，将会始终存在于设备列表中；
 注2：当前状态 默认开启，默认 2s；
 */
@property (nonatomic, assign) NSTimeInterval peripheralAliveTime;

/**
 StartOV788:1 延迟 500 ms 测试，默认关闭
 */
@property (nonatomic, assign) BOOL delayStartOv788Test;

/**
 StartOV788:1 延迟 500 ms 测试时间，默认 500 ms
 */
@property (nonatomic, assign) double delayStartOv788Time;

/**
 获取 手机当前连接 WiFi 的 ssid
 @return ssid
 */
+ (NSString *)GetSSID;

/**
 校验 图片中是否 有 蓝条
 @param image 图片数据
 @return 校验结果
 */
+ (BOOL)ExamineBlueStripImage:(UIImage *)image;

#pragma mark >>> LIFE CYCLE <<<
/**
 取得 CTConfig 的共享实例
 @return CTConfig 的共享实例
 */
+ (CTConfig *)SharedConfig;

@end
