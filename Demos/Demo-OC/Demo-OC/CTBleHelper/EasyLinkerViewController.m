//
//  EasyLinkerViewController.m
//  Demo-OC
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import "EasyLinkerViewController.h"
#import "CameraHelperViewController.h"

@interface EasyLinkerViewController ()
@property (nonatomic, strong) UIButton *startScan;
@property (nonatomic, strong) UIButton *stopScan;
@property (nonatomic, strong) UIButton *startBind;
@property (nonatomic, strong) UIButton *disConnect;
@property (nonatomic, strong) UIButton *getInfo;
@property (nonatomic, strong) UIButton *autoLink;
@property (nonatomic, strong) UIButton *startCamera;
@property (nonatomic, strong) UIButton *startBleUpgrade;
@property (nonatomic, strong) UIButton *startCoreUpgrade;
@property (nonatomic, strong) UIButton *setWiredMode;
@property (nonatomic, strong) UIButton *calibration;
@property (nonatomic, strong) UIButton *shutdown;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, assign) BOOL bleActived;
@property (nonatomic, assign) BOOL isAutoBind;  // 搜索完成后，是否自动连接设备蓝牙

@property (nonatomic, strong) NSMutableString *log;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, assign) BOOL autoByRSSI;  // 根据设备的信号强度判定连接，20cm -> -60 rssi
@property (nonatomic, strong) NSTimer *autoBindTimer;  // 不根据设备的信号强度判定连接的时候，设定搜索超时时长
@property (nonatomic, assign) NSTimeInterval autoBindStartTime;

@property (nonatomic, strong) NSArray *devices;  // 已扫描到的附近设备列表
@property (nonatomic, strong) NSDictionary *targetDevice;  // 目标连接设备

@property (nonatomic, assign) BOOL apLinkCheck;
@property (nonatomic, strong) NSString *apLinkSSID;
@property (nonatomic, strong) NSString *ip;

@property (nonatomic, assign) int upgradeValue;
@property (nonatomic, assign) BOOL shouldReset;  // 用于判定是否进入图像采集控制器
@end

@implementation EasyLinkerViewController

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
        [CTBleHelper StopScan];
        [CTBleHelper Disconnect];
        [CTBleHelper CleanDeviceCache];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"CTEasyLinker";
    self.view.backgroundColor = XFColor(0xf6f6f6, 1.0f);

    self.isAutoBind = YES;
    self.autoByRSSI = YES;

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
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter removeObserver:self name:CT_iPhone_BleUpdate object:nil];
    [notiCenter addObserver:self selector:@selector(CT_iPhone_BleUpdate:)
                       name:CT_iPhone_BleUpdate object:nil];

    if ([CTBleHelper BlePowerdOn]==-1) {
        [self xf_Log:@"等待< 用户给予蓝牙权限 >或< Sdk内部启动蓝牙模块 >."];
        self.bleActived = NO;
        return;
    }
    self.bleActived = YES;

    self.startScan.userInteractionEnabled = YES;
    self.startScan.selected = YES;
    [self xf_Log:@"准备就绪..."];

    [self configXiaoFuSdk];

    if (![CTBleHelper BlePowerdOn]) {
        [self xf_Log:@"手机蓝牙已关闭."];
        return;
    }
    [self xf_Log:@"手机蓝牙已打开."];
}

- (void)configXiaoFuSdk
{
    XFWeakSelf(weakSelf);
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];

    CTConfig *config = [CTConfig Shared];
    
    config.debugEnable = YES;
    config.debugLogType = 1;
    config.debugLogHandler = ^(NSString *log) {
        [weakSelf xf_Log:log];
    };
    
