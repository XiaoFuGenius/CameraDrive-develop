//
//  XFBluetoothHelper.h
//  XiaoFuTechHelper
//
//  Created by xiaofutech on 2017/9/26.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XFBluetoothHelperDelegate <NSObject>
- (void)XFBluetoothHelperDelegateStatus:(BOOL)status;
@end

@interface XFBluetoothHelper : UIViewController

+ (void)InitBluetoothManager;
+ (BOOL)BluetoothStatus;

///添加蓝牙状态观察者(不增加对象的引用计数)，在丢弃该对象之前建议调用移除观察者的方法
+ (void)AddObserve:(id<XFBluetoothHelperDelegate>)observe;
+ (void)RemoveObserve:(id<XFBluetoothHelperDelegate>)observe;

@end
