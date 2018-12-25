//
//  XFAppIconHelper.h
//  XiaoFuTech
//
//  Created by xiaofutech on 2018/5/31.
//  Copyright © 2018年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFAppIconHelper : NSObject

/**
 image标准大小，建议 1024*1024
 */
+ (void)XF_GeneratorAppIconViaImage:(UIImage *)image;

@end
