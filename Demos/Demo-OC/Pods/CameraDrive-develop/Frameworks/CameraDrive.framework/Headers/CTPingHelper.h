//
//  CTPingHelper.h
//  CameraDrive
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTPingHelper : NSObject

/* address 可以是 网址 & ip */
+ (void)PingAddress:(NSString *)address Completion:(void(^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
