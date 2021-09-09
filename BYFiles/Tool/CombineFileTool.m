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
+ (void)combVideosInPath:(NSString *)videosPath outputPath:(NSString *)outputPath log:(void (^)(NSString *msg))log completion:(void (^)(NSString *filePath))completion {
    if(log) {
        log(@"开始合并数据");
    }
    NSArray *contentArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videosPath error:nil];
    NSMutableData *dataArr = [NSMutableData alloc];
    __block int videoCount = 0;
    NSString *pathExtension = @"";
    NSMutableArray *tmpPaths = [NSMutableArray new];
    for (NSString *str in contentArr) {
        pathExtension = str.pathExtension;
        if([pathExtension isEqual:@"ts"]) {
            // 按顺序拼接 TS 文件
            if ([str containsString:@"file_"]) {
                NSString *videoName = [NSString stringWithFormat:@"file_%d.%@", videoCount, str.pathExtension];
                NSString *videoPath = [videosPath stringByAppendingPathComponent:videoName];
                // 读出数据
                NSData *data = [[NSData alloc] initWithContentsOfFile:videoPath];
                // 合并数据
                [dataArr appendData:data];
                videoCount++;
                [NSFileManager deleteFile:videoPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
                    
                }];
            }
        } else {
            NSString *videoName = [NSString stringWithFormat:@"file_%d.%@", videoCount, str.pathExtension];
            NSString *videoPath = [videosPath stringByAppendingPathComponent:videoName];
            [tmpPaths addObject:videoPath];
            videoCount++;
        }
    }
    NSString *dateStr = [NSDate stringWithDate:[NSDate date] formatStr:@"yyyyMMddHHmmss"];
    NSString *filePath = [NSString stringWithFormat:@"%@/file_%@.%@", outputPath, dateStr, pathExtension];
    if([pathExtension isEqual:@"ts"]) {
        [NSFileManager writeData:dataArr toFile:filePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            if(log) {
                log([NSString stringWithFormat:@"%@  %@", msg, filePath]);
            }
        }];
    } else {
        [CombineFileTool moveFile:tmpPaths index:0 toPath:outputPath];
    }
    if(log) {
        log(@"2秒后开始下一个文件下载");
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(completion) {
            completion(filePath);
        }
    });
}

+(void)moveFile:(NSArray *)filePaths index:(NSInteger)index toPath:(NSString *)toPath {
    if(index < filePaths.count) {
        NSString *filePath = filePaths[index];
        if ([filePath containsString:@"file_"]) {
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            NSString *dateStr = [NSDate stringWithDate:[NSDate date] formatStr:@"yyyyMMddHHmmss"];
            [NSFileManager writeData:data toFile:[NSString stringWithFormat:@"%@/file_%@.%@", toPath, dateStr, filePath.pathExtension] finish:^(BOOL isSuc, NSString * _Nullable msg) {
                [NSFileManager deleteFile:filePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [CombineFileTool moveFile:filePaths index:index+1 toPath:toPath];
                    });
                }];
            }];
        }
    }
}

@end
