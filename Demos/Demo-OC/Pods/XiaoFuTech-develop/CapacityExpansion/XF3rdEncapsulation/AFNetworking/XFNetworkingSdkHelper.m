//
//  XFNetworkingSdkHelper.m
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/21.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import "XFNetworkingSdkHelper.h"
#import <XiaoFuTech/XiaoFuTech.h>

#pragma mark - XFNetworkingSdkHelper @implementation
NSNotificationName const kXFNotis_NetworkStatusChanged = @"kXFNotis_NetworkStatusChanged";

@interface XFNetworkingSdkHelper ()
@property (nonatomic, assign) BOOL monitorEnabled;
@property (nonatomic, assign) NSInteger networkStatus;  // -2 未知网络状态，-1 无互联网连接，1 蜂窝数据，2 WIFI，
@end

static XFNetworkingSdkHelper *networkingSdkHelper = nil;
@implementation XFNetworkingSdkHelper

#pragma mark >>> Public Methods <<<
+ (void)StartNetworkStatusMonitor
{
    [[XFNetworkingSdkHelper SharedNetworkingSdkHelper] startNetworkStatusMonitor];
}

+ (NSInteger)NetworkStatus
{
    return [XFNetworkingSdkHelper SharedNetworkingSdkHelper].networkStatus;
}

/** Post 请求 */
+ (void)PostHttpDataWithUrlStr:(NSString *)url Param:(NSDictionary *)param
     ConstructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                      Progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                  SuccessBlock:(SuccessBlock)successBlock
                  FailureBlock:(FailedBlock)failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //设置安全策略
    //AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    //[securityPolicy setAllowInvalidCertificates:YES];
    //[manager setSecurityPolicy:securityPolicy];

    // 设置可接受的数据格式类别
    NSSet *acTypes = [NSSet setWithObjects:@"application/json", @"text/json",
                      @"text/javascript", @"text/html", @"text/plain", nil];
    manager.responseSerializer.acceptableContentTypes = acTypes;

    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    //设置签名信息
    if (![self AdditionalProcessForPostHttpParamSettingManager:manager]) {
        return;
    }

    [manager POST:url parameters:param constructingBodyWithBlock:block progress:uploadProgress
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;

            long long serverTime = [[dict objectForKey:@"T"] longLongValue];
            [XFHttpSignature SetServerTime:serverTime];
        }

        if (![self AdditionalProcessForPostHttpSuccessBlock:task ResponseObject:responseObject]) {
            return;
        }

        /** 这里是处理事件的回调 */
        if (successBlock) {
            successBlock(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        /** 这里是处理事件的回调 */
        if (failureBlock) {
            failureBlock(error);
        }

    }];
}

// 供继承类 重写；
+ (BOOL)AdditionalProcessForPostHttpParamSettingManager:(AFHTTPSessionManager *)manager
{
    return YES;
}

// 供继承类 重写；
+ (BOOL)AdditionalProcessForPostHttpSuccessBlock:(NSURLSessionDataTask *)task ResponseObject:(id)responseObject
{
    return YES;
}

/** Get 请求 */
+(void)GetHttpDataWithUrlStr:(NSString *)url Dic:(NSDictionary *)dic
                SuccessBlock:(SuccessBlock)successBlock
                FailureBlock:(FailedBlock)failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    // 设置可接受的数据格式类别
    NSSet *acTypes = [NSSet setWithObjects:@"application/json", @"text/json",
                      @"text/javascript", @"text/html", @"text/plain", nil];
    manager.responseSerializer.acceptableContentTypes = acTypes;

    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    [manager GET:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        ///
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        /** 这里是处理事件的回调 */
        if (successBlock) {
            successBlock(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        /** 这里是处理事件的回调 */
        if (failureBlock) {
            failureBlock(error);
        }

    }];
}

/* 数据下载 */
+ (void)DownloadHttpDataWithUrlStr:(NSString *)url
                          Progress:(void (^)(NSProgress *downloadProgress))progress
                        Completion:(void (^)(NSURLResponse *response, NSURL *filePath,
                                             NSError *error))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    /*
     第一个参数:请求对象
     第二个参数:progress 进度回调
     第三个参数:destination 回调(目标位置)

     有返回值
     targetPath:临时文件路径
     response:响应头信息
     第四个参数:completionHandler 下载完成后的回调
     filePath:最终的文件路径
     */
    NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                  NSUserDomainMask,
                                                                  YES).lastObject
                              stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (completion) {
            completion(response, filePath, error);
        }
    }];

    //执行Task
    [download resume];
}

#pragma mark >>> Private Methods <<<
- (void)startNetworkStatusMonitor
{
    if (!self.monitorEnabled) {
        self.monitorEnabled = YES;
        [self displayNetworkStatusMonitor:[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus];

        AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
        [mgr startMonitoring];

        XFWeakSelf(weakSelf);
        [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [weakSelf displayNetworkStatusMonitor:status];
        }];
    }
}

