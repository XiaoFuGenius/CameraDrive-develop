//
//  XFBuglySdkHelper.m
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/19.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import "XFBuglySdkHelper.h"
#import <Bugly/Bugly.h>

@interface XFBuglySdkHelper ()
@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *appKey;
@end

static XFBuglySdkHelper *buglySdkHelper = nil;
@implementation XFBuglySdkHelper

#pragma mark - Public Methods
+ (void)RegisterAppKey:(NSString *)appKey secret:(NSString *)secret debugEnable:(BOOL)debugEnable
{
    [XFBuglySdkHelper SharedBuglySdkHelper].appid = appKey;
    [XFBuglySdkHelper SharedBuglySdkHelper].appKey = secret;

    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.debugMode = debugEnable;
    [Bugly startWithAppId:[XFBuglySdkHelper SharedBuglySdkHelper].appid config:config];
}

#pragma mark - Private Methods
#pragma mark >>> Custom Accessors <<<
+ (XFBuglySdkHelper *)SharedBuglySdkHelper
{
    return [[XFBuglySdkHelper alloc] init];
}

#pragma mark >>> Life Cycle <<<
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (!buglySdkHelper) {
            buglySdkHelper = [super allocWithZone:zone];
        }
        return buglySdkHelper;
    }

    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    //    buglySdkHelper = [super allocWithZone:zone];
    //});
    //return buglySdkHelper;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [XFBuglySdkHelper SharedBuglySdkHelper];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [XFBuglySdkHelper SharedBuglySdkHelper];
}

@end