//    config.blueStripDetectionHandler = ^(UIImage *blueStripImage) {
//        [weakSelf xf_Log:@"当前图片检测到蓝条，可选择记录日志或者图片数据。"];
//    };  // 1.0.17 新增，蓝条检测
    //[CTConfig Shared].blueStripDetectionType = 1;
    
    config.channelSetting = -1;  // 1.0.17 新增，AP模式，随机信道
    config.splitStrings = @[@"!@"];

    [notiCenter addObserver:self selector:@selector(CT_Device_ScanUpdate:)
                       name:CT_Device_ScanUpdate object:nil];
    [notiCenter addObserver:self selector:@selector(CT_Device_BleUpdate:)
                       name:CT_Device_BleUpdate object:nil];
    [notiCenter addObserver:self selector:@selector(CT_Device_BatteryUpdate:)
                       name:CT_Device_BatteryUpdate object:nil];

    CTEasyLinker *easyLinker = [CTEasyLinker SharedEsayLinker];
    easyLinker.smartMode = 1;
    easyLinker.verify5GEnabled = YES;
    easyLinker.staPingEnabled = YES;
    easyLinker.staCachesStored = YES;
    easyLinker.ssidIgnored = @[@"CFY_"];
    easyLinker.hotspotEnabled = YES;

    easyLinker.preparedForAP = ^(NSString * _Nonnull ssid, NSString * _Nonnull password) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf preparedForAP:ssid password:password];
        });
    };

    easyLinker.preparedForSTA = ^(NSString * _Nonnull ssid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf preparedForSTA:ssid];
        });
    };

    easyLinker.responseForSTA = ^(CTBleResponseCode code, int wifiStatus, NSString * _Nonnull ip) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf responseForSTA:code wifiStatus:wifiStatus ip:ip];
        });
    };

    easyLinker.networkLinkResponse = ^(CTBleResponseCode code, int type, NSString * _Nonnull ip) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf networkLinkResponse:code type:type ip:ip];
        });
    };

    // 可选...
    easyLinker.staStartResponse = ^{
        [weakSelf xf_Log:@"启动 STA模式 联网进程."];
    };

    easyLinker.verify5GResponse = ^(BOOL isStart, CTBleResponseCode code) {
        NSString *log = [NSString stringWithFormat:@"%@.", isStart?@"开始5G网络检测...":@"5G网络检测已结束"];
        [weakSelf xf_Log:log];
    };

    easyLinker.staPingResponse = ^(BOOL isStart, CTBleResponseCode code) {
        NSString *log = [NSString stringWithFormat:@"%@.", isStart?@"开始Ping网络检测...":@"Ping网络检测已结束"];
        [weakSelf xf_Log:log];
    };

    easyLinker.apStartResponse = ^{
        [weakSelf xf_Log:@"启动 AP模式 联网进程."];
    };

    easyLinker.hotspotResponse = ^(BOOL isStart, CTBleResponseCode code) {
        NSString *log = [NSString stringWithFormat:@"%@.", isStart?@"开始启动Hotspot进程...":@"Hotspot进程已结束"];
        [weakSelf xf_Log:log];
    };

    easyLinker.verifyIpAddressResponse = ^(BOOL isStart, CTBleResponseCode code) {
        NSString *log = [NSString stringWithFormat:@"%@.", isStart?@"开始启动 IP地址检测 进程...":@"IP地址检测 进程已结束"];
        [weakSelf xf_Log:log];
    };
}

- (void)CT_iPhone_BleUpdate:(NSNotification *)noti
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

- (void)CT_Device_ScanUpdate:(NSNotification *)noti
{
    XFWeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *devices = [NSMutableArray array];
        NSArray *list = noti.userInfo[@"Devices"];
        for (NSDictionary *device in list) {
            if ([device[@"Name"] xf_NotNull] && [device[@"BindID"] xf_NotNull]) {
                NSString *deviceInfo = [NSString stringWithFormat:@"Name:%@, BindID:%@, RSSI:%@.",\
                                        device[@"Name"], device[@"BindID"], device[@"RSSI"]];
                NSLog(@"%@", deviceInfo);

                if (weakSelf.autoByRSSI) {
                    if ([device[@"RSSI"] intValue] < 0 &&
                        [device[@"RSSI"] intValue] >= -60) {  // 20cm -> -60 rssi
                        [devices addObject:[device copy]];
                    }
                } else {
                    [devices addObject:[device copy]];
                }
            } else {
                [weakSelf xf_Log:@"[WARNING]设备信息有空值，请反馈给开发者."];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{  // 会被触发多次..
            if (!weakSelf.autoBindTimer) {
                [weakSelf xf_Log:@"已停止扫描，放弃处理扫描结果."];
                return;
            }

            weakSelf.devices = [devices copy];
            if (weakSelf.autoByRSSI && weakSelf.devices.count>0) {
                [weakSelf xf_Log:@"自动停止扫描 - 来自设备的信号强度判定."];
                [CTBleHelper StopScan];

                weakSelf.stopScan.userInteractionEnabled = NO;
                weakSelf.stopScan.selected = NO;

                [weakSelf.autoBindTimer invalidate];
                weakSelf.autoBindTimer = nil;
                [weakSelf autoBind];
            }
        });
    });
}

