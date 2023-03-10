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

static NSString *MSGLOG = @"";

@implementation LogMsgTool

#pragma mark - public

+(void)updateMsg:(NSString *)msg {
    [LogMsgTool updateMsg:msg toTextView:nil];
}
+(void)updateMsg:(NSString *)msg toTextView:(NSTextView  * _Nullable)textView {
    if(msg == nil || msg.length == 0) {
        return;
    }
    NSLog(@"%@", msg);
    NSString *dateStr = [NSDate stringWithDate:[NSDate date] type:(BY_DateFormatterType_ymdhms)];
    NSString *logFilePath = [self checkLogFile];
    if(MSGLOG.length == 0) {
        MSGLOG = [NSString stringWithFormat:@"%@:%@", dateStr, msg];
    } else {
        MSGLOG = [NSString stringWithFormat:@"%@:%@\n%@", dateStr, msg, MSGLOG];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(textView != nil) {
            textView.string = MSGLOG;
        }
        [NSFileManager writeData:[NSData dataWithString:MSGLOG] toFile:logFilePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            
        }];
    });
}

#pragma mark - private

+ (NSString *)checkLogFile {
    NSString *logPath = [NSString stringWithFormat:@"%@/log", [NSFileManager cachePath]];
    NSString *logFileName = @"log.txt";
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
