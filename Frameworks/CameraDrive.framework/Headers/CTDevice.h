//
//  CTDevice.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/11/30.
//  Copyright © 2018 郑炜钢. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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


@interface CTDevice : NSObject
@property (nonatomic, strong) NSDate *aliveDate;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *BindID;
@property (nonatomic, strong) NSNumber *RSSI;
@end

NS_ASSUME_NONNULL_END