- (void)CT_Device_BleUpdate:(NSNotification *)noti
{
    XFWeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"CT_Device_BleUpdate：%d, %@, %d", [noti.userInfo[@"ConnectStatus"] intValue], noti.userInfo[@"Msg"], [CTBleHelper ConnectStatus]);

        if ([CTBleHelper ConnectStatus] == 2) {

            [weakSelf xf_Log:@"设备蓝牙已连接."];

            NSDictionary *device = [CTBleHelper DeviceInfoCache];
            NSString *deviceInfo = [NSString stringWithFormat:@"%@，%@，%d，ble：%@，core：%@ .", \
                                    device[@"Name"], device[@"BindID"], \
                                    [weakSelf.targetDevice[@"RSSI"] intValue], \
                                    device[@"BleVersionString"], device[@"CoreVersionString"]];
            [weakSelf xf_Log:deviceInfo];

            weakSelf.title = [deviceInfo componentsSeparatedByString:@"，ble"].firstObject;
            [weakSelf updateUI4BleConnected];

        } else if ([CTBleHelper ConnectStatus] == 0) {

            [weakSelf xf_Log:@"设备蓝牙已断开连接(主动)."];
            [weakSelf resetUI];

        } else if ([CTBleHelper ConnectStatus] == -1) {

            [weakSelf xf_Log:@"未成功连接设备蓝牙."];
            [weakSelf resetUI];

        } else if ([CTBleHelper ConnectStatus] == -2) {

            [weakSelf xf_Log:@"设备蓝牙已断开连接(被动)."];
            [weakSelf resetUI];

        }
    });

}

- (void)CT_Device_BatteryUpdate:(NSNotification *)noti
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

- (void)preparedForAP:(NSString *)ssid password:(NSString *)password
{
    [self showAPLinkAlert:ssid];
}

- (void)preparedForSTA:(NSString *)ssid
{
    [self confirmShowSTALinkAlert];
}

- (void)responseForSTA:(CTBleResponseCode)code wifiStatus:(int)wifiStatus ip:(NSString *)ip
{
    if (code==CTBleResponseError) {
        self.maskView.hidden = YES;
        [self xf_Log:@"STA模式未成功联网，命令请求失败."];
        return;
    }

    if (wifiStatus == 0) {
        [self xf_Log:@"STA模式连接已完成."];
        return;
    }

    /** 可见 CTEasyLinker.h 中的方法回调说明；
     注：wifiStatus -3：未搜索到ssid（设备固件版本可能过旧），-2：命令请求失败或超时，-1：密码错误，0：请求成功；
     注：较”CTBleHelper“，wifiStatus -101：5g检查，判定为5g网络，-102：ping检查，判定为公共验证类wifi；
     */
    self.maskView.hidden = YES;
    if (wifiStatus == -1) {

        [self xf_Log:@"密码错误，请重新输入."];
        [self performSelector:@selector(confirmShowSTALinkAlert) withObject:nil afterDelay:0.91f];

    } else if (wifiStatus == -3) {

        [self xf_Log:@"设备(固件版本旧)，未搜索到指定ssid，请使用AP模式联网."];

    } else if (wifiStatus == -101) {

        UIAlertController *alert5G = [UIAlertController
                                      alertControllerWithTitle:@"5g检查，判定为5g网络"
                                      message:@"设备 当前“不支持”5G网络 联网，请使用AP模式联网或重试."
                                      preferredStyle:UIAlertControllerStyleAlert];
        [alert5G addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel
                                                  handler:nil]];
        [self showAlert:alert5G Sender:self.autoLink];

    } else if (wifiStatus == -102) {

        UIAlertController *alertPing = [UIAlertController
                                        alertControllerWithTitle:@"ping检查，判定为公共验证类wifi"
                                        message:@"设备 当前“不支持”公共验证类wifi 联网，请使用AP模式联网或重试."
                                        preferredStyle:UIAlertControllerStyleAlert];
        [alertPing addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel
                                                  handler:nil]];
        [self showAlert:alertPing Sender:self.autoLink];

    }
}

