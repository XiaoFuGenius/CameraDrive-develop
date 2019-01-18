//
//  EasyCameraViewController.m
//  Demo-OC
//
//  Created by 胡文峰 on 2019/1/3.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

#import "EasyCameraViewController.h"
#import <Photos/Photos.h>
#import "CTSimpleNetwork.h"

// Privacy Status 状态
typedef NS_ENUM(NSInteger, XFUserAuthorizationStatus) {
    XFUserAuthorizationStatus_ErrorParam                = 0,
    XFUserAuthorizationStatus_NotSupport                = 1,

    XFUserAuthorizationStatus_NotDetermined             = 2,
    XFUserAuthorizationStatus_Restricted                = 3,
    XFUserAuthorizationStatus_Denied                    = 4,
    XFUserAuthorizationStatus_Authorized                = 5,

    XFUserAuthorizationStatus_LocAuthorizedWhenInUse    = 6,
    XFUserAuthorizationStatus_LocAuthorizedAlways       = 7,
};
typedef void (^XFUserRightsCallBack)(BOOL authorized, XFUserAuthorizationStatus status, NSError *error);

@interface EasyCameraViewController ()
@property (nonatomic, strong) CTCameraHelper *camera;
@property (nonatomic, strong) CTEasyCamera *easyCamera;

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, assign) int ledMode;

@property (nonatomic, strong) UIButton *layerBtn;
@property (nonatomic, strong) UIButton *captureBtn;
@property (nonatomic, strong) UIButton *exitBtn;

@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, assign) BOOL displayLayer;
@property (nonatomic, assign) int successCount;
@property (nonatomic, assign) int failureCount;

@property (nonatomic, assign) BOOL loaded;
@end

@implementation EasyCameraViewController

- (void)dealloc
{
    self.param = nil;
    self.logHandler = nil;

    [self.cameraView removeFromSuperview];
    self.cameraView = nil;

    NSLog(@"【dealloc】%@", self);

    [self stopCamera];
    [self resetCameraAfterCtrDealloc];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    @synchronized (self) {  // 初始化操作仅调用一次
        if (!self.loaded) {
            self.loaded = YES;
            [self prepareForCameraStart];
            [self startCamera];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = XFColor(0x000000, 1.0f);

    self.ip = self.param[@"IP"];
    [self.view addSubview:self.cameraView];

    [self setupMainButtons];

    self.displayView.alpha = 0.0f;
    [self.view addSubview:self.displayView];
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

#pragma mark >>> main buttons <<<
- (void)setupMainButtons
{
    CGFloat btnWidth = (kWidth-15*2-20*2)/3;
    CGFloat btnHeight = 45;

    CGRect frame = CGRectMake([self.view xf_GetWidth]-15-btnWidth,
                              [self.view xf_GetHeight]-15-btnHeight, btnWidth, btnHeight);
    UIButton *exitBtn = [self setupButtonTitle:@"Exit" Action:@selector(exitBtnClick:) Frame:frame];
    [self.view addSubview:exitBtn];
    self.exitBtn = exitBtn;

    frame = CGRectMake([exitBtn xf_GetLeft]-20-btnWidth, [exitBtn xf_GetTop], btnWidth, btnHeight);
    UIButton *captureBtn = [self setupButtonTitle:@"Capture"
                                           Action:@selector(captureBtnClick:) Frame:frame];
    [self.view addSubview:captureBtn];
    self.captureBtn = captureBtn;

    frame = CGRectMake([captureBtn xf_GetLeft]-20-btnWidth, [exitBtn xf_GetTop], btnWidth, btnHeight);
    UIButton *layerBtn = [self setupButtonTitle:@"Layer" Action:@selector(layerBtnClick:) Frame:frame];
    [self.view addSubview:layerBtn];
    self.layerBtn = layerBtn;

    [self updateActionButtonStatus:NO];
}

- (UIButton *)setupButtonTitle:(NSString *)title Action:(SEL)action Frame:(CGRect)frame
{
    UIButton *button = [UIButton XF_ButtonWithColor:[UIColor clearColor] Image:nil
                                              Title:title Font:XFFont(15)
                                         TitleColor:XFColor(0xffffff, 1.0f) Target:self
                                             Action:action Frame:frame];
    button.selected = YES;
    button.userInteractionEnabled = YES;

    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.layer.cornerRadius = 3.0f;
    button.clipsToBounds = YES;
    [button xf_SetBackgroundColor:XFColor(0xcecece, 1.0f) forState:UIControlStateNormal];
    [button xf_SetBackgroundColor:XFColor(0x4d7bfe, 1.0f) forState:UIControlStateSelected];
    [button xf_SetBackgroundColor:XFColor(0x4d7bfe, 0.75f)
                         forState:UIControlStateSelected | UIControlStateHighlighted];
    return button;
}

- (void)exitBtnClick:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)captureBtnClick:(UIButton *)sender
{
    NSString *rgbName = [self GetFilePath:@"rgbName"];
    NSString *plName = [self GetFilePath:@"plName"];

    [self DeleteFileAtPath:rgbName];
    [self DeleteFileAtPath:plName];

    [self updateActionButtonStatus:NO];

    XFWeakSelf(weakSelf);
    [self.easyCamera captureRgbFilePath:rgbName PlFilePath:plName
                                Handler:^(NSInteger status, NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateActionButtonStatus:YES];

            if (status==0) {
                NSString *rgbNameX = [weakSelf GetFilePath:@"rgbName"];
                NSString *plNameX = [weakSelf GetFilePath:@"plName"];
                NSData *rgbData = [weakSelf ReadFileAtPath:rgbNameX];
                NSData *plData = [weakSelf ReadFileAtPath:plNameX];

                if (![rgbData xf_NotNull] || ![plData xf_NotNull]) {
                    [weakSelf showAlertViewMsg:@"未成功获取照片数据，请重试."];
                    return;
                }

                weakSelf.displayLayer = NO;
                UIImageView *imageView = weakSelf.displayView.subviews.firstObject;
                imageView.image = [UIImage imageWithData:rgbData];

                [UIView animateWithDuration:0.3f animations:^{
                    weakSelf.displayView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    UIButton *apiTest2Btn = weakSelf.displayView.subviews.lastObject;
                    apiTest2Btn.xf_object = nil;
                }];
            } else {
                [weakSelf showAlertViewMsg:description];
            }
        });
    }];
}

