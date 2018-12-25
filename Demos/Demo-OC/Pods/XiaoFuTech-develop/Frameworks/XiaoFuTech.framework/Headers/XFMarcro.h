//
//  XFMarcro.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#ifndef XFMarcro_h
#define XFMarcro_h

#pragma mark - 正则表达式
#define XFRegEx_En @"[a-zA-Z'-]{1,100}" ///英文单词
#define XFRegEx_CN @"[\\u4e00-\\u9fa5]" //汉字
#define XFRegEx_Digit @"[0-9]" ///数字
#define XFRegEx_Char @"[\\s\\S]"  ///任意字符

#pragma mark - 尺寸
#define XF_Is_Simulator      ([UIDevice XF_DeviceType]==XFDeviceType_Simulator)
#define XF_Is_iPad           ([UIDevice XF_DeviceType]==XFDeviceType_iPad)
#define XF_Is_iPhoneX        ([UIDevice XF_DeviceType]==XFDeviceType_iPhoneX)
#define XF_SysVersion        [XFUIAdaptationHelper SysVersion]
#define XFWidth              [XFUIAdaptationHelper Width]
#define XFHeight             [XFUIAdaptationHelper Height]
#define XFScale              [XFUIAdaptationHelper Scale]
#define XFSafeTop            [XFUIAdaptationHelper SafeTop]
#define XFSafeBottom         [XFUIAdaptationHelper SafeBottom]
#define XFNaviBarHeight      (XFSafeTop+44.0f)

#pragma mark - 颜色+字体
#define XFColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define XFColor(rgbValue, alpha)    XFColorFromRGBA(rgbValue, alpha)
#define XFFont(fontSize) [UIFont systemFontOfSize:fontSize]
#define XFFont_bold(fontSize) [UIFont boldSystemFontOfSize:fontSize]

#pragma mark - 借助运行时给分类增加属性
#define Runtime_Setter(propertyName, property) objc_setAssociatedObject(self, propertyName, property, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
#define Runtime_Getter(propertyName) objc_getAssociatedObject(self, propertyName)

#pragma mark - 其它
#define XFiOSValidSys(sysVersion) @available(iOS sysVersion, *)
#define XFWeakSelf(weakSelf)  __weak __typeof(&*self) weakSelf = self;
#define XFWeakObject(obj, weakObj) __weak __typeof(&*obj) weakObj = obj;
#define XFBlockObject(obj, blockObj) __block __typeof(&*obj) blockObj = obj;

#endif /* XFMarcro_h */