- (void)networkLinkResponse:(CTBleResponseCode)code type:(int)type ip:(NSString *)ip
{
    self.maskView.hidden = YES;

    if (code==CTBleResponseOK) {
        self.ip = ip;

        self.autoLink.userInteractionEnabled = NO;
        self.autoLink.selected = NO;
        self.startCamera.userInteractionEnabled = YES;
        self.startCamera.selected = YES;
        self.startCoreUpgrade.userInteractionEnabled = YES;
        self.startCoreUpgrade.selected = YES;

        NSString *msg = [NSString stringWithFormat:@"设备已联网(%@，ip：%@).", type==1?@"STA模式":@"AP模式", ip];
        [self xf_Log:msg];
    } else {
        [self xf_Log:@"设备联网失败，请重新尝试(若多次联网失败，建议先重启设备)."];
    }

    self.maskView.hidden = YES;
}

#pragma mark > STA Mode <
- (void)confirmShowSTALinkAlert
{
    XFWeakSelf(weakSelf);
    [[CTConfig Shared] wifiSSID:YES Callback:^(NSString *iPhone_ssid, NSDictionary *locRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![iPhone_ssid xf_NotNull]) {
                [weakSelf xf_Log:@"showSTALinkAlert，启动失败，未获取到ssid."];
                return;
            }

            weakSelf.maskView.hidden = NO;

            NSString *pwd = [CTEasyLinker STACachesContains:iPhone_ssid];
            if (pwd) {
                [weakSelf xf_Log:@"该wifi已保存密码，无需再次输入密码."];
                [weakSelf confirmSTAlink_SSID:iPhone_ssid Pwd:pwd];
                return;
            }

            UIAlertController *staAlert = [UIAlertController
                                           alertControllerWithTitle:@"输入wifi密码" message:iPhone_ssid
                                           preferredStyle:UIAlertControllerStyleAlert];
            [staAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                //可自定义textField相关属性...
            }];
            [staAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.maskView.hidden = YES;
                [weakSelf xf_Log:@"已取消sta连接."];
            }]];
            [staAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                NSString *pwd = staAlert.textFields.firstObject.text;
                [weakSelf confirmSTAlink_SSID:iPhone_ssid Pwd:pwd];
            }]];
            [weakSelf showAlert:staAlert Sender:weakSelf.autoLink];
        });
    }];
}

- (void)confirmSTAlink_SSID:(NSString *)ssid Pwd:(NSString *)pwd
{
    NSString *log = [NSString stringWithFormat:@"ssid：%@，pwd：%@ .", ssid, pwd];
    [self xf_Log:@"开始启动STA模式连接..."];
    [self xf_Log:log];
    [CTEasyLinker STA:ssid Password:pwd];
}

