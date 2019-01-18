//
//  SwiftLinkerViewController.m
//  Demo-OC
//
//  Created by 胡文峰 on 2019/1/3.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

#import "SwiftLinkerViewController.h"
#import "EasyCameraViewController.h"

@interface SwiftLinkerViewController ()
@property (nonatomic, strong) UIButton *start;
@property (nonatomic, strong) UIButton *stop;
@property (nonatomic, strong) UIButton *getInfo;
@property (nonatomic, strong) UIButton *startCamera;
@property (nonatomic, strong) UIButton *startBleUpgrade;
@property (nonatomic, strong) UIButton *startCoreUpgrade;
@property (nonatomic, strong) UIButton *setWiredMode;
@property (nonatomic, strong) UIButton *calibration;
@property (nonatomic, strong) UIButton *shutdown;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) CTSwiftLinker *swiftLinker;
@property (nonatomic, strong) NSNotificationCenter *notiCenter;
@property (nonatomic, assign) BOOL bleActived;

@property (nonatomic, strong) NSMutableString *log;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, assign) int upgradeValue;
@property (nonatomic, assign) BOOL shouldReset;  // 用于判定是否进入图像采集控制器
@end

@implementation SwiftLinkerViewController

- (void)dealloc
{
    NSLog(@"【dealloc】%@", self);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.shouldReset = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.shouldReset) {
        [self stop:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"CTSwiftLinker";
    self.view.backgroundColor = XFColor(0xf6f6f6, 1.0f);

    [self customUI];
    [self everythingIsReady];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -
#pragma mark >> sdk 基础配置 <<

- (void)everythingIsReady
{
    [CTSwiftLinker SharedLinker];  // 必须要最先调用，以激活通知注册
    [self.notiCenter removeObserver:self name:CTSwift_iPhone_BleUpdate object:nil];
    [self.notiCenter addObserver:self selector:@selector(CTSwift_iPhone_BleUpdate:)
                            name:CTSwift_iPhone_BleUpdate object:nil];

    if ([CTBleHelper BlePowerdOn]==-1) {
        [self xf_Log:@"等待< 用户给予蓝牙权限 >或< Sdk内部启动蓝牙模块 >."];
        self.bleActived = NO;
        return;
    }
    self.bleActived = YES;

    [self xf_Log:@"准备就绪..."];
    [self configXiaoFuSdk];
    [self resetUI];

    if (![CTBleHelper BlePowerdOn]) {
        [self xf_Log:@"手机蓝牙已关闭."];
        return;
    }
    [self xf_Log:@"手机蓝牙已打开."];
}

- (CTSwiftLinker *)swiftLinker
{
    return [CTSwiftLinker SharedLinker];
}

- (NSNotificationCenter *)notiCenter
{
    return [NSNotificationCenter defaultCenter];
}

- (void)configXiaoFuSdk
{
    XFWeakSelf(weakSelf);

    self.swiftLinker.configHandler = ^{
        CTConfig *config = [CTConfig SharedConfig];
        config.debugEnable = YES;
        config.debugLogType = 1;
        config.debugLogHandler = ^(NSString *log) {
            [weakSelf xf_Log:log];
        };
        config.splitStrings = @[@"!@"];

        CTEasyLinker *easyLinker = [CTEasyLinker SharedEsayLinker];
        easyLinker.smartMode = 1;
        easyLinker.verify5GEnabled = YES;
        easyLinker.staPingEnabled = YES;
        easyLinker.staCachesStored = YES;
        easyLinker.ssidIgnored = @[@"CFY_"];
        easyLinker.hotspotEnabled = YES;
    };

    self.swiftLinker.bleResponse = ^(CTSwiftBleLinkStatus status, NSString * _Nonnull description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf bleResponseStatus:status description:description];
        });
    };

    self.swiftLinker.networkResponse = ^(CTSwiftNetworkLinkStatus status, NSString * _Nonnull description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf networkResponseStatus:status description:description];
        });
    };

    self.swiftLinker.alertShowHandler = ^(int type, NSString * _Nonnull ssid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf alertShowHandlerType:type ssid:ssid];
        });
    };

    [self.notiCenter addObserver:self selector:@selector(CTSwift_Device_BatteryUpdate:)
                            name:CTSwift_Device_BatteryUpdate object:nil];
}

- (void)bleResponseStatus:(CTSwiftBleLinkStatus)status description:(NSString *)description
{
    switch (status) {
            case CTSwiftBleLinkDevicePoweredOn:{
                [self xf_Log:description];
                break;
            }
            case CTSwiftBleLinkDeviceNotFound:
            case CTSwiftBleLinkDeviceFailed:{
                [self xf_Log:description];
                [self resetUI];
                break;
            }
            case CTSwiftBleLinkDeviceSucceed:{
                [self xf_Log:@"已连接设备蓝牙，开始尝试与设备建立网络连接."];

                NSDictionary *device = [CTBleHelper DeviceInfoCache];
                NSString *deviceInfo = [NSString stringWithFormat:@"%@，%@，%d，ble：%@，core：%@ .", \
                                        device[@"Name"], device[@"BindID"], \
                                        [device[@"RSSI"] intValue], \
                                        device[@"BleVersionString"], device[@"CoreVersionString"]];
                [self xf_Log:deviceInfo];

                self.title = [deviceInfo componentsSeparatedByString:@"，ble"].firstObject;
                [self updateUI4BleConnected];

                [CTSwiftLinker StartNetworkLink];

                break;
            }
    }
}

