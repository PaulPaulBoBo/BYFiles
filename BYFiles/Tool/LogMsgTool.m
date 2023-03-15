//
//  LogMsgTool.m
//  BYFiles
//
//  Created by Liu on 2021/9/3.
//

#import "LogMsgTool.h"
#import "NSDate+BY.h"
#import "NSFileManager+BY.h"
#import "NSData+BY.h"

@implementation LogMsgTool

#pragma mark - public

+(void)updateMsg:(NSString *)msg tag:(NSString *)tag {
    [LogMsgTool updateMsg:msg tag:tag toTextView:nil];
}
+(void)updateMsg:(NSString *)msg tag:(NSString *)tag toTextView:(NSTextView  * _Nullable)textView {
    if(msg == nil || msg.length == 0) {
        return;
    }
    NSString *dateStr = [NSDate stringWithDate:[NSDate date] type:(BY_DateFormatterType_ymdhms)];
    NSString *logFilePath = [self checkLogFileTag:tag];
    if(textView != nil && msg.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            textView.string = [NSString stringWithFormat:@"%@:%@\n%@", dateStr, msg, textView.string];
            [NSFileManager writeData:[NSData dataWithString:textView.string] toFile:logFilePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
                
            }];
        });
    }
}

+(NSString *)singleLogMsg:(NSString *)msg tag:(NSString *)tag {
    if(msg == nil || msg.length == 0) {
        return @"";
    }
    NSString *logPath = [LogMsgTool checkLogFile:[NSString stringWithFormat:@"%@",[NSDate date]] tag:tag];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSFileManager writeData:[NSData dataWithString:msg] toFile:logPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            
        }];
    });
    return logPath;
}
+(NSString *)singleMDLogMsg:(NSString *)msg tag:(NSString *)tag {
    return [self singleMDLogMsg:msg tag:tag fileName:@"" finish:^(BOOL isSuc, NSString * _Nullable msg) {
        
    }];
}

+(NSString *)singleMDLogMsg:(NSString *)msg tag:(NSString *)tag fileName:(NSString *)fileName finish:(void(^)(BOOL isSuc, NSString * _Nullable msg))finish {
    if(msg == nil || msg.length == 0) {
        return @"";
    }
    NSString *name = fileName;
    if(name == nil || ![name isKindOfClass:[NSString class]] || name.length == 0) {
        name = [NSString stringWithFormat:@"%@", [NSDate date]];
    }
    NSString *logPath = [LogMsgTool checkLogFile:[NSString stringWithFormat:@"%@.md", name] tag:tag];
    NSLog(@"logPath:%@", logPath);
    [NSFileManager writeData:[NSData dataWithString:msg] toFile:logPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
        if(finish) {
            finish(isSuc, msg);
        }
    }];
    return logPath;
}

+(void)clearHistory:(NSTextView  * _Nullable)textView tag:(NSString *)tag completion:(void(^)(NSString *msg))completion {
    textView.string = @"";
    textView.backgroundColor = [NSColor labelColor];
    textView.textColor = [NSColor systemGreenColor];
    textView.insertionPointColor = [NSColor systemGreenColor];
    NSString *logPath = [NSString stringWithFormat:@"%@/log", [NSFileManager cachePath]];
    NSString *logFileName = [NSString stringWithFormat:@"log_%@.txt", tag];
    NSString *logFilePath = [NSString stringWithFormat:@"%@/%@", logPath, logFileName];
    [NSFileManager deleteFile:logFilePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
        if(completion) {
            completion([NSString stringWithFormat:@"%@删除完成！", logFilePath]);
        }
    }];
}

#pragma mark - private

+ (NSString *)checkLogFileTag:(NSString *)tag {
    NSString *logPath = [NSString stringWithFormat:@"%@/log", [NSFileManager cachePath]];
    NSString *logFileName = [NSString stringWithFormat:@"log_%@.txt", tag];
    NSString *logFilePath = [NSString stringWithFormat:@"%@/%@", logPath, logFileName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
        [NSFileManager createPath:logPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            
        }];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        [NSFileManager createFile:logFilePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            
        }];
    }
    return [LogMsgTool checkLogFile:@"log" tag:tag];
}

+ (NSString *)checkLogFile:(NSString *)fileName tag:(NSString *)tag {
    NSString *logPath = [NSString stringWithFormat:@"%@/log", [NSFileManager cachePath]];
    NSString *logFileName = @"";
    if([fileName rangeOfString:@"."].length > 0) {
        logFileName = fileName;
    } else {
        logFileName = [NSString stringWithFormat:@"%@_%@.txt", fileName, tag];
    }
    NSString *logFilePath = [NSString stringWithFormat:@"%@/%@", logPath, logFileName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
        [NSFileManager createPath:logPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            
        }];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        [NSFileManager createFile:logFilePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            
        }];
    }
    return logFilePath;
}

@end
