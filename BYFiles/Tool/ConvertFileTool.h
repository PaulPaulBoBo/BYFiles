//
//  ConvertFileTool.h
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import <Foundation/Foundation.h>

typedef void(^ConvertFinish)(NSString * _Nullable filePaths);

NS_ASSUME_NONNULL_BEGIN

@interface ConvertFileTool : NSObject

/// 转换文件链接
/// @param filePath 文件地址
/// @param orderPath 输出路径
/// @param baseURLStr 基础url
/// @param log 需要记录日志回调
/// @param completion 完成回调
+(void)convertFilePath:(NSString *)filePath toPath:(NSString *)orderPath baseURLStr:(NSString *)baseURLStr log:(void (^)(NSString *msg))log completion:(void (^)(NSString *filePath))completion;

@end

NS_ASSUME_NONNULL_END