- (void)networkResponseStatus:(CTSwiftNetworkLinkStatus)status description:(NSString *)description
{
    switch (status) {
            case CTSwiftNetworkLinkCheckStatus:
            case CTSwiftNetworkLinkSTA:
            case CTSwiftNetworkLink5gChecking:
            case CTSwiftNetworkLinkWiFiStart:
            case CTSwiftNetworkLinkPwdError:
            case CTSwiftNetworkLinkPingChecking:
            case CTSwiftNetworkLinkAP:
            case CTSwiftNetworkLinkHotspotStart:
            case CTSwiftNetworkLinkIpAddrChecking:{
                [self xf_Log:description];
                break;
            }
            case CTSwiftNetworkLinkStaFailed:
            case CTSwiftNetworkLinkSsidNotFound:
            case CTSwiftNetworkLinkApFailed:{
                [self xf_Log:description];
                self.maskView.hidden = YES;
                break;
            }
            case CTSwiftNetworkLink5gConfirmed:{
                [self xf_Log:description];

                UIAlertController *alert5G = [UIAlertController
                                              alertControllerWithTitle:@"5g检查，判定为5g网络"
                                              message:@"设备 当前“不支持”5G网络 联网，请使用AP模式联网或重试."
                                              preferredStyle:UIAlertControllerStyleAlert];
                [alert5G addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel
                                                          handler:nil]];
                [self showAlert:alert5G Sender:self.start];

                self.maskView.hidden = YES;
                break;
            }
            case CTSwiftNetworkLinkPingFailed:{
                [self xf_Log:description];

                UIAlertController *alertPing = [UIAlertController
                                              alertControllerWithTitle:@"ping检查，判定为公共验证类wifi"
                                              message:@"设备 当前“不支持”公共验证类wifi 联网，请使用AP模式联网或重试."
                                              preferredStyle:UIAlertControllerStyleAlert];
                [alertPing addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel
                                                          handler:nil]];
                [self showAlert:alertPing Sender:self.start];

                self.maskView.hidden = YES;
                break;
            }
            case CTSwiftNetworkLinkSucceed:{
                NSString *msg = [NSString stringWithFormat:@"设备已联网(%@，ip：%@).", \
                                 self.swiftLinker.type==1?@"STA模式":@"AP模式", self.swiftLinker.ip];
                [self xf_Log:msg];

                self.startCamera.userInteractionEnabled = YES;
                self.startCamera.selected = YES;
                self.startCoreUpgrade.userInteractionEnabled = YES;
                self.startCoreUpgrade.selected = YES;

                self.maskView.hidden = YES;
                break;
            }
            case CTSwiftNetworkLinkFailed:{
                [self xf_Log:description];
                //[self xf_Log:@"设备联网失败，请重新尝试(若多次联网失败，建议先重启设备)."];
                self.maskView.hidden = YES;
                break;
            }
    }
}

- (void)alertShowHandlerType:(int)type ssid:(NSString *)ssid
{
    if (type==1) {
        [self showSTALinkAlert:ssid];
    } else {
        [self showAPLinkAlert:ssid];
    }
}

- (void)CTSwift_iPhone_BleUpdate:(NSNotification *)noti
{
    XFWeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized (weakSelf) {
            if (weakSelf.bleActived) {
                if (![CTBleHelper BlePowerdOn]) {
                    [weakSelf xf_Log:@"手机蓝牙已关闭."];
                } else {
                    [weakSelf xf_Log:@"手机蓝牙已打开."];
                }
                return;
            }

            // 用户已授权 & Sdk内部蓝牙模块已启动.
            weakSelf.bleActived = YES;
            [weakSelf everythingIsReady];
        }
    });
}

- (void)CTSwift_Device_BatteryUpdate:(NSNotification *)noti
{
    XFWeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *batteryInfo = noti.userInfo;

        BOOL success    = [batteryInfo[@"Success"] intValue];
        BOOL isCharge   = [batteryInfo[@"IsCharge"] intValue];
        int battery     = [batteryInfo[@"Battery"] intValue];
        if (success) {
            NSString *info = [NSString stringWithFormat:@"收到电量状态变化通知，设备%@，电量：%d.", \
                              isCharge?@"正在充电":@"未充电", battery];
            [weakSelf xf_Log:info];
        } else {
            [weakSelf xf_Log:@"电量信息请求失败."];
        }
    });
}