- (void)layerBtnClick:(UIButton *)sender
{
    self.ledMode = self.ledMode==0?1:0;
    self.camera.ledMode = self.ledMode;
}

- (void)updateActionButtonStatus:(BOOL)isActived
{
    self.layerBtn.selected = isActived;
    self.layerBtn.userInteractionEnabled = isActived;
    self.captureBtn.selected = isActived;
    self.captureBtn.userInteractionEnabled = isActived;
}

#pragma mark >>> camera <<<
- (CTCameraHelper *)camera
{
    return [CTCameraHelper SharedCameraHelper];
}

- (CTEasyCamera *)easyCamera
{
    return [CTEasyCamera SharedEasyCamera];
}

- (void)prepareForCameraStart
{
    self.camera.renderingBitrate = 800;
    self.camera.ledMode = 0;
    self.camera.isRetroflexion = YES;
    self.camera.ip = self.ip;
    self.camera.port = 1000;
    [self.camera loadBearerView:self.cameraView Handler:^(NSInteger status, NSString *description) {
        NSLog(@"%@", description);
    }];
}

- (void)resetCameraAfterCtrDealloc
{
    [self.camera unloadBearerView:^(NSInteger status, NSString *description) {
        NSLog(@"%@", description);
    }];
}

- (void)startCamera
{
    XFWeakSelf(weakSelf);
    self.easyCamera.startLoadingHnadler = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateActionButtonStatus:NO];
        });
    };

    self.easyCamera.startTimeoutHandler = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf cameraStartTimeoutHandler];
        });
    };

    self.easyCamera.captureTimeoutHandler = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf captureTimeoutHandler];
        });
    };

    [self.easyCamera start:^(NSInteger status, NSString * _Nullable description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", description);
            [weakSelf cameraStatusUpdate:status==0];

        });
    }];
}

