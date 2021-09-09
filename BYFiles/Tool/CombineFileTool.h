//
//  CombineFileTool.h
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CombineFileTool : NSObject

/// 合并ts文件
/// @param videosPath ts文件缓存路径
/// @param outputPath 输出文件路径
/// @param log 需要记录日志的回调
/// @param completion 合并完成回调
+ (void)combVideosInPath:(NSString *)videosPath outputPath:(NSString *)outputPath log:(void (^)(NSString *msg))log completion:(void (^)(NSString *filePath))completion;

@end

NS_ASSUME_NONNULL_END
