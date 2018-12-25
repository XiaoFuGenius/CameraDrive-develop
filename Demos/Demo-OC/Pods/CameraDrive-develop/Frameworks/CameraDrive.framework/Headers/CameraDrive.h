//
//  CameraDrive.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

/**
 CameraDrive版本号
 更新时间：2018.12.19 09:01
 */
#define CameraDrive_SDK_VERSION @"1.0.5"

#import <UIKit/UIKit.h>

// 预设
#import "CTConfig.h"
#import "CTWiFiHelper.h"
#import "CTPingHelper.h"
#import "CTHotspotHelper.h"

// 蓝牙&联网 连接控制
#import "CTBleHelper.h"  // 基础
#import "CTEasyLinker.h"  // 推荐
#import "CTEasyUpgrade.h"  // 推荐

// 摄像头 控制
#import "CTCameraHelper.h"
