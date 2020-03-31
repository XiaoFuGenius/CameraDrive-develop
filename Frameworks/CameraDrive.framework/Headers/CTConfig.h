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

#pragma mark
#pragma mark 常规配置项

/// 终端日志输出开关，默认 关闭；
@property (nonatomic, assign) BOOL debugEnable;

/// 终端日志输出类型，注：0：默认(类名)，1(具体方法)，2(附加当前线程)
@property (nonatomic, assign) NSInteger debugLogType;

/// 终端日志输出回调
@property (nonatomic, copy) CTConfigDebugLogHandler debugLogHandler;

/// 蓝条检测，可选类型，默认 0
/// 0：仅检测摄像头成功启动后的前十帧图像；1：对每一帧图像都进行检测（可能会影响渲染的流畅度）；
@property (nonatomic, assign) NSInteger blueStripDetectionType;

/// 蓝条检测确认回调，默认关闭。赋值即意味着开启检测，对于确认存在蓝条的图片帧，会通过回调传出；
@property (nonatomic, copy) CTConfigBlueStripDetectionHandler blueStripDetectionHandler;

/// 热点模式，指定信道。（STA模式，信道由产生 wifi 信号的路由器决定）
/// -1 随机信道，1 - 13 指定信道(不建议选择 12，13 信道)，默认随机信道；
/// 注：当前 Android 默认 信道9
@property (nonatomic, assign) NSInteger channelSetting;

/// 指定的 分隔字符串数组
/// 拆分 设备 的蓝牙识别字符串，拆分成 Name 和 BindID；默认 @[@"!@"]；
@property (nonatomic, strong) NSArray *splitStrings;

/// 蓝牙扫描时，外围设备的保活时间，默认 2s，自定义时间 >2s
/// 超过保活时间即被视为该外围设备已失活，将从已扫描到的设备列表中移除；
/// 注1：-1 指定，不执行 相关的保活逻辑，设备扫描到一次，将会始终存在于设备列表中；
/// 注2：当前状态 默认开启，默认 2s；
@property (nonatomic, assign) NSTimeInterval peripheralAliveTime;

/// StartOV788:1 延迟 500 ms 测试，默认关闭
@property (nonatomic, assign) BOOL delayStartOv788Test;

/// StartOV788:1 延迟 500 ms 测试时间，默认 500 ms
@property (nonatomic, assign) double delayStartOv788Time;

#pragma mark
#pragma mark Public Methods

/// 请求 手机当前连接 wifi 的 ssid
/// @param locRequest 请求位置权限
/// @param callback 请求完成回调
/// callback（iPhone_ssid）手机当前连接 wifi 的 ssid，可能为空
/// callback（locRes）位置授权结果，可能为空，或 {@"authorized":@(授权状态)，@"status":@(CTUserAuthorizationStatus)}
/// 注：locRequest 源于 iOS 13 新的隐私政策要求；低版本系统不受该参数影响。
- (void)wifiSSID:(BOOL)locRequest Callback:(void (^)(NSString *iPhone_ssid, NSDictionary *locRes))callback;

/// 校验 图片中是否存在<蓝条>情况
/// @param image 待校验图片数据
- (BOOL)examineBlueStripImage:(UIImage *)image;

#pragma mark
#pragma mark LIFE CYCLE

/// CTConfig 的共享实例
+ (CTConfig *)Shared;

@end
