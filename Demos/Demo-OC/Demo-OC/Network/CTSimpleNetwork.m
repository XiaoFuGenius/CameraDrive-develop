//
//  CTSimpleNetwork.m
//  Demo-OC
//
//  Created by 胡文峰 on 2019/1/15.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

#import "CTSimpleNetwork.h"

@implementation CTSimpleNetwork

+ (BOOL)AdditionalProcessForPostHttpParamSettingManager:(AFHTTPSessionManager *)manager
{
    /** 接口数据返回 语言选择；当前提供：zh-简体中文、en-英文
     默认返回简体中文，不设定或设定 @"zh"
     获取英文，需设定 @"en"
     */
    [manager.requestSerializer setValue:@"en" forHTTPHeaderField:@"Accept-Language"];

    return YES;
}

@end