#pragma mark > STA Mode <
- (void)showSTALinkAlert:(NSString *)ssid
{
    if (![ssid xf_NotNull]) {
        [self xf_Log:@"showSTALinkAlert，启动失败，未获取到ssid."];
        [self resetUI];
        return;
    }

    XFWeakSelf(weakSelf);
    UIAlertController *staAlert = [UIAlertController
                                   alertControllerWithTitle:@"输入wifi密码" message:ssid
                                   preferredStyle:UIAlertControllerStyleAlert];

    [staAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //可自定义textField相关属性...
    }];

    [staAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.swiftLinker.canceledHandler) {
            weakSelf.swiftLinker.canceledHandler();
        }
    }]];

    [staAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        NSString *pwd = staAlert.textFields.firstObject.text;
        if (weakSelf.swiftLinker.confirmedHandler) {
            weakSelf.swiftLinker.confirmedHandler(pwd);
        }
    }]];

    [self showAlert:staAlert Sender:self.start];
}

#pragma mark > AP Mode <
- (void)showAPLinkAlert:(NSString *)ssid
{
    if (![ssid xf_NotNull]) {
        [self xf_Log:@"showAPLinkAlert，启动失败，未获取到ssid."];
        [self resetUI];
        return;
    }

    XFWeakSelf(weakSelf);
    UIAlertController *apAlert = [UIAlertController
                                  alertControllerWithTitle:@"前往设置连接指定热点"
                                  message:ssid
                                  preferredStyle:UIAlertControllerStyleAlert];

    [apAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.swiftLinker.canceledHandler) {
            weakSelf.swiftLinker.canceledHandler();
        }
    }]];

    [apAlert addAction:[UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.swiftLinker.confirmedHandler) {
            weakSelf.swiftLinker.confirmedHandler(@"");
        }
    }]];

    [self showAlert:apAlert Sender:self.start];
}

#pragma mark -
#pragma mark >> Actions <<

- (void)start:(UIButton *)sender
{
    if (![CTBleHelper BlePowerdOn]) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"请打开手机蓝牙" message:nil
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleCancel handler:nil]];
        [self showAlert:alert Sender:self.start];
        return;
    }

    if ([CTBleHelper ConnectStatus]==2) {
        [self stop:nil];
    }

    [self xf_Log:@"开始连接."];
    [CTSwiftLinker StartBleLink];

    self.maskView.hidden = NO;
    self.start.userInteractionEnabled = NO;
    self.start.selected = NO;
    self.stop.userInteractionEnabled = YES;
    self.stop.selected = YES;
}

- (void)stop:(UIButton *)sender
{
    [self xf_Log:@"手动停止."];
    [CTSwiftLinker Stop];
    [CTBleHelper CleanDeviceCache];
    [self resetUI];
}

- (void)shutdown:(UIButton *)sender
{
    [CTBleHelper Shutdown:nil];
    if (!sender) {
        [self xf_Log:@"设备已自动关机."];
    }
}

- (void)getInfo:(UIButton *)sender
{
    XFWeakSelf(weakSelf);
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"请选择要获取的信息" message:nil
                                preferredStyle:[self getAlertStyle:UIAlertControllerStyleActionSheet]];
    [alert addAction:[UIAlertAction actionWithTitle:@"wifiStatus" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [weakSelf wifiStatus:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"MAC" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [weakSelf getMAC:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Version" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [weakSelf getVersion:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Battery" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [weakSelf getBattery:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self showAlert:alert Sender:self.getInfo];
}

- (void)wifiStatus:(UIButton *)sender
{
    [self xf_Log:@"[仅检查]开始获取设备网络状态..."];
    self.maskView.hidden = NO;

    XFWeakSelf(weakSelf);
    [CTEasyLinker NetworkStatusCheckOnly:YES Response:^(CTBleResponseCode code, int type,
                                                        NSString * _Nonnull ssid,
                                                        NSString * _Nonnull password,
                                                        NSString * _Nonnull ip) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.maskView.hidden = YES;

            NSString *logMsg = @"wifiStatus 获取成功.";
            if (code==CTBleResponseError) {
                logMsg = @"未成功获取 wifiStatus.";
                [weakSelf xf_Log:logMsg];
                return;
            }

            [weakSelf xf_Log:logMsg];
            if (type==0) {

                if (![[CTConfig GetSSID] xf_NotNull]) {
                    logMsg = @"UnKnown_手机未连接wifi，可启动ap模式.";
                } else {
                    logMsg = @"UnKnown_手机已连接wifi，可启动sta模式.";
                }

            } else if (type==1) {

                if (![[CTConfig GetSSID] xf_NotNull]) {
                    logMsg = @"STA_手机未连接wifi，可启动ap模式.";
                } else {
                    if ([[CTConfig GetSSID] isEqualToString:ssid]) {
                        if ([ip xf_NotNull]) {
                            logMsg = @"STA_手机与设备处于同一wifi网络，且已获取到设备联网ip，可直接启动摄像头.";
                        } else {
                            logMsg = @"AP_手机已连接设备热点，但未获取到设备联网ip，可启动sta模式.";
                        }
                    } else {
                        logMsg = @"STA_手机已连接wifi，可启动sta模式.";
                    }
                }

            } else if (type==2) {

                if (![[CTConfig GetSSID] xf_NotNull]) {
                    logMsg = @"AP_手机未连接wifi，可启动ap模式.";
                } else {
                    if ([[CTConfig GetSSID] isEqualToString:ssid]) {
                        if ([ip xf_NotNull]) {
                            logMsg = @"AP_手机已连接设备热点，且已获取到设备联网ip，可直接启动摄像头.";
                        } else {
                            logMsg = @"AP_手机已连接设备热点，但未获取到设备联网ip，可启动ap模式.";
                        }
                    } else {
                        logMsg = @"AP_手机未连接当前设备热点，可启动ap模式.";
                    }
                }

            }

            [weakSelf xf_Log:logMsg];
        });
    }];
}

