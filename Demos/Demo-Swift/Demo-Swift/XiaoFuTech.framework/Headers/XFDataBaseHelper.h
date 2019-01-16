//
//  XFDataBaseHelper.h
//  XiaoFuTechHelper
//
//  Created by xiaofutech on 2017/9/28.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface XFDataBaseHelper : NSObject

/**
 初始化数据库

 @param fileName 当前用户的文件夹名
 @param dbName 数据库名称, 格式：anyName.database
 @param tStrings 需要创建的表
 @param atColumns 需要声明修改的列
 注意用户切换的时候需要调用该方法重新初始化数据库！
 */
+ (void)InitDataBaseHelperFileName:(NSString *)fileName
                            DBName:(NSString *)dbName
                      TableStrings:(NSArray <NSString *>*)tStrings
                 AlterTableColumns:(NSArray <NSString *>*)atColumns;

//开始事务
+ (void)BeginTransaction;

//提交事务
+ (void)CommitTransaction;

//执行SQL
+ (NSArray*)QueryWithSQL:(NSString*)sql;

//执行SQL
+ (NSArray*)QueryWithSQL:(NSString*)sql Parameters:(id) parameters,... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.");

//执行SQL
+ (int)ExecuteWithSQL:(NSString*)sql;

//执行SQL
+ (int)ExecuteWithSQL:(NSString*)sql Parameters:(id) parameters,... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.");

//获取DataBase实例
+ (sqlite3 *)GetDB;

//获取锁实例
+ (id)GetLock;

@end
