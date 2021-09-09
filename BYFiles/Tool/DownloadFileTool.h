//
//  DownloadFileTool.h
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadFileTool : NSObject

/// 下载多个ts文件
/// @param listArr ts文件的url数组
/// @param index 当前下标
/// @param cacheFilePath 缓存路径
/// @param log 需要记录日志的block
/// @param progress 当前下载进度block downloadProgress是当前下载进度，downloadingUrl是当前下载的url
/// @param completion 所有ts文件都下载完的block filePath是ts文件的缓存地址
+ (void)downloadVideoWithArr:(NSArray *)listArr
                    andIndex:(NSInteger)index
               cacheFilePath:(NSString *)cacheFilePath
                         log:(void (^)(NSString *msg))log
                    progress:(void (^)(NSProgress *downloadProgress, NSString *downloadingUrl))progress
                  completion:(void (^)(NSString *filePath))completion;

/// 下载单个文件
/// @param downloadURL 下载地址
/// @param destinationPath 缓存地址 
/// @param progress 进度
/// @param completion 完成回调
+ (void)downloadURL:(NSString *)downloadURL destinationPath:(NSString *)destinationPath progress:(void (^)(NSProgress *downloadProgress))progress completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