- (void)getMAC:(UIButton *)sender
{
    [self xf_Log:@"开始获取设备的 MAC信息..."];
    self.maskView.hidden = NO;

    XFWeakSelf(weakSelf);
    [CTBleHelper MAC:^(CTBleResponseCode code, NSString *mac) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.maskView.hidden = YES;
            if (code==CTBleResponseOK) {
                [weakSelf xf_Log:[NSString stringWithFormat:@"MAC获取成功：%@.", mac]];
            } else {
                [weakSelf xf_Log:[NSString stringWithFormat:@"MAC信息获取失败."]];
            }
        });
    }];
}

- (void)getVersion:(UIButton *)sender
{
    [self xf_Log:@"开始获取设备的 Version信息..."];
    self.maskView.hidden = NO;

    XFWeakSelf(weakSelf);
    [CTBleHelper Version:^(CTBleResponseCode code, NSString *ble, NSString *core,
                           long bleValue, long coreValue) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.maskView.hidden = YES;
            if (code==CTBleResponseOK) {
                NSString *verInfo = [NSString stringWithFormat:@"Version获取成功：Ble:%@[%ld], Core：%@[%ld].", ble, bleValue, core, coreValue];
                [weakSelf xf_Log:verInfo];
            } else {
                [weakSelf xf_Log:[NSString stringWithFormat:@"Version信息获取失败."]];
            }
        });
    }];
}

- (void)getBattery:(UIButton *)sender
{
    [self xf_Log:@"开始获取设备的 Battery信息..."];
    self.maskView.hidden = NO;

    XFWeakSelf(weakSelf);
    [CTBleHelper Battery:^(CTBleResponseCode code, BOOL isCharge, int battery) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.maskView.hidden = YES;
            if (code==CTBleResponseOK) {
                NSString *batteryInfo = [NSString stringWithFormat:@"Battery获取成功：isCharge：%d, battery：%d.", isCharge, battery];
                [weakSelf xf_Log:batteryInfo];
            } else {
                [weakSelf xf_Log:[NSString stringWithFormat:@"Battery信息获取失败."]];
            }
        });
    }];
}

- (void)startCamera:(UIButton *)sender
{
    [self xf_Log:[NSString stringWithFormat:@"开始启动摄像头[ip：%@]...", self.swiftLinker.ip]];

    XFWeakSelf(weakSelf);
    EasyCameraViewController *cameraCtr = [[EasyCameraViewController alloc] init];
    cameraCtr.param = @{@"IP":[self.swiftLinker.ip copy]};
    cameraCtr.logHandler = ^(NSString *log) {
        [weakSelf xf_Log:log];
    };

    self.shouldReset = NO;
    [self.navigationController presentViewController:cameraCtr animated:YES completion:nil];
}

#pragma mark > BLE UPGRADE <
- (void)startBleUpgrade:(UIButton *)sender
{
    NSString *alertTitle = @"选择蓝牙固件版本";
    NSArray *bleVerTitles = @[@"Release_Ble_2.0.0（归一化）", @"Release_Ble_2.1.0（支持有线）"];
    NSArray *bleVersions = @[@"BLE_2.0.0_20000", @"BLE_2.1.0_20100"];

    XFWeakSelf(weakSelf);

    UIAlertController *bleAlert = [UIAlertController
                                   alertControllerWithTitle:alertTitle message:nil
                                   preferredStyle:[self getAlertStyle:UIAlertControllerStyleActionSheet]];
    for (NSInteger i = 0; i < bleVersions.count; i++) {
        NSString *title = [bleVerTitles objectAtIndex:i];
        NSString *version = [bleVersions objectAtIndex:i];
        [bleAlert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf xf_Log:[NSString stringWithFormat:@"当前选择版本：%@", title]];
            [weakSelf startUpdateBle:version];
        }]];
    }
    [bleAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                               handler:nil]];
    [self showAlert:bleAlert Sender:self.startBleUpgrade];
}

- (void)bleVersionUpgradeLimitedTargetVersion:(NSInteger)targetVersion
                                   Completion:(void (^)(void))completion
{
    NSInteger bleVersion = [[CTBleHelper DeviceInfoCache][@"BleVersion"] integerValue];
    NSInteger coreVersion =  [[CTBleHelper DeviceInfoCache][@"CoreVersion"] integerValue];

    BOOL limited = NO;
    NSString *alertMsg = @"蓝牙固件版本受限处理.";
    // 受限判定
    if (bleVersion > 20000 && coreVersion > 30000
        && targetVersion < 20100) {
        // ble > 2.0.0，core > 3.0.0，降级操作：目标版本2.0.0 + 3.0.0，必须先核心，后蓝牙
        limited = YES;
        alertMsg = @"请先降级核心固件版本.";
    }

    if (!limited) {  // 无受限
        if (completion) {
            completion();
        }
        return;
    }

    // 显示受限警示框
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:alertMsg message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self showAlert:alert Sender:self.startBleUpgrade];
}

