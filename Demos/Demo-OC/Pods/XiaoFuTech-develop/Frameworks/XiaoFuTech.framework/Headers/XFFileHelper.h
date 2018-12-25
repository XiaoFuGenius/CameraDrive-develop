//
//  XFFileHelper.h
//  XiaoFuTech
//
//  Created by xiaofutech on 2017/10/16.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFFileHelper : NSObject

/**
 获取文件地址
 @param directory 沙盒路径
 @param fileName 文件名
 @return 完整的文件地址
 */
+ (NSString *)GetFilePath:(NSSearchPathDirectory)directory FileName:(NSString *)fileName;

/**
 检查文件(夹)是否存在
 @param path 文件(夹)地址
 @return 检查结果
 */
+ (BOOL)FileExistsAtPath:(NSString *)path;

/**
 将数据写到一个文件
 @param path 文件地址
 @param createIntermediates 若文件不存在，是否自动创建
 @param fileData 需要写入的数据
 @return 写入结果
 */
+ (BOOL)WriteFileAtPath:(NSString *)path WithIntermediateDirectories:(BOOL)createIntermediates
               FileData:(NSData *)fileData;

/**
 读取文件数据
 @param path 文件地址
 @return 该文件的二进制数据
 */
+ (NSData *)ReadFileAtPath:(NSString *)path;

/**
 删除文件(夹)
 @param path 文件(夹)地址
 @return 操作成功状态
 */
+ (BOOL)DeleteFileAtPath:(NSString *)path;

/**
 获取文件夹中的所有文件，自动遍历所有子文件(夹)
 @param path 文件夹地址
 @return 该文件夹下的所有子文件(文件夹)地址
 */
+ (NSArray *)GetAllSubFilesAtPath:(NSString *)path;

/**
 获取文件(夹)大小，自动遍历所有子文件(夹)
 @param path 文件(夹)地址
 @return 文件(夹)大小
 */
+ (long long)GetFileSizeAtPath:(NSString *)path;

@end