- (void)stopCamera
{
    [self.easyCamera stop:^(NSInteger status, NSString *description) {
        NSLog(@"%@", description);
    }];
}

- (void)cameraStatusUpdate:(BOOL)isOK
{
    if (!isOK) {
        [self showAlertViewMsg:@"摄像头发生错误，当前已关闭，可尝试重启或者退出当前控制器."];
        return;
    }

    NSLog(@"摄像头 当前已启动.");
    self.camera.ledMode = self.ledMode;
    [self updateActionButtonStatus:YES];
}

- (void)cameraInterruptedHandler
{
    [self showAlertViewMsg:@"测肤仪断开连接,请重新连接"];
}

- (void)cameraStartTimeoutHandler
{
    [self showAlertViewMsg:@"摄像头启动失败，可继续等待或退出并重启测肤仪后再次连接"];
}

- (void)captureTimeoutHandler
{
    [self showAlertViewMsg:@"图像采集失败，请再试一次吧"];
}

#pragma mark >>> cameraView <<<
- (UIView *)cameraView
{
    if (!_cameraView) {
        CGRect frame = CGRectMake(0, 0, kWidth, kWidth*16/9);
        _cameraView = [UIView XF_ViewWithColor:[UIColor clearColor] Frame:frame];
    }
    return _cameraView;
}

#pragma mark >>> displayView <<<
- (UIView *)displayView
{
    if (!_displayView) {
        CGRect frame = CGRectMake(0, 0, kWidth, kHeight);
        _displayView = [UIView XF_ViewWithColor:[UIColor blackColor] Frame:frame];

        frame = CGRectMake(0, 0, kWidth, kWidth*16/9);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_displayView addSubview:imageView];

        CGFloat btnWidth = (kWidth-15*2-20*2)/3;
        CGFloat btnHeight = 45;
        frame = CGRectMake(15, kHeight-15-btnHeight, btnWidth, btnHeight);
        UIButton *backBtn = [self setupButtonTitle:@"Back"
                                            Action:@selector(displayViewBackBtnClick:) Frame:frame];
        [_displayView addSubview:backBtn];

        frame = CGRectMake([backBtn xf_GetRight]+20, kHeight-15-btnHeight, btnWidth, btnHeight);
        UIButton *layerBtn = [self setupButtonTitle:@"Layer"
                                             Action:@selector(displayViewLayerBtnClick:) Frame:frame];
        [_displayView addSubview:layerBtn];

        frame = CGRectMake([layerBtn xf_GetRight]+20, kHeight-15-btnHeight, btnWidth, btnHeight);
        UIButton *saveBtn = [self setupButtonTitle:@"Save"
                                            Action:@selector(displayViewSaveBtnClick:) Frame:frame];
        [_displayView addSubview:saveBtn];

        frame = CGRectMake([saveBtn xf_GetLeft], XFSafeTop + (44.0f-btnHeight)/2, btnWidth, btnHeight);
        UIButton *apiTest1Btn = [self setupButtonTitle:@"ApiTest1"
                                                Action:@selector(displayViewApiTest1BtnClick:) Frame:frame];
        [_displayView addSubview:apiTest1Btn];

        frame = CGRectMake([saveBtn xf_GetLeft], [apiTest1Btn xf_GetBottom]+20, btnWidth, btnHeight);
        UIButton *apiTest2Btn = [self setupButtonTitle:@"ApiTest2"
                                                Action:@selector(displayViewApiTest2BtnClick:) Frame:frame];
        [_displayView addSubview:apiTest2Btn];
    }
    return _displayView;
}

- (void)displayViewBackBtnClick:(UIButton *)sender
{
    [UIView animateWithDuration:0.3f animations:^{
        self.displayView.alpha = 0.0f;
    } completion:nil];
}

- (void)displayViewLayerBtnClick:(UIButton *)sender
{
    NSString *rgbName = [self GetFilePath:@"rgbName"];
    NSString *plName = [self GetFilePath:@"plName"];

    self.displayLayer = !self.displayLayer;

    NSString *fileName = self.displayLayer?plName:rgbName;
    UIImageView *imageView = self.displayView.subviews.firstObject;
    imageView.image = [UIImage imageWithData:[self ReadFileAtPath:fileName]];
}