- (void)startUpdateBle:(NSString *)verName
{
    NSString *targetStr = [verName componentsSeparatedByString:@"_"][1];
    NSArray *bleVers = [targetStr componentsSeparatedByString:@"."];
    NSInteger target = [bleVers[0] intValue]*10000 + [bleVers[1] intValue]*100 + [bleVers[2] intValue];

    XFWeakSelf(weakSelf);
    [self bleVersionUpgradeLimitedTargetVersion:target Completion:^{
        [weakSelf xf_Log:@"开始升级蓝牙固件..."];
        weakSelf.maskView.hidden = NO;

        NSData *bleData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]
                                                          pathForResource:verName ofType:@"bin"]];

        weakSelf.upgradeValue = -1;
        [CTEasyLinker UpdateBLE:bleData Response:^(CTBleResponseCode code, int value,
                                                   NSString * _Nonnull msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (code==CTBleResponseError) {
                    weakSelf.maskView.hidden = YES;
                    [weakSelf xf_Log:[NSString stringWithFormat:@"升级失败：%@", msg]];
                    [weakSelf resetUI];
                    return;
                }

                if (value<100) {
                    if (value<3 || value>97) {
                        [weakSelf xf_Log:[NSString stringWithFormat:@"升级进度：%d（%@）", value, msg]];
                    } else if (3==value ||
                               16==value || 26==value || 36==value || 56==value ||
                               66==value || 76==value || 86==value || 96==value) {
                        if (weakSelf.upgradeValue != value) {
                            weakSelf.upgradeValue = value;
                            [weakSelf xf_Log:[NSString stringWithFormat:@"升级进度：%d（%@）", value, msg]];
                        }
                    }
                } else {
                    weakSelf.maskView.hidden = YES;
                    [weakSelf xf_Log:[NSString stringWithFormat:@"升级进度：%d（%@）", value, msg]];
                    [weakSelf resetUI];
                }
            });
        }];
    }];
}

#pragma mark > CORE UPGRADE <
- (void)startCoreUpgrade:(UIButton *)sender
{
    NSString *alertTitle = @"选择核心固件版本";
    NSArray *kernelVerTitles = @[@"Release_Core_3.0.0（归一化）", @"Release_Core_3.1.0（有线支持）"];
    NSArray *kernelVersions = @[@"Core_3.0.0_30000", @"Core_3.1.0_30100"];

    XFWeakSelf(weakSelf);

    UIAlertController *coreAlert = [UIAlertController
                                    alertControllerWithTitle:alertTitle message:nil
                                    preferredStyle:[self getAlertStyle:UIAlertControllerStyleActionSheet]];
    for (NSInteger i = 0; i < kernelVersions.count; i++) {
        NSString *title = [kernelVerTitles objectAtIndex:i];
        NSString *version = [kernelVersions objectAtIndex:i];
        [coreAlert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf xf_Log:[NSString stringWithFormat:@"当前选择版本：%@", title]];
            [weakSelf startCoreUpdate:version];
        }]];
    }
    [coreAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                handler:nil]];
    [self showAlert:coreAlert Sender:self.startCoreUpgrade];
}

- (void)coreVersionUpgradeLimitedTargetVersion:(NSInteger)targetVersion
                                    Completion:(void (^)(void))completion
{
    NSInteger bleVersion = [[CTBleHelper DeviceInfoCache][@"BleVersion"] integerValue];
    //NSInteger coreVersion =  [[CTBleHelper DeviceInfoCache][@"CoreVersion"] integerValue];

    BOOL limited = NO;
    NSString *alertMsg = @"核心固件版本受限处理.";
    // 受限判定
    if (bleVersion < 20100 && targetVersion > 30000) {
        // ble < 2.1.0，升级操作：目标版本2.1.0 + 3.1.0，必须先蓝牙，后核心
        limited = YES;
        alertMsg = @"请先升级蓝牙固件版本.";
    }

    if (!limited) {  // 无受限
        if (completion) {
            completion();
        }
        return;
    }

    // 显示受限警示框
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:alertMsg message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self showAlert:alert Sender:self.startCoreUpgrade];
}

