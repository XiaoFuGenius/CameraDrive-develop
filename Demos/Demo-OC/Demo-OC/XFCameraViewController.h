//
//  XFCameraViewController.h
//  Demo-OC
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XFCameraViewController : UIViewController

@property (nonatomic, strong) NSDictionary *param;  // 参数，IP地址
@property (nonatomic, copy) void(^logHandler)(NSString *log);  // 日志回调

@end
