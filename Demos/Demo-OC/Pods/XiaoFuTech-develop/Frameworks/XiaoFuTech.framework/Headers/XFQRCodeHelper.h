//
//  XFQRCodeHelper.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/26.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XFQRCodeImageType) {
    XFQRCodeImageTypeQRCode = 0,    //type for QRCode
    XFQRCodeImageTypeBarCode,       //type for BarCode
};

typedef NS_ENUM(NSInteger, XFQRCodeScannerType) {
    XFQRCodeScannerTypeAll = 0,     //default, scan QRCode and barcode
    XFQRCodeScannerTypeQRCode,      //scan QRCode only
    XFQRCodeScannerTypeBarCode,     //scan barcode only
};

typedef void(^ScannerScanRect)(CGRect rect);
typedef void(^ScannerStartScan)(void);
typedef void(^ScannerScale)(CGFloat scale);
typedef void(^ScannerStopScan)(void);
typedef void(^ScannerReset)(void);
typedef void(^ScannerManuel)(CALayer *layer, ScannerScanRect scanRect, ScannerStartScan startScan,
                             ScannerScale scale, ScannerStopScan stopScan, ScannerReset reset);
typedef void(^ScannerResult)(BOOL granted, NSString *value);

@interface XFQRCodeHelper : NSObject

/**
 二维码 & 条形码 扫描器
 */
+ (void)ScannerWithType:(XFQRCodeScannerType)type
                 Manuel:(ScannerManuel)manuel
                 Result:(ScannerResult)result;

/**
 生成 二维码 & 条形码
 @param type 将要生成的码类型
 @param content 需要二维码携带的信息（二维码，一般是url；条形码，一般是一个有规则的字母数字混合字符串）
 @param size 二维码 & 条形码 大小
 @param onColor 前景色（必须是暗色）
 @param offColor 背景色（必须是亮色）
 @return 二维码 & 条形码 图片数据
 */
+ (UIImage *)CodeImageWithType:(XFQRCodeImageType)type
                       Content:(NSString *)content Size:(CGSize)size
                       OnColor:(UIColor *)onColor OffColor:(UIColor *)offColor;

@end