- (void)startCoreUpdate:(NSString *)verName
{
    NSString *targetStr = [verName componentsSeparatedByString:@"_"][1];
    NSArray *bleVers = [targetStr componentsSeparatedByString:@"."];
    NSInteger target = [bleVers[0] intValue]*10000 + [bleVers[1] intValue]*100 + [bleVers[2] intValue];

    XFWeakSelf(weakSelf);
    [self coreVersionUpgradeLimitedTargetVersion:target Completion:^{
        [weakSelf xf_Log:@"开始升级核心固件..."];
        weakSelf.maskView.hidden = NO;

        NSData *coreData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]
                                                           pathForResource:verName ofType:@"bin"]];

        weakSelf.upgradeValue = -1;
        [CTEasyLinker UpdateCore:coreData Response:^(CTBleResponseCode code, int value,
                                                     NSString * _Nonnull msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (code==CTBleResponseError) {
                    weakSelf.maskView.hidden = YES;
                    [weakSelf xf_Log:[NSString stringWithFormat:@"升级失败：%@", msg]];
                    [weakSelf shutdown:nil];
                    return;
                }

                if (value<100) {
                    if (value<6 || value>97) {
                        [weakSelf xf_Log:[NSString stringWithFormat:@"升级进度：%d（%@）", value, msg]];
                    } else if (6==value ||
                               16==value || 26==value || 36==value || 56==value ||
                               66==value || 76==value || 86==value || 96==value) {
                        if (weakSelf.upgradeValue != value) {
                            weakSelf.upgradeValue = value;
                            [weakSelf xf_Log:[NSString stringWithFormat:@"升级进度：%d（%@）", value, msg]];
                        }
                    }
                } else {
                    weakSelf.maskView.hidden = YES;
                    [weakSelf xf_Log:[NSString stringWithFormat:@"升级进度：%d（%@）", value, msg]];
                    [weakSelf shutdown:nil];
                }
            });
        }];
    }];
}

#pragma mark > calibrationTools <
- (void)calibrationTools:(UIButton *)sender
{
    XFWeakSelf(weakSelf);
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"请选择 校准 选项" message:nil
                                preferredStyle:[self getAlertStyle:UIAlertControllerStyleActionSheet]];
    [alert addAction:[UIAlertAction actionWithTitle:@"calibration（校准）"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf calibration:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"recalibration（回滚）"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf recalibration:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"restartNVDS（恢复配置）"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf restartNVDS:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self showAlert:alert Sender:self.calibration];
}

- (void)calibration:(UIButton *)sender
{
    NSInteger bleVersion = [[CTBleHelper DeviceInfoCache][@"BleVersion"] integerValue];
    NSInteger coreVersion =  [[CTBleHelper DeviceInfoCache][@"CoreVersion"] integerValue];

    if (bleVersion < 20100 || coreVersion < 30100) {
        [self xf_Log:@"固件版本不符合要求，已取消."];
        return;
    }

    [self xf_Log:@"开始检查当前校准状态..."];
    self.maskView.hidden = NO;

    XFWeakSelf(weakSelf);
    [CTBleHelper CalibrateStatusCheck:^(CTBleResponseCode code, int status, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.maskView.hidden = YES;
            if (code==CTBleResponseError) {
                [weakSelf xf_Log:@"获取校准状态 请求失败."];
                return;
            }

            if (-1==status) {
                [weakSelf xf_Log:@"校准状态未知."];
            } else if (0==status) {
                [weakSelf xf_Log:@"当前设备不需要校准."];
            } else if (1==status) {
                [weakSelf xf_Log:@"请使用专门的 校准工具 进行校准."];
            } else if (2==status) {
                [weakSelf xf_Log:@"当前设备已校准."];
            }
        });
    }];
}

- (void)recalibration:(UIButton *)sender
{
    NSInteger bleVersion = [[CTBleHelper DeviceInfoCache][@"BleVersion"] integerValue];
    NSInteger coreVersion =  [[CTBleHelper DeviceInfoCache][@"CoreVersion"] integerValue];

    if (bleVersion < 20100 || coreVersion < 30100) {
        [self xf_Log:@"固件版本不符合要求，已取消."];
        return;
    }

    [self xf_Log:@"开始检查当前校准状态..."];
    self.maskView.hidden = NO;

    XFWeakSelf(weakSelf);
    [CTBleHelper CalibrateStatusCheck:^(CTBleResponseCode code, int status, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code==CTBleResponseError) {
                weakSelf.maskView.hidden = YES;
                return;
            }

            if (2==status) {
                [weakSelf xf_Log:@"设备已校准，开始执行 图像校准回滚..."];
                [CTBleHelper CalibrateCommand:3 Response:^(CTBleResponseCode code, int status,
                                                           NSString *msg) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf xf_Log:[NSString stringWithFormat:@"图像校准回滚：%@.", msg]];
                        weakSelf.maskView.hidden = YES;
                        if (code==CTBleResponseOK) {
                            [weakSelf shutdown:nil];
                        }
                    });
                }];

                return;
            }

            weakSelf.maskView.hidden = YES;
            if (-1==status) {
                [weakSelf xf_Log:@"校准状态未知，回滚拒绝."];
            } else if (0==status) {
                [weakSelf xf_Log:@"当前设备不需要校准，回滚拒绝."];
            } else if (1==status) {
                [weakSelf xf_Log:@"当前设备未校准，回滚拒绝."];
            } else if (2==status) {
                //[weakSelf xf_Log:@"当前设备已校准，可以回滚."];
            }
        });
    }];
}

- (void)restartNVDS:(UIButton *)sender
{
    NSInteger bleVersion = [[CTBleHelper DeviceInfoCache][@"BleVersion"] integerValue];
    NSInteger coreVersion =  [[CTBleHelper DeviceInfoCache][@"CoreVersion"] integerValue];

    if (bleVersion < 20100 || coreVersion < 30100) {
        [self xf_Log:@"固件版本不符合要求，已取消"];
        return;
    }

    [self xf_Log:@"开始执行 一键恢复，校准配置..."];
    self.maskView.hidden = NO;

    XFWeakSelf(weakSelf);
    [CTBleHelper CalibrateRestartNVDS:^(CTBleResponseCode code, int status, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf xf_Log:[NSString stringWithFormat:@"一键恢复，校准配置：%@", msg]];
            weakSelf.maskView.hidden = YES;
            if (code==CTBleResponseOK) {
                [weakSelf shutdown:nil];
            }
        });
    }];
}

