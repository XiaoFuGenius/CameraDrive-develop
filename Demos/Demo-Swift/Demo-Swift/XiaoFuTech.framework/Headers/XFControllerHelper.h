//
//  XFControllerHelper.h
//  XiaoFuTechHelper
//
//  Created by xiaofutech on 2017/9/27.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFControllerHelper : NSObject
#pragma mark ==================== 暂不支持使用URL直接跳转WebViewController的操作 ====================
/**
 注册登录NavigationController，用于页面跳转
 */
+ (void)RegisterLoginNavigationController:(UINavigationController*)navigationController;

/**
 获取登录NavigationController
 */
+ (UINavigationController *)LoginNavigationController;

/**
 注册根NavigationController，用于页面跳转
 */
+ (void)RegisterRootNavigationController:(UINavigationController*)navigationController;

/**
 获取根NavigationController
 */
+ (UINavigationController *)RootNavigationController;

#pragma mark - 以下默认为RootNavigationController
#pragma mark ==================== Push ====================
/**
 跳转到指定ViewController，ViewController可以是类名，类，NSURL，ViewController对象，
 若ViewController为NSURL时，传入参数为NSURL的Query对应的NSDictionary，若ViewController为其他时，传入参数为nil
 */
+ (void)PushViewController:(id)viewController Animated:(BOOL)animated;

/**
 跳转到指定ViewController，ViewController可以是类名，类，NSURL，ViewController对象，
 若ViewController为NSURL时，传入参数为NSURL的Query对应的NSDictionary，
 如果parameters不为nil，传入参数优先级为parameters大于NSURL的Query
 */
+ (void)PushViewController:(id)viewController Parameters:(id)parameters Animated:(BOOL)animated;

/**
 Pop回前一个页面
 */
+ (UIViewController *)PopViewControllerAnimated:(BOOL)animated;

#pragma mark ==================== Present ====================
/**
 跳转到指定ViewController，ViewController可以是类名，类，NSURL，ViewController对象，
 若ViewController为NSURL时，传入参数为NSURL的Query对应的NSDictionary，若ViewController为其他时，传入参数为nil
 */
+ (void)PresentViewController:(id)viewController Animated:(BOOL)animated
                   Completion:(void (^)(void))completion;

/**
 跳转到指定ViewController，ViewController可以是类名，类，NSURL，ViewController对象，
 若ViewController为NSURL时，传入参数为NSURL的Query对应的NSDictionary,如果parameters不为nil，
 传入参数优先级为parameters大于NSURL的Query
 */
+ (void)PresentViewController:(id)viewController Parameters:(id)parameters
                     Animated:(BOOL)animated Completion:(void (^)(void))completion;

/**
 dismiss回前一个界面
 */
+ (void)DismissViewControllerAnimated: (BOOL)flag completion:(void (^)(void))completion;

#pragma mark ==================== Transition Push ====================
/**
 模拟Present方式的动画进行Push操作...
 */
+ (void)PushViewControllerForRootTransition:(id)viewController Parameters:(id)parameters;
/**
 模拟Present方式的动画进行Pop操作...
 */
+ (void)PopViewControllerForRootTransition:(void (^)(void))block;

#pragma mark ==================== AnchorViewController ====================
/**
 设置一个锚点控制器，可以直接返回到这个控制器
 */
+(void)SetAnchorViewController:(UIViewController *)viewController;

/**
 获取锚点控制器
 */
+ (UIViewController *)AnchorViewController;

/**
 返回到锚点页面
 */
+ (void)PopToAnchorViewController:(BOOL)animated;

@end