- (void)displayViewSaveBtnClick:(UIButton *)sender
{
    XFWeakSelf(weakSelf);
    [self PhotosRightsCheckAndRequest:YES Completion:^(BOOL authorized,
                                                       XFUserAuthorizationStatus status,
                                                       NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (authorized) {
                NSString *rgbName = [weakSelf GetFilePath:@"rgbName"];
                NSString *plName = [weakSelf GetFilePath:@"plName"];

                weakSelf.successCount = 0;
                weakSelf.failureCount = 0;

                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    UIImage *rgbImage = [UIImage imageWithData:[weakSelf ReadFileAtPath:rgbName]];
                    PHAssetChangeRequest* req = [PHAssetChangeRequest creationRequestForAssetFromImage:rgbImage];
                    NSLog(@"rgb - %@", req.placeholderForCreatedAsset.localIdentifier);
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    weakSelf.successCount += success ? 1 : 0;
                    weakSelf.failureCount += success ? 0 : 1;
                    [weakSelf photoSavedCheckIsRgb:YES Success:success];
                }];

                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    UIImage *plImage = [UIImage imageWithData:[weakSelf ReadFileAtPath:plName]];
                    PHAssetChangeRequest* req = [PHAssetChangeRequest creationRequestForAssetFromImage:plImage];
                    NSLog(@"pl - %@", req.placeholderForCreatedAsset.localIdentifier);
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    weakSelf.successCount += success ? 1 : 0;
                    weakSelf.failureCount += success ? 0 : 1;
                    [weakSelf photoSavedCheckIsRgb:NO Success:success];
                }];

            } else {
                [weakSelf showAlertViewMsg:@"保存失败，未取得相册访问权限"];
            }
        });
    }];
}

- (void)photoSavedCheckIsRgb:(BOOL)isRgb Success:(BOOL)success
{
    if (!success) {
        [self showAlertViewMsg:isRgb?@"标准光 图片保存失败":@"偏振光 图片保存失败"];
        return;
    }

    if (2 == self.successCount+self.failureCount &&
        0 == self.failureCount) {
        [self showAlertViewMsg:@"图片已保存至相册"];
    }
}

#pragma mark > 图像检测api，测试样例 <
- (void)displayViewApiTest1BtnClick:(UIButton *)sender
{
    NSString *rgbNameX = [self GetFilePath:@"rgbName"];
    NSString *plNameX = [self GetFilePath:@"plName"];
    NSData *rgbData = [self ReadFileAtPath:rgbNameX];
    NSData *plData = [self ReadFileAtPath:plNameX];

    if (![rgbData xf_NotNull] || ![plData xf_NotNull]) {
        [self showAlertViewMsg:@"没有照片数据，请重新拍摄"];
        return;
    }

    /** 小肤检测详情接口
     “全脸检测”需要采集“脸部5个部位”的图像数据，此处用了”1组图像数据(扩展为5组)“进行测试；
     结果不具有参考价值，仅用于验证“api接口”的有效性，请了解；
     */
    NSDictionary *imageDict = @{@"forehead_rgb":[rgbData copy],
                                @"forehead_pl":[plData copy],
                                @"leftface_rgb":[rgbData copy],
                                @"leftface_pl":[plData copy],
                                @"rightface_rgb":[rgbData copy],
                                @"rightface_pl":[plData copy],
                                @"nose_rgb":[rgbData copy],
                                @"nose_pl":[plData copy],
                                @"chin_rgb":[rgbData copy],
                                @"chin_pl":[plData copy],
                                };

    [XFLoadingWindow ShowSreenLock:YES];
    XFBlockObject(imageDict, blockImageDict);
    XFWeakSelf(weakSelf);

    NSDictionary *param = @{@"appId":kAuthKey};
    [CTSimpleNetwork PostHttpDataWithUrlStr:kServerUrl(@"external/putDistinguishResult2")
                                      Param:param
                  ConstructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        for (int i = 0; i < blockImageDict.allKeys.count; i++) {
            NSString *key = blockImageDict.allKeys[i];
            [formData appendPartWithFileData:blockImageDict[key] name:key
                                    fileName:key mimeType:@"image/jpg"];
        }

    } Progress:nil SuccessBlock:^(id responseObject) {

        [XFLoadingWindow Hide];
        NSString *distinguishId = responseObject[@"Data"][@"DistinguishId"];
        if ([distinguishId xf_NotNull]) {
            UIButton *apiTest2Btn = weakSelf.displayView.subviews.lastObject;
            apiTest2Btn.xf_object = distinguishId;
        }

        NSLog(@"%@", responseObject);

        NSString *msg = @"请求成功.apiTest1\n";
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"Data"] xf_NotNull]) {
            msg = [msg stringByAppendingString:@"已获取到响应数据，请至控制台查看日志."];
        }
        [weakSelf showAlertViewMsg:msg];

    } FailureBlock:^(id error) {

        [XFLoadingWindow Hide];
        NSLog(@"%@", error);
        NSString *msg = [NSString stringWithFormat:@"%@", error];
        [weakSelf showAlertViewMsg:msg];

    }];
}

