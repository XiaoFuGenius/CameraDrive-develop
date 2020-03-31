//
//  XFAppDelegate.m
//  Demo-OC
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import "XFAppDelegate.h"

@interface XFAppDelegate ()

@end

@implementation XFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{  // 为了弹出网络连接的权限提示
        NSURL *url = [NSURL URLWithString:@"https://www.apple.com"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
        NSHTTPURLResponse *response;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        data = nil;
    });
    
    [XFBuglySdkHelper RegisterAppKey:@"cf4300b1d2"
                              secret:@"b5ac4324-7160-470e-a4b4-b6010f48f29f"
                         debugEnable:YES];

    [XFLoadingWindow InitLoadingWindow:UIWindowLevelAlert];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UIViewController *demoViewController = [NSClassFromString(@"XFDemoViewController") new];
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:demoViewController];
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"WARNING. applicationWillTerminate.");
}

+ (void)XF_ApplicationOpenSettingsType:(int)type
{
    NSString *urlString = UIApplicationOpenSettingsURLString;  // 默认打开应用本身的设置

    if (type==1 || type==2) {
        if (@available(iOS 10.0, *)) {
            if (1==type) {  // 蓝牙
                urlString = @"+isuBvoLk0Yiom+zE/seXWlQ61KndZ37+Nvoncux4Dg=";
            } else if (2==type) {  // WiFi
                urlString = @"jQhHpJ9VKHSuHiR5IhA4gfdeNW6UJznZBCmDQE0+Iug=";
            }
        } else {
            if (1==type) {  // 蓝牙
                urlString = @"kPA0CM7evkwDf8Z6cFz3MRnN4AiXJMulSCc0m/dTSvM=";
            } else if (2==type) {  // WiFi
                urlString = @"tpc9U7wbJZEVbQnLoj+ErA==";
            }
        }
        urlString = [urlString xf_DecryptAES128];
    }

    UIApplication *sharedApplication = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:urlString];
    if (![sharedApplication canOpenURL:url]) {
        NSLog(@"打开系统设置失败，请手动打开");
        return;
    }

    [XFQuickHelper OpenUrl:urlString];
}

@end
