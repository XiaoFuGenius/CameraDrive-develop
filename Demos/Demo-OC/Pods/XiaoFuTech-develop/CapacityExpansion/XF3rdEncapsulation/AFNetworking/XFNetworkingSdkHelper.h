//
//  XFNetworkingSdkHelper.h
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/21.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

extern NSNotificationName const kXFNotis_NetworkStatusChanged;
typedef void (^SuccessBlock) (id responseObject);
typedef void (^FailedBlock) (id error);

NS_ASSUME_NONNULL_BEGIN

@interface XFNetworkingSdkHelper : NSObject

/**
 开启网络状态监视器
 观察者监测 通知：kXFNotis_NetworkStatusChanged
 */
+ (void)StartNetworkStatusMonitor;

/**
 获取当前网络状态
 -2 未知网络状态，-1 无互联网连接，1 蜂窝数据，2 WIFI，
 */
+ (NSInteger)NetworkStatus;

/** Post 请求 */
+ (void)PostHttpDataWithUrlStr:(NSString *)url Param:(nullable NSDictionary *)param
     ConstructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                      Progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                  SuccessBlock:(nullable SuccessBlock)successBlock
                  FailureBlock:(nullable FailedBlock)failureBlock;

/** Get 请求 */
+(void)GetHttpDataWithUrlStr:(NSString *)url Dic:(nullable NSDictionary *)dic
                SuccessBlock:(nullable SuccessBlock)successBlock
                FailureBlock:(nullable FailedBlock)failureBlock;

/* 数据下载 */
+ (void)DownloadHttpDataWithUrlStr:(NSString *)url
                          Progress:(void (^)(NSProgress *downloadProgress))progress
                        Completion:(void (^)(NSURLResponse *response, NSURL *filePath,
                                             NSError *error))completion;

@end

@interface XFHttpSignature : NSObject
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *noncestr;
@property (nonatomic, strong) NSString *loginKey;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, assign) long Id;

+ (XFHttpSignature *)Signature;

+ (void)SetServerTime:(long long)time;
+ (long long)GetTime;

+ (void)SetSignature_UserID:(NSString *)userId;
+ (NSString *)GetSignature_UserID;

+ (void)SetSignature_LoginKey:(NSString *)loginKey;
+ (NSString *)GetSignature_LoginKey;

+ (void)SetSignature_ID:(long)ID;
+ (long)GetSignature_ID;

@end

NS_ASSUME_NONNULL_END
