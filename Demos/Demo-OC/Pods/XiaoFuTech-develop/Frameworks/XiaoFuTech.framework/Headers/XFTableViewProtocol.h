//
//  XFTableViewProtocol.h
//  XiaoFuTechHelper
//
//  Created by 胡钧昱 on 2017/9/27.
//  Copyright © 2017年 EternalTech. All rights reserved.
//

#import <Foundation/Foundation.h>

///dataSource
typedef NSInteger (^NumberOfRowsInSection)(NSInteger section);
typedef id (^CellForRowAtIndexPath)(UITableView *tableView, NSIndexPath *indexPath);
///delegate
typedef NSInteger (^NumberOfSectionsInTableView)(void);
typedef CGFloat (^HeightForRowAtIndexPath)(NSIndexPath *indexPath);
typedef void (^DidSelectRowAtIndexPath)(UITableView *tableView, id cell, NSIndexPath *indexPath);

@interface XFTableViewProtocol : NSObject <UITableViewDataSource, UITableViewDelegate>

///dataSource
//@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, copy) NumberOfRowsInSection numberOfRowsBlock;
@property (nonatomic, copy) CellForRowAtIndexPath cellBlock;

///delegete
@property (nonatomic, copy) NumberOfSectionsInTableView numberOfSectionsBlock;
@property (nonatomic, copy) HeightForRowAtIndexPath  heightForRowBlock;
@property (nonatomic, copy) DidSelectRowAtIndexPath didSelectCellBlock;

@end
