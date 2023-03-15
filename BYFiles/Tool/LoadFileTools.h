//
//  LoadFileTools.h
//  BYFiles
//
//  Created by Liu on 2021/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 当前是否在转换中
static BOOL IsRunning = NO;

@interface LoadFileTools : NSObject

/// 移除string中首尾空格，如果首尾有多个空格也会全部移除
/// @param string 原字符串
-(NSString *)removeWhiteSpacePreSufInString:(NSString *)string;

/// 移除string中所有的str
/// @param str 查询子串
/// @param string 原字符串
-(NSString *)removeSpecStr:(NSString *)str inString:(NSString *)string;

/// 把string中所有的str替换为newStr
/// @param str 查询子串
/// @param newStr 替换子串
/// @param string 原字符串
-(NSString *)replaceSpecStr:(NSString *)str withString:(NSString *)newStr inString:(NSString *)string;

/// 获取字符串中首个连续的空格字符串的range
/// @param str 原字符串
-(NSRange)loadWhiteSpaceRangeInString:(NSString *)str;

/// 判断字符串里是否有连续空格
/// @param str 要判断的字符串
-(BOOL)hasMuchWhiteSpace:(NSString *)str;

/// 获取方法的参数
/// @param code 方法代码行
/// @param arr 代码行数组 多行方法时使用
/// @param line 当前方法行 多行方法时使用
-(NSArray *)loadMethodParam:(NSString *)code arr:(NSArray *)arr line:(NSInteger)line;

/// 获取单行方法代码的参数
/// @param code 单行代码字符串 必须是以分号结尾的单行字符串方法
-(NSArray *)loadMethodParams:(NSString *)code;

/// 获取string中str的个数
/// @param str 指定子串
/// @param string 源字符串
-(NSInteger)findSpecStrCount:(NSString *)str inString:(NSString *)string;

/// 获取方法中"()"及"()"内的代码range
/// @param code 方法代码字符串
-(NSRange)findParamTypeRange:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