#pragma mark > wiredMode <
- (void)wiredMode:(UIButton *)sender
{
    NSInteger bleVersion = [[CTBleHelper DeviceInfoCache][@"BleVersion"] integerValue];
    NSInteger coreVersion =  [[CTBleHelper DeviceInfoCache][@"CoreVersion"] integerValue];

    if (bleVersion < 20100 || coreVersion < 30100) {
        [self xf_Log:@"固件版本不符合要求，已取消"];
        return;
    }

    XFWeakSelf(weakSelf);

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"请选择设备模式" message:nil
                                preferredStyle:[self getAlertStyle:UIAlertControllerStyleActionSheet]];
    [alert addAction:[UIAlertAction actionWithTitle:@"混合 模式" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setWiredMode:1];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"[仅]无线 模式" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setWiredMode:2];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"[仅]有线 模式" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setWiredMode:3];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self showAlert:alert Sender:self.setWiredMode];
}

- (void)setWiredMode:(int)mode
{
    XFWeakSelf(weakSelf);
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"请选择设备类型" message:nil
                                preferredStyle:[self getAlertStyle:UIAlertControllerStyleActionSheet]];
    [alert addAction:[UIAlertAction actionWithTitle:@"老设备" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [CTBleHelper SetWiredModeCommand:-mode Response:^(CTBleResponseCode code, NSString *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *modeDes = mode==1?@"混合":(mode==2?@"无线":@"有线");
                if (code==CTBleResponseOK) {
                    [weakSelf xf_Log:[NSString stringWithFormat:@"老设备 %@模式 设置成功.", modeDes]];
                } else {
                    [weakSelf xf_Log:[NSString stringWithFormat:@"老设备 %@模式 设置失败.", modeDes]];
                }
                [weakSelf shutdown:nil];
            });
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"新设备" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [CTBleHelper SetWiredModeCommand:mode Response:^(CTBleResponseCode code, NSString *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *modeDes = mode==1?@"混合":(mode==2?@"无线":@"有线");
                if (code==CTBleResponseOK) {
                    [weakSelf xf_Log:[NSString stringWithFormat:@"新设备 %@模式 设置成功.", modeDes]];
                } else {
                    [weakSelf xf_Log:[NSString stringWithFormat:@"新设备 %@模式 设置失败.", modeDes]];
                }
                [weakSelf shutdown:nil];
            });
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self showAlert:alert Sender:self.setWiredMode];
}

#pragma mark >> customUI <<

- (void)customUI
{
    self.navigationController.navigationBar.translucent = NO;

    CGRect frame = CGRectMake(0, 0, kWidth, kHeight-XFNaviBarHeight);
    UIView *mainView = [UIView XF_ViewWithColor:[UIColor clearColor] Frame:frame];
    [self.view addSubview:mainView];

    CGFloat top = 5;
    frame = CGRectMake(5, top, [mainView xf_GetWidth]-10, [mainView xf_GetHeight]/2-10);
    // NSTextStorage, NSLayoutManager, NSTextContainer
    UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = XFColor(0x333333, 1.0f).CGColor;
    textView.layer.cornerRadius = 3.0f;
    textView.clipsToBounds = YES;
    textView.font = XFFont(11);
    textView.textColor = XFColor(0x333333, 1.0f);

    textView.editable = NO;
    //textView.selectable = NO;  // iOS 11 + 会触发 滚动至最后一行 功能出现Bug；

    textView.layoutManager.allowsNonContiguousLayout = NO;
    [mainView addSubview:textView];
    top += [textView xf_GetHeight]+15;
    self.textView = textView;

    frame = CGRectMake(5, top-10, [mainView xf_GetWidth]-10, [mainView xf_GetHeight]-5-(top-10));
    UIView *maskView = [UIView XF_ViewWithColor:XFColor(0x000000, 0.3f) Frame:frame];
    maskView.layer.cornerRadius = 3.0f;
    maskView.hidden = YES;
    self.maskView = maskView;



    CGFloat btnWidth = (kWidth-15*2-20*2)/3;
    CGFloat btnHeight = 45;
    CGFloat limitHeight = [mainView xf_GetHeight];
    CGFloat left = 15;
    CGFloat spacing = 10.0f;

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *start = [self setupButtonTitle:@"start"
                                      Action:@selector(start:) Frame:frame];
    _start = start;
    [mainView addSubview:start];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *stop = [self setupButtonTitle:@"stop"
                                         Action:@selector(stop:) Frame:frame];
    _stop = stop;
    [mainView addSubview:stop];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *getInfo = [self setupButtonTitle:@"getInfo"
                                        Action:@selector(getInfo:) Frame:frame];
    _getInfo = getInfo;
    [mainView addSubview:getInfo];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *startBleUpgrade = [self setupButtonTitle:@"startBleUpgrade"
                                                Action:@selector(startBleUpgrade:) Frame:frame];
    _startBleUpgrade = startBleUpgrade;
    [mainView addSubview:startBleUpgrade];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *startCamera = [self setupButtonTitle:@"startCamera"
                                            Action:@selector(startCamera:) Frame:frame];
    _startCamera = startCamera;
    [mainView addSubview:startCamera];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *startCoreUpgrade = [self setupButtonTitle:@"startCoreUpgrade"
                                                 Action:@selector(startCoreUpgrade:) Frame:frame];
    _startCoreUpgrade = startCoreUpgrade;
    [mainView addSubview:startCoreUpgrade];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *calibration = [self setupButtonTitle:@"calibration"
                                            Action:@selector(calibrationTools:) Frame:frame];
    _calibration = calibration;
    [mainView addSubview:calibration];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *setWiredMode = [self setupButtonTitle:@"wiredMode"
                                             Action:@selector(wiredMode:) Frame:frame];
    _setWiredMode = setWiredMode;
    [mainView addSubview:setWiredMode];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *shutdown = [self setupButtonTitle:@"shutdown" Action:@selector(shutdown:) Frame:frame];
    _shutdown = shutdown;
    [mainView addSubview:shutdown];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [start xf_GetTop];
    }

    [mainView addSubview:self.maskView];
}

