//
//  CombineFileTool.m
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import "CombineFileTool.h"
#import "AFNetworking.h"
#import "LogMsgTool.h"
#import "NSFileManager+BY.h"
#import "BYFileTreeModel.h"
#import "NSDate+BY.h"

@implementation CombineFileTool

// 合成为一个ts文件
+ (void)combVideosInPath:(NSString *)videosPath log:(void (^)(NSString *msg))log completion:(void (^)(NSString *filePath))completion {
    if(log) {
        log(@"开始合并数据");
    }
    NSArray *contentArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videosPath error:nil];
    NSMutableData *dataArr = [NSMutableData alloc];
    int videoCount = 0;
    for (NSString *str in contentArr) {
        // 按顺序拼接 TS 文件
        if ([str containsString:@"video_"]) {
            NSString *videoName = [NSString stringWithFormat:@"video_%d.%@", videoCount, str.pathExtension];
            NSString *videoPath = [videosPath stringByAppendingPathComponent:videoName];
            // 读出数据
            NSData *data = [[NSData alloc] initWithContentsOfFile:videoPath];
            // 合并数据
            [dataArr appendData:data];
            videoCount++;
            [NSFileManager deleteFile:videoPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
                
            }];
        }
    }
    NSString *dateStr = [NSDate stringWithDate:[NSDate date] type:(BY_DateFormatterType_ymdhms)];
    NSString *filePath = [NSString stringWithFormat:@"%@/video_%@", videosPath, dateStr];
    [NSFileManager writeData:dataArr toFile:filePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
        if(log) {
            log([NSString stringWithFormat:@"%@  %@", msg, filePath]);
        }
    }];
    if(log) {
        log(@"2秒后开始下一个文件下载");
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(completion) {
            completion(filePath);
        }
    });
}

@end