#pragma mark > AP Mode <
- (void)showAPLinkAlert:(NSString *)ssid
{
    self.apLinkSSID = ssid;

    XFWeakSelf(weakSelf);

    UIAlertController *apAlert = [UIAlertController
                                  alertControllerWithTitle:@"前往设置连接指定热点" message:ssid
                                  preferredStyle:UIAlertControllerStyleAlert];
    [apAlert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.maskView.hidden = YES;
        [weakSelf xf_Log:@"已取消ap连接."];
    }]];
    [apAlert addAction:[UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
        [XFAppDelegate XF_ApplicationOpenSettingsType:2];

        weakSelf.apLinkCheck = YES;
        NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
        [notiCenter removeObserver:weakSelf name:UIApplicationWillEnterForegroundNotification object:nil];
        [notiCenter addObserver:weakSelf selector:@selector(applicationWillEnterForeground)
                           name:UIApplicationWillEnterForegroundNotification object:nil];
    }]];
    [self showAlert:apAlert Sender:self.autoLink];
}

- (void)applicationWillEnterForeground
{
    XFWeakSelf(weakSelf);
    [[CTConfig Shared] wifiSSID:YES Callback:^(NSString *iPhone_ssid, NSDictionary *locRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([iPhone_ssid isEqualToString:weakSelf.apLinkSSID]) {
                weakSelf.apLinkCheck = NO;
                NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
                [notiCenter removeObserver:weakSelf name:UIApplicationWillEnterForegroundNotification
                                    object:nil];

                [CTHotspotHelper IPAddressConfirmed:^(BOOL success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf startNetworkConnect];
                    });
                }];

            } else {
                [weakSelf showAPLinkAlert:weakSelf.apLinkSSID];
            }
        });
    }];
}

#pragma mark -
#pragma mark >> Actions <<

- (void)startScan:(UIButton *)sender
{
    if (![CTBleHelper BlePowerdOn]) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"请打开手机蓝牙" message:nil
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleCancel handler:nil]];
        [self showAlert:alert Sender:self.startScan];
        return;
    }

    if ([CTBleHelper ConnectStatus]==2) {
        [CTBleHelper Disconnect];
    }

    [self xf_Log:[NSString stringWithFormat:@"开始扫描，已选择%@连接模式.", self.isAutoBind?@"自动":@"手动"]];
    [CTBleHelper StartScan];

    self.startScan.userInteractionEnabled = NO;
    self.startScan.selected = NO;
    self.stopScan.userInteractionEnabled = YES;
    self.stopScan.selected = YES;

    //if (!self.isAutoBind) {
    //    return;
    //}

    // 启动扫描计时，10s
    if (self.autoBindTimer) {
        [self.autoBindTimer invalidate];
        self.autoBindTimer = nil;
    }
    self.autoBindTimer = [NSTimer timerWithTimeInterval:0.1f target:self
                                               selector:@selector(autoBindTimerRun:)
                                               userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoBindTimer forMode:NSRunLoopCommonModes];

    self.autoBindStartTime = [[NSDate date] timeIntervalSince1970];
    [self.autoBindTimer setFireDate:[NSDate date]];
}

- (void)stopScan:(UIButton *)sender
{
    [self xf_Log:@"手动停止扫描."];
    [CTBleHelper StopScan];

    [self.autoBindTimer invalidate];
    self.autoBindTimer = nil;

    self.title = @"CTEasyLinker";
    self.startScan.userInteractionEnabled = YES;
    self.startScan.selected = YES;
    self.stopScan.userInteractionEnabled = NO;
    self.stopScan.selected = NO;
}

- (void)startBind:(UIButton *)sender
{
    [self xf_Log:@"等待设备确认."];
    self.maskView.hidden = NO;
    self.startBind.userInteractionEnabled = NO;
    self.startBind.selected = NO;

    XFWeakSelf(weakSelf);
    [CTBleHelper Bind:^(CTBleResponseCode code, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.maskView.hidden = YES;
            weakSelf.startBind.userInteractionEnabled = YES;
            weakSelf.startBind.selected = YES;
            if (code==CTBleResponseOK) {
                [weakSelf xf_Log:@"设备已确认."];
            } else {
                [weakSelf xf_Log:@"设备确认失败."];
            }
        });
    }];
}

