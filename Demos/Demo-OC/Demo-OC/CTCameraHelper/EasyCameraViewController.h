//
//  EasyCameraViewController.h
//  Demo-OC
//
//  Created by 胡文峰 on 2019/1/3.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EasyCameraViewController : UIViewController

@property (nullable, nonatomic, strong) NSDictionary *param;  // 参数，IP地址
@property (nullable, nonatomic, copy) void(^logHandler)(NSString *log);  // 日志回调

@end

NS_ASSUME_NONNULL_END
