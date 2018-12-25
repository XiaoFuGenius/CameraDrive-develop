//
//  XFCarouselControls.h
//  XiaoFuTech
//
//  Created by xiaofutech on 2017/11/5.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XFCarouselControls : UIView

+ (XFCarouselControls *)SetupCarouselControlsAutoCarouse:(BOOL)autoCarouse
                                            TimeInterval:(CGFloat)timeInterval
                                                Vertical:(BOOL)vertical
                                             ContentMode:(UIViewContentMode)contentMode
                                                  Images:(NSArray *)images
                                                   Frame:(CGRect)frame
                                                 Carouse:(void (^)(NSInteger currentIndex))carouse
                                                  Tapped:(void (^)(NSInteger currentIndex))tapped;

+ (XFCarouselControls *)SetupCarouselControlsImages:(NSArray *)images
                                              Frame:(CGRect)frame
                                            Carouse:(void (^)(NSInteger currentIndex))carouse
                                             Tapped:(void (^)(NSInteger currentIndex))tapped;

- (void)stop;

@end
