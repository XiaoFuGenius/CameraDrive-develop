//
//  XFPickerViewHelper.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/27.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XFPickerViewHelper;
@protocol XFPickerViewHelperDelegate <NSObject>
- (void)XFPickerViewHelper:(XFPickerViewHelper *)pickerHelper Done:(NSArray *)doneArray;
@end

typedef void(^XFPickerFinished)(void);
@interface XFPickerViewHelper : UIView
@property (nonatomic, readonly) CGFloat headerViewHeight;

+ (XFPickerViewHelper *)PickerView:(id <XFPickerViewHelperDelegate>)delegate
                       PickerArray:(NSArray *)pickerArray;

- (void)updateHeaderViewTitle:(NSString *)title Done:(NSString *)done;
- (XFPickerFinished)updateHeaderView:(UIView *)view;

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component;

@end