- (void)displayNetworkStatusMonitor:(AFNetworkReachabilityStatus)status
{
    NSString *networkTypeDes = @"网络状态类型描述";
    switch (status) {
            case AFNetworkReachabilityStatusUnknown:{
                self.networkStatus = -2;
                networkTypeDes = @"未知网络状态";
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:{
                self.networkStatus = -1;
                networkTypeDes = @"无互联网连接";
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                self.networkStatus = 1;
                networkTypeDes = @"蜂窝数据网络";
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                self.networkStatus = 2;
                networkTypeDes = @"无线WIFI网络";
                break;
            }
    }
    NSLog(@"当前网络类型：%ld, %@", (long)self.networkStatus, networkTypeDes);

    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter postNotificationName:kXFNotis_NetworkStatusChanged object:@(self.networkStatus)];
}

#pragma mark >>> Custom Accessors <<<
+ (XFNetworkingSdkHelper *)SharedNetworkingSdkHelper
{
    return [[XFNetworkingSdkHelper alloc] init];
}

#pragma mark >>> Life Cycle <<<
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (!networkingSdkHelper) {
            networkingSdkHelper = [super allocWithZone:zone];
            networkingSdkHelper.monitorEnabled = NO;
            networkingSdkHelper.networkStatus = -1;
        }
        return networkingSdkHelper;
    }

    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    //    networkingSdkHelper = [super allocWithZone:zone];
    //});
    //return networkingSdkHelper;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [XFNetworkingSdkHelper SharedNetworkingSdkHelper];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [XFNetworkingSdkHelper SharedNetworkingSdkHelper];
}

@end


#pragma mark - XFHttpSignature @implementation
@implementation XFHttpSignature
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))
static NSString *passwordKey = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
static long long ServerTime = 0;
static long long Time = 0;

#define XFServerTime            @"XFHttpSignature_ServerTime"
#define XFSignature_UserID      @"XFHttpSignature_Signature_UserID"
#define XFSignature_LoginKey    @"XFHttpSignature_Signature_LoginKey"
#define XFSignature_ID          @"XFHttpSignature_Signature_ID"

#pragma mark >>> Public Methods <<<
+ (XFHttpSignature *)Signature
{
    long long currentTime = (long long)[[NSDate date] timeIntervalSince1970]*1000;
    currentTime -= [XFHttpSignature GetTime];

    XFHttpSignature *signature = [XFHttpSignature new];
    signature.timestamp = [@(currentTime) stringValue];
    signature.noncestr = [XFHttpSignature GetPassword:32];
    signature.userid = [XFHttpSignature GetSignature_UserID];
    signature.loginKey = [XFHttpSignature GetSignature_LoginKey];
    signature.Id = [XFHttpSignature GetSignature_ID];

    NSString *signText = [NSString stringWithFormat:@"id=%ld&key=%@&noncestr=%@&timestamp=%@",
                          signature.Id,
                          signature.loginKey,
                          signature.noncestr,
                          signature.timestamp];
    signature.sign = [signText xf_EncryptSHA1];

    return signature;
}

+ (void)SetServerTime:(long long)time
{
    @synchronized(self) {
        if (0==time) {
            ServerTime = 0;
            return;
        }
        //NSDictionary *times = [XFHttpSignature GetFormatterTimes:time];
        //NSLog(@"%@", times);

        long long nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
        long long serverTime = time - 8*3600*1000;

        ServerTime = nowTime - serverTime;
        if (ABS(Time - (nowTime-time)) > 60*1000) {
            Time = nowTime - time;
            [[NSUserDefaults standardUserDefaults] setObject:@(Time) forKey:XFServerTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    }
}
+ (long long)GetTime {
    @synchronized(self) {
        if (0==Time) {
            Time = [[[NSUserDefaults standardUserDefaults] objectForKey:XFServerTime] longLongValue];
        }
        return Time;
    }
}

+ (void)SetSignature_UserID:(NSString *)userId
{
    if ([userId xf_NotNull]) {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:XFSignature_UserID];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:XFSignature_UserID];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)GetSignature_UserID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:XFSignature_UserID];
}

+ (void)SetSignature_LoginKey:(NSString *)loginKey
{
    if ([loginKey xf_NotNull]) {
        [[NSUserDefaults standardUserDefaults] setObject:loginKey forKey:XFSignature_LoginKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:XFSignature_LoginKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)GetSignature_LoginKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:XFSignature_LoginKey];
}

+ (void)SetSignature_ID:(long)ID
{
    [[NSUserDefaults standardUserDefaults] setObject:@(ID) forKey:XFSignature_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (long)GetSignature_ID
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:XFSignature_ID] longValue];
}

#pragma mark >>> Private Methods <<<
+ (NSDictionary *)GetFormatterTimes:(long long)time
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss EEEE";

    NSString *timeDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time/1000]];
    NSString *serverDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(time - 8*3600*1000)/1000]];
    NSString *nowDate = [dateFormatter stringFromDate:[NSDate date]];

    return @{@"Now":nowDate, @"MetaServer":timeDate, @"Server":serverDate};
}

//+ (long long)GetServerTimeDifference
//{
//    @synchronized(self) {
//        return ServerTime;
//    }
//}

//+ (long long)GetServerTime
//{
//    @synchronized(self) {
//        long long nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
//        return nowTime - ServerTime;
//    }
//}

+ (NSString *)GetPassword:(int)Num
{
    NSMutableString *text = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < Num; i++) {
        int index = (int)RANDOM_INT(0, [passwordKey length]-1);
        NSRange range = NSMakeRange(index, 1);
        NSString *passwordChar = [passwordKey substringWithRange:range];
        [text appendString:passwordChar];
    }
    return text;
}
@end
