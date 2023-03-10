//
//  DownloadFileTool.m
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import "DownloadFileTool.h"
#import "AFNetworking.h"
#import "LogMsgTool.h"
#import "NSFileManager+BY.h"
#import "BYFileTreeModel.h"
#import "NSDate+BY.h"

@interface DownloadFileTool()

@end

@implementation DownloadFileTool

// 循环下载 ts 文件
+ (void)downloadVideoWithArr:(NSArray *)listArr
                    andIndex:(NSInteger)index
               cacheFilePath:(NSString *)cacheFilePath
                         log:(void (^)(NSString *msg))log
                    progress:(void (^)(NSProgress *downloadProgress, NSString *downloadingUrl))progress
                  completion:(void (^)(NSString *filePath))completion {
    NSString *fileUrl = listArr[index];
    NSString *fileType = [[fileUrl componentsSeparatedByString:@"?"].firstObject componentsSeparatedByString:@"."].lastObject;
    if(fileType == nil || fileType.length == 0) {
        fileType = @"ts";
    }
    NSString *fileName = [NSString stringWithFormat:@"file_%ld.%@", (long)index, fileType];
    if (index >= listArr.count) {
        if(completion) {
            completion(cacheFilePath);
        }
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", cacheFilePath, fileName]]) {
        if(index+1 < listArr.count) {
            [DownloadFileTool downloadVideoWithArr:listArr andIndex:index+1 cacheFilePath:cacheFilePath log:log progress:progress completion:completion];
        } else {
            if(completion) {
                completion(cacheFilePath);
            }
        }
    } else {
        [DownloadFileTool downloadURL:fileUrl destinationPath:[NSString stringWithFormat:@"%@/%@", cacheFilePath, fileName] progress:^(NSProgress * _Nonnull downloadProgress) {
            if(progress) {
                progress(downloadProgress, fileUrl);
            }
        } completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (!error) {
                if(log) {
                    log([NSString stringWithFormat:@"文件\"%@\"下载成功!", fileUrl]);
                }
                if(index+1 < listArr.count) {
                    [DownloadFileTool downloadVideoWithArr:listArr andIndex:index+1 cacheFilePath:cacheFilePath log:log progress:progress completion:completion];
                } else {
                    if(completion) {
                        completion(cacheFilePath);
                    }
                }
            } else {
                if(log) {
                    log([NSString stringWithFormat:@"下载失败:%@", error.localizedDescription]);
                }
            }
        }];
    }
}

+ (void)downloadURL:(NSString *)downloadURL destinationPath:(NSString *)destinationPath progress:(void (^)(NSProgress *downloadProgress))progress completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion {
    AFHTTPSessionManager *manage  = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: downloadURL]];
    NSURLSessionDownloadTask *downloadTask =
    [manage downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *filePathUrl = nil;
        if (destinationPath) {
            filePathUrl = [NSURL fileURLWithPath:destinationPath];
        }
        if (filePathUrl) {
            return filePathUrl;
        }
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fullpath = [caches stringByAppendingPathComponent:response.suggestedFilename];
        filePathUrl = [NSURL fileURLWithPath:fullpath];
        return filePathUrl;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        if (completion) {
            completion(response, filePath, error);
        }
    }];
    
    [downloadTask resume];
}

@end
