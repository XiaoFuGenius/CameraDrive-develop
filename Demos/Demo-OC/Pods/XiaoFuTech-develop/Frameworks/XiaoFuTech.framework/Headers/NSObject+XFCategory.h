//
//  NSObject+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XFCategory)

#define XF_CodingImplementation \
- (instancetype)initWithCoder:(NSCoder *)aDecoder {\
if (self = [super init]) {\
[self xf_decode:aDecoder];\
}\
return self;\
}\
\
- (void)encodeWithCoder:(NSCoder *)aCoder {\
[self xf_encode:aCoder];\
}

#define XF_CopyingImplementation \
- (id)copyWithZone:(NSZone *)zone {\
return [self xf_copyWithZone:zone];\
}

#pragma mark >> 对象的 复制拷贝 <<
/**
 返回不需要coder的属性数组 - 重写
 @return 不需要coder的属性数组
 */
- (NSArray *)xf_ignoredNames;

/**
 属性列表编码
 @param aCoder NSCoder实例
 */
- (void)xf_encode:(NSCoder *)aCoder;

/**
 属性列表解码
 @param aDecoder NSCoder实例
 */
- (void)xf_decode:(NSCoder *)aDecoder;

/**
 属性列表复制
 @param zone NSZone实例
 @return 复制完成的对象
 */
- (id)xf_copyWithZone:(NSZone *)zone;

#pragma mark >> 带参，键盘监听 <<
@property (nonatomic, strong) id xf_object;
@property (nonatomic, copy) void (^xf_keyboardWillShow)(NSTimeInterval duration, CGFloat height);
@property (nonatomic, copy) void (^xf_keyboardWillHide)(NSTimeInterval duration, CGFloat height);

#pragma mark >> 安全性检查 <<
/**
 获取对象的引用计数值
 @return 引用计数
 */
- (long)xf_GetRetainCount;

/**
 判断对象是否为空
 @return 判断结果
 */
- (BOOL)xf_NotNull;

/**
 检查 字典、数组 中是否存在NSNull类型，并且自动将NSNull类型转成空串
 @return 处理完成的新的对象
 */
- (id)xf_checkNull;

#pragma mark >> json解析、转换 <<
/**
 将对象转成二进制数据
 @return 二进制数据
 */
- (NSData *)xf_convertToJsonData;

/**
 将对象转成json字符串
 @return json字符串
 */
- (NSString *)xf_convertToJsonString;

/**
 将json字符串转成对象
 @param jsonString json字符串
 @return 对象实例
 */
+ (id)XF_ConvertToObject:(NSString *)jsonString;

#pragma mark >> 字典对象互转 <<
/**
 将对象转成字典
 @return 字典
 */
- (NSDictionary *)xf_ObjectToDictionary;

/**
 将字典转成对象
 @param dict 字典
 @param className 对象类名
 @return 对象实例
 */
+ (id)XF_DictionaryToObject:(NSDictionary*)dict ClassName:(id)className;

#pragma mark >> 其它 <<
/**
 将字典的键名全部转成小写形式
 @param dictionary 待转换字典实例
 @return 转换完成字典实例
 */
+ (NSDictionary *)XF_GetLowcaseKeyDictionary:(NSDictionary *)dictionary;

@end
