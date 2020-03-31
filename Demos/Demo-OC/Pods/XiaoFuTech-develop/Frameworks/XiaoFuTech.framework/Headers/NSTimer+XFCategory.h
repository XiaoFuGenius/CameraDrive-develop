//
//  NSTimer+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by 胡钧昱 on 2017/9/25.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (XFCategory)

///暂停
- (void)xf_Pause;
///恢复
- (void)xf_Resume;
///指定时间恢复
- (void)xf_ResumeAfterTimeInterval:(NSTimeInterval)interval;
///停止，会调用 invalidate 方法
- (void)xf_Stop;

@end
