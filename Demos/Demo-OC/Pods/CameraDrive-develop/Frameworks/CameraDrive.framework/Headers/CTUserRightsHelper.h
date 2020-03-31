//
//  CTUserRightsHelper.h
//  CameraDrive
//
//  Created by 胡文峰 on 2019/12/22.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Privacy Status 状态
typedef NS_ENUM(NSInteger, CTUserAuthorizationStatus) {
    CTUserAuthorizationStatus_ErrorParam                = 0,
    CTUserAuthorizationStatus_NotSupport                = 1,

    CTUserAuthorizationStatus_NotDetermined             = 2,
    CTUserAuthorizationStatus_Restricted                = 3,
    CTUserAuthorizationStatus_Denied                    = 4,
    CTUserAuthorizationStatus_Authorized                = 5,

    CTUserAuthorizationStatus_LocAuthorizedWhenInUse    = 6,
    CTUserAuthorizationStatus_LocAuthorizedAlways       = 7,
};

typedef void (^CTUserRightsCallBack)(BOOL authorized,
                                     CTUserAuthorizationStatus status,
                                     NSError * _Nullable error);

@interface CTUserRightsHelper : NSObject

+ (void)LocationServicesRightsCheckAndRequest:(BOOL)request Always:(BOOL)always
                                   Completion:(CTUserRightsCallBack)completion;

@end

NS_ASSUME_NONNULL_END
