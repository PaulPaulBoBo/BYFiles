//
//  GBTask+Finder.h
//  BYFiles
//
//  Created by Liu on 2022/12/20.
//

#import "GBTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBTask (Finder)

/// 新建文件目录
/// - Parameters:
///   - path: 文件目录
///   - completion: 完成回调 如文件夹已存在，该回调将不会执行
+(void)mkdir:(NSString *)path completion:(void(^)(void))completion;

/// 删除文件目录
/// - Parameters:
///   - path: 文件目录
///   - completion: 完成回调 如文件夹已存在，该回调将不会执行
+(void)rmdir:(NSString *)path completion:(void(^)(void))completion;

/// 删除文件 如果传入的是文件目录 将递归删除目录下的所有文件
/// - Parameters:
///   - path: 文件目录
///   - completion: 完成回调 如文件夹已存在，该回调将不会执行
+(void)rmfile:(NSString *)path completion:(void(^)(void))completion;

/// 拷贝文件
/// - Parameters:
///   - sourceFilePath: 源文件路径
///   - orderFilePath: 目标路径
///   - completion: 完成回调
+(void)copy:(NSString *)sourceFilePath orderFilePath:(NSString *)orderFilePath completion:(void(^)(void))completion;

/// 移动文件
/// - Parameters:
///   - sourceFilePath: 源文件路径
///   - orderFilePath: 目标路径
///   - completion: 完成回调
+(void)move:(NSString *)sourceFilePath orderFilePath:(NSString *)orderFilePath completion:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
