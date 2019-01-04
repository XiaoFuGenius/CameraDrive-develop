//
//  XFDemoViewController.m
//  Demo-OC
//
//  Created by 胡文峰 on 2018/12/18.
//  Copyright © 2018 XIAOFUTECH. All rights reserved.
//

#import "XFDemoViewController.h"

@interface XFDemoViewController ()

@end

@implementation XFDemoViewController

- (void)dealloc
{
    NSLog(@"【dealloc】%@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBar.translucent = NO;

    self.title = @"XF Sdk Demo";
    self.view.backgroundColor = XFColor(0xf6f6f6, 1.0f);

    [self setupFuncs];
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

- (void)setupFuncs
{
    CGRect frame = CGRectMake(0, 0, 50, 30);
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:frame];
    [settingBtn setTitleColor:XFColor(0x333333, 0.8f) forState:UIControlStateNormal];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    settingBtn.titleLabel.font = XFFont(17);
    [settingBtn addTarget:self action:@selector(openApplicationSettings:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.rightBarButtonItems = @[item];

    // ------------------------------------------------------------------------------------------

    CGFloat width = kWidth/3;
    CGFloat height = 56;

    frame = CGRectMake(width/3, 15, width, height);
    UIButton *cameraDrive = [self setupButtonTitle:@"CTBleHelper"
                                            Action:@selector(showCameraDrive) Frame:frame];
    [self.view addSubview:cameraDrive];

    frame = CGRectMake([cameraDrive xf_GetRight] + width/3, [cameraDrive xf_GetTop], width, height);
    UIButton *easyLinker = [self setupButtonTitle:@"CTEasyLinker\n（推荐）"
                                             Action:@selector(showEasyLinker) Frame:frame];
    [self.view addSubview:easyLinker];

    frame = CGRectMake([cameraDrive xf_GetRight] + width/3,
                       [cameraDrive xf_GetBottom] + width/3, width, height);
    UIButton *swiftLinker = [self setupButtonTitle:@"CTSwiftLinker\n（推荐+）"
                                           Action:@selector(showSwiftLinker) Frame:frame];
    [self.view addSubview:swiftLinker];
}

- (void)openApplicationSettings:(UIButton *)sender
{
    [XFAppDelegate XF_ApplicationOpenSettingsType:0];
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

    button.userInteractionEnabled = YES;
    button.selected = YES;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    return button;
}

- (void)showCameraDrive
{
    UIViewController *ctr = [NSClassFromString(@"BleHelperViewController") new];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)showEasyLinker
{
    UIViewController *ctr = [NSClassFromString(@"EasyLinkerViewController") new];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)showSwiftLinker
{
    UIViewController *ctr = [NSClassFromString(@"SwiftLinkerViewController") new];
    [self.navigationController pushViewController:ctr animated:YES];
}

@end