- (void)displayViewApiTest2BtnClick:(UIButton *)sender
{
    if (!sender.xf_object) {
        [self showAlertViewMsg:@"请先调用”ApiTest1“"];
        return;
    }

    [XFLoadingWindow ShowSreenLock:YES];
    XFWeakSelf(weakSelf);

    NSString *distinguishId = sender.xf_object;
    NSDictionary *param = @{@"appId":kAuthKey,
                            @"distinguishId":distinguishId};

    [CTSimpleNetwork PostHttpDataWithUrlStr:kServerUrl(@"external/distinguishDetail2")
                                      Param:param ConstructingBodyWithBlock:nil Progress:nil
                               SuccessBlock:^(id responseObject) {

        [XFLoadingWindow Hide];
        UIButton *apiTest2Btn = weakSelf.displayView.subviews.lastObject;
        apiTest2Btn.xf_object = nil;

        NSLog(@"%@", responseObject);

        NSString *msg = @"请求成功.apiTest2\n";
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"Data"] xf_NotNull]) {
            msg = [msg stringByAppendingString:@"已获取到响应数据，请至控制台查看日志."];
        }
        [weakSelf showAlertViewMsg:msg];

    } FailureBlock:^(id error) {

        [XFLoadingWindow Hide];
        NSLog(@"%@", error);
        NSString *msg = [NSString stringWithFormat:@"%@", error];
        [weakSelf showAlertViewMsg:msg];

    }];
}

#pragma mark >>> alert message <<<
- (void)showAlertViewMsg:(NSString *)msg  // 针对于性能较低的设备，大量数据的msg会阻塞主线程；
{
    XFWeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:nil message:msg
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault
                                                handler:nil]];
        [weakSelf presentViewController:alert animated:YES completion:nil];
    });
}

- (void)displayLog:(NSString *)log
{
    NSLog(@"[%@] %@", self, log);
    if (self.logHandler) {
        self.logHandler(log);
    }
}

#pragma mark >>> file operation <<<
- (NSString *)GetFilePath:(NSString*)FileName
{
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                  NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:FileName];
    return filePath;
}

- (NSData *)ReadFileAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        return [NSData dataWithContentsOfFile:path];
    }

    return nil;
}

- (BOOL)DeleteFileAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        if (!error) {
            return YES;
        }
    }

    return NO;
}

#pragma mark >>> user rights request <<<
- (void)PhotosRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion
{
    BOOL available = [UIImagePickerController
                      isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if (!available) {
        if (completion) completion(NO, XFUserAuthorizationStatus_NotSupport, nil);
        return;
    }

    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    switch (authStatus) {
            case PHAuthorizationStatusNotDetermined:{
                if (!request) {
                    if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
                    return;
                }

                XFWeakSelf(weakSelf);
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    [weakSelf PhotosRightsCheckAndRequest:NO Completion:completion];
                }];
                break;
            }
            case PHAuthorizationStatusRestricted:{
                if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
                break;
            }
            case PHAuthorizationStatusDenied:{
                if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
                break;
            }
            case PHAuthorizationStatusAuthorized:{
                if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
                break;
            }
        default:{
            break;
        }
    }
}
@end
