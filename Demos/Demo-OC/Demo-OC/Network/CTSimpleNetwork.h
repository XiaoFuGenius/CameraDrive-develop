//
//  CTSimpleNetwork.h
//  Demo-OC
//
//  Created by 胡文峰 on 2019/1/15.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

#import "XFNetworkingSdkHelper.h"

NS_ASSUME_NONNULL_BEGIN

#define kAuthKey @"922f183b-ea61-422d-8d3a-deec762e70f2"  // ai测肤接口授权key
#define kServerRootUrl @"https://api.xiaofutech.com/"  // ai测肤接口域名地址
#define kServerUrl(Url) [NSString stringWithFormat:@"%@%@", kServerRootUrl, Url]


@interface CTSimpleNetwork : XFNetworkingSdkHelper

@end

NS_ASSUME_NONNULL_END
