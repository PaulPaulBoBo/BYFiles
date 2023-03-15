//
//  LogMsgTool.h
//  BYFiles
//
//  Created by Liu on 2021/9/3.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/// 日志记录工具类
@interface LogMsgTool : NSObject

/// 日志记录 不会展示在界面上，但会记录到本地日志文件内
/// @param msg 日志内容
+(void)updateMsg:(NSString *)msg tag:(NSString *)tag;

/// 日志记录 会展示在界面textView上，并记录到本地日志文件内
/// @param msg 日志内容
/// @param textView 日志框
+(void)updateMsg:(NSString *)msg tag:(NSString *)tag toTextView:(NSTextView * __nullable)textView;

/// 单独记录日志到文件
/// @param msg 日志内容
+(NSString *)singleLogMsg:(NSString *)msg tag:(NSString *)tag;

/// 单独记录日志到Markdown格式文件
/// @param msg 日志内容
+(NSString *)singleMDLogMsg:(NSString *)msg tag:(NSString *)tag;

/// 单独记录日志到Markdown格式文件
/// @param msg 日志内容
/// @param tag 标签 用以区分哪个类打的日志
/// @param fileName 文件名 如果不指定会以当前日期格式化字符串作为文件名  注：不要带后缀
/// @param finish 创建完成回调
+(NSString *)singleMDLogMsg:(NSString *)msg tag:(NSString *)tag fileName:(NSString *)fileName finish:(void(^)(BOOL isSuc, NSString * _Nullable msg))finish;

/// 清除旧日志
/// @param textView 日志框
/// @param completion 完成回调
+(void)clearHistory:(NSTextView  * _Nullable)textView tag:(NSString *)tag completion:(void(^)(NSString *msg))completion;

@end

NS_ASSUME_NONNULL_END