- (void)disConnect:(UIButton *)sender
{
    [CTBleHelper Disconnect];
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
        [[CTConfig Shared] wifiSSID:YES Callback:^(NSString *iPhone_ssid, NSDictionary *locRes) {
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

                    if (![iPhone_ssid xf_NotNull]) {
                        logMsg = @"UnKnown_手机未连接wifi，可启动ap模式.";
                    } else {
                        logMsg = @"UnKnown_手机已连接wifi，可启动sta模式.";
                    }

                } else if (type==1) {

                    if (![iPhone_ssid xf_NotNull]) {
                        logMsg = @"STA_手机未连接wifi，可启动ap模式.";
                    } else {
                        if ([iPhone_ssid isEqualToString:ssid]) {
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

                    if (![iPhone_ssid xf_NotNull]) {
                        logMsg = @"AP_手机未连接wifi，可启动ap模式.";
                    } else {
                        if ([iPhone_ssid isEqualToString:ssid]) {
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

- (void)autoLink:(UIButton *)sender
{
    XFWeakSelf(weakSelf);
    [[CTConfig Shared] wifiSSID:YES Callback:^(NSString *iPhone_ssid, NSDictionary *locRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![iPhone_ssid xf_NotNull]) {
                [weakSelf startNetworkConnect];
                return;
            }

            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:@"请选择网络连接类型" message:nil
                                        preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"STA" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [CTEasyLinker SharedEsayLinker].smartMode = 1;
                [weakSelf startNetworkConnect];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"AP" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [CTEasyLinker SharedEsayLinker].smartMode = 2;
                [weakSelf startNetworkConnect];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                    handler:nil]];
            [weakSelf showAlert:alert Sender:weakSelf.autoLink];
        });
    }];
}

- (void)startNetworkConnect
{
    [self xf_Log:@"[联网准备]开始获取设备网络状态..."];
    self.maskView.hidden = NO;

    [CTEasyLinker NetworkStatusCheckOnly:NO Response:nil];
}

- (void)startCamera:(UIButton *)sender
{
    [self xf_Log:[NSString stringWithFormat:@"开始启动摄像头[ip：%@]...", self.ip]];

    XFWeakSelf(weakSelf);
    CameraHelperViewController *cameraCtr = [[CameraHelperViewController alloc] init];
    cameraCtr.param = @{@"IP":[self.ip copy]};
    cameraCtr.logHandler = ^(NSString *log) {
        [weakSelf xf_Log:log];
    };

    self.shouldReset = NO;
    cameraCtr.modalPresentationStyle = UIModalPresentationFullScreen;
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
    [alert addAction:[UIAlertAction actionWithTitle:@"calibration（校准）" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf calibration:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"recalibration（回滚）" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf recalibration:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"restartNVDS（恢复配置）" style:UIAlertActionStyleDefault
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

#pragma mark - Others

- (void)autoBindTimerRun:(NSTimer *)timer
{
    if ([[NSDate date] timeIntervalSince1970] > self.autoBindStartTime+10.0f) {
        [self xf_Log:@"自动停止扫描 - 来自扫描计时."];
        [CTBleHelper StopScan];

        self.stopScan.userInteractionEnabled = NO;
        self.stopScan.selected = NO;

        [self.autoBindTimer invalidate];
        self.autoBindTimer = nil;
        [self autoBind];
    }
}

- (void)autoBind
{
    if (!self.devices || self.devices.count==0) {
        [self xf_Log:@"未扫描到任何设备."];
        self.title = @"CTEasyLinker";
        self.startScan.userInteractionEnabled = YES;
        self.startScan.selected = YES;
        return;
    }

    // 仅连接列表中信号强度最强的那个设备
    NSDictionary *device = self.devices.firstObject;
    for (NSDictionary *dev in self.devices) {
        if ([dev[@"RSSI"] intValue] > [device[@"RSSI"] intValue]) {
            device = [dev copy];
        }
    }

    self.targetDevice = device;
    [CTEasyLinker ConnectByName:device[@"Name"] BindID:device[@"BindID"]];
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
    UIButton *startScan = [self setupButtonTitle:@"startScan"
                                          Action:@selector(startScan:) Frame:frame];
    _startScan = startScan;
    [mainView addSubview:startScan];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *stopScan = [self setupButtonTitle:@"stopScan"
                                         Action:@selector(stopScan:) Frame:frame];
    _stopScan = stopScan;
    [mainView addSubview:stopScan];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    if (!self.isAutoBind) {
        frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
        UIButton *startBind = [self setupButtonTitle:@"startBind" Action:@selector(startBind:) Frame:frame];
        _startBind = startBind;
        [mainView addSubview:startBind];
        top += btnHeight+spacing;
        if (top+btnHeight+spacing > limitHeight) {
            left += btnWidth+20;
            top = [startScan xf_GetTop];
        }
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *disConnect = [self setupButtonTitle:@"disConnect" Action:@selector(disConnect:) Frame:frame];
    _disConnect = disConnect;
    [mainView addSubview:disConnect];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *getInfo = [self setupButtonTitle:@"getInfo"
                                           Action:@selector(getInfo:) Frame:frame];
    _getInfo = getInfo;
    [mainView addSubview:getInfo];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *startBleUpgrade = [self setupButtonTitle:@"startBleUpgrade"
                                                Action:@selector(startBleUpgrade:) Frame:frame];
    _startBleUpgrade = startBleUpgrade;
    [mainView addSubview:startBleUpgrade];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *autoLink = [self setupButtonTitle:@"autoLink"
                                         Action:@selector(autoLink:) Frame:frame];
    _autoLink = autoLink;
    [mainView addSubview:autoLink];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *startCamera = [self setupButtonTitle:@"startCamera"
                                            Action:@selector(startCamera:) Frame:frame];
    _startCamera = startCamera;
    [mainView addSubview:startCamera];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *startCoreUpgrade = [self setupButtonTitle:@"startCoreUpgrade"
                                                 Action:@selector(startCoreUpgrade:) Frame:frame];
    _startCoreUpgrade = startCoreUpgrade;
    [mainView addSubview:startCoreUpgrade];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *calibration = [self setupButtonTitle:@"calibration"
                                           Action:@selector(calibrationTools:) Frame:frame];
    _calibration = calibration;
    [mainView addSubview:calibration];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *setWiredMode = [self setupButtonTitle:@"wiredMode"
                                           Action:@selector(wiredMode:) Frame:frame];
    _setWiredMode = setWiredMode;
    [mainView addSubview:setWiredMode];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
    }

    frame = CGRectMake((int)left, (int)top, btnWidth, btnHeight);
    UIButton *shutdown = [self setupButtonTitle:@"shutdown" Action:@selector(shutdown:) Frame:frame];
    _shutdown = shutdown;
    [mainView addSubview:shutdown];
    top += btnHeight+spacing;
    if (top+btnHeight+spacing > limitHeight) {
        left += btnWidth+20;
        top = [startScan xf_GetTop];
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

    self.title = @"CTEasyLinker";
    self.startScan.userInteractionEnabled = YES;
    self.startScan.selected = YES;
    self.stopScan.userInteractionEnabled = NO;
    self.stopScan.selected = NO;

    self.startBind.userInteractionEnabled = NO;
    self.startBind.selected = NO;
    self.disConnect.userInteractionEnabled = NO;
    self.disConnect.selected = NO;
    self.shutdown.userInteractionEnabled = NO;
    self.shutdown.selected = NO;

    self.getInfo.userInteractionEnabled = NO;
    self.getInfo.selected = NO;
    self.autoLink.userInteractionEnabled = NO;
    self.autoLink.selected = NO;
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
    self.startScan.userInteractionEnabled = NO;
    self.startScan.selected = NO;
    self.stopScan.userInteractionEnabled = NO;
    self.stopScan.selected = NO;

    self.startBind.userInteractionEnabled = YES;
    self.startBind.selected = YES;

    self.disConnect.userInteractionEnabled = YES;
    self.disConnect.selected = YES;
    self.shutdown.userInteractionEnabled = YES;
    self.shutdown.selected = YES;

    self.getInfo.userInteractionEnabled = YES;
    self.getInfo.selected = YES;
    self.autoLink.userInteractionEnabled = YES;
    self.autoLink.selected = YES;
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
