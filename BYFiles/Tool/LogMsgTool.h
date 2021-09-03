//
//  LogMsgTool.h
//  BYFiles
//
//  Created by Liu on 2021/9/3.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogMsgTool : NSObject

/// 日志记录 不会展示在界面上，但会记录到本地日志文件内
/// @param msg 日志内容
+(void)updateMsg:(NSString *)msg;

/// 日志记录 会展示在界面textView上，并记录到本地日志文件内
/// @param msg 日志内容
/// @param textView 日志框
+(void)updateMsg:(NSString *)msg toTextView:(NSTextView * __nullable)textView;

@end

NS_ASSUME_NONNULL_END