- (UIButton *)setupButtonTitle:(NSString *)title Action:(SEL)action Frame:(CGRect)frame
{
    UIButton *button = [UIButton XF_ButtonWithColor:[UIColor clearColor] Image:nil
                                              Title:title Font:XFFont(15)
                                         TitleColor:XFColor(0xffffff, 1.0f) Target:self
                                             Action:action Frame:frame];
    button.userInteractionEnabled = NO;

    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.layer.cornerRadius = 3.0f;
    button.clipsToBounds = YES;
    [button xf_SetBackgroundColor:XFColor(0xcecece, 1.0f) forState:UIControlStateNormal];
    [button xf_SetBackgroundColor:XFColor(0x4d7bfe, 1.0f) forState:UIControlStateSelected];
    [button xf_SetBackgroundColor:XFColor(0x4d7bfe, 0.75f)
                         forState:UIControlStateSelected | UIControlStateHighlighted];
    return button;
}

- (void)resetUI
{
    self.maskView.hidden = YES;

    self.title = @"CTSwiftLinker";
    self.start.userInteractionEnabled = YES;
    self.start.selected = YES;
    self.stop.userInteractionEnabled = NO;
    self.stop.selected = NO;

    self.shutdown.userInteractionEnabled = NO;
    self.shutdown.selected = NO;

    self.getInfo.userInteractionEnabled = NO;
    self.getInfo.selected = NO;
    self.startBleUpgrade.userInteractionEnabled = NO;
    self.startBleUpgrade.selected = NO;

    self.setWiredMode.userInteractionEnabled = NO;
    self.setWiredMode.selected = NO;
    self.calibration.userInteractionEnabled = NO;
    self.calibration.selected = NO;

    self.startCamera.userInteractionEnabled = NO;
    self.startCamera.selected = NO;
    self.startCoreUpgrade.userInteractionEnabled = NO;
    self.startCoreUpgrade.selected = NO;
}

- (void)updateUI4BleConnected
{
    self.start.userInteractionEnabled = NO;
    self.start.selected = NO;
    self.stop.userInteractionEnabled = YES;
    self.stop.selected = YES;

    self.shutdown.userInteractionEnabled = YES;
    self.shutdown.selected = YES;

    self.getInfo.userInteractionEnabled = YES;
    self.getInfo.selected = YES;
    self.startBleUpgrade.userInteractionEnabled = YES;
    self.startBleUpgrade.selected = YES;

    self.setWiredMode.userInteractionEnabled = YES;
    self.setWiredMode.selected = YES;
    self.calibration.userInteractionEnabled = YES;
    self.calibration.selected = YES;

    self.startCamera.userInteractionEnabled = NO;
    self.startCamera.selected = NO;
    self.startCoreUpgrade.userInteractionEnabled = NO;
    self.startCoreUpgrade.selected = NO;
}

- (UIAlertControllerStyle)getAlertStyle:(UIAlertControllerStyle)style
{
    if ([UIDevice XF_DeviceType]==XFDeviceType_iPad) {
        return UIAlertControllerStyleAlert;
    }
    return style;
}
- (void)showAlert:(UIAlertController *)alert Sender:(UIView *)sender
{
    if ([UIDevice XF_DeviceType]==XFDeviceType_iPad) {
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = sender;
        popPresenter.sourceRect = sender.bounds;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark >> Log <<

- (NSMutableString *)log
{
    if (!_log) {
        _log = [NSMutableString string];
    }
    return _log;
}

- (void)xf_Log:(NSString *)logX
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"[HH:mm:ss.SSS]："];
        NSString *date = [formatter stringFromDate:[NSDate date]];

        [self.log appendFormat:@"%@%@\r\n", date, logX];
        NSLog(@"%@%@\r\n", date, logX);

        self.textView.text = self.log;
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
    });
}

@end
