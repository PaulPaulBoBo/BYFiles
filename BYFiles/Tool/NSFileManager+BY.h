//
//  NSFileManager+BY.h
//  BYCategory
//
//  Created by Liu on 2021/8/26.
//

#import <Foundation/Foundation.h>
#import "BYFileTreeModel.h"

/**完成回调*/
typedef void(^BYFileOperationFinish)(BOOL isSuc, NSString * _Nullable msg);

NS_ASSUME_NONNULL_BEGIN

/// 提供常见路径访问、创建删除文件或文件目录、文件写入与读取方法
@interface NSFileManager (BY)

/// home 路径
+(NSString *)homePath;

/// document 路径
+(NSString *)documentPath;

/// library 路径
+(NSString *)libraryPath;

/// cache 路径
+(NSString *)cachePath;

/// tmp 路径
+(NSString *)tmpPath;

/// 创建路径
/// @param pathName 全路径
/// @param finish 完成回调
+(NSString *)createPath:(NSString *)pathName finish:(BYFileOperationFinish)finish;

/// 创建文件
/// @param filePath 文件路径
/// @param finish 完成回调
+(NSString *)createFile:(NSString *)filePath finish:(BYFileOperationFinish)finish;

/// 写入文件
/// @param data 写入的内容
/// @param filePath 文件全路径
/// @param finish 完成回调
+(NSString *)writeData:(NSData *)data toFile:(NSString *)filePath finish:(BYFileOperationFinish)finish;

/// 读取文件内容
/// @param filePath 文件全路径
+(NSData *)readFileDataWithFilePath:(NSString *)filePath;

/// 读取文件或文件夹属性
/// @param filePath 文件或文件夹全路径
+(BYFileAttributeModel *)readFileAttribute:(NSString *)filePath;

/// 删除文件或文件夹
/// @param filePath 文件或文件夹全路径
/// @param finish 完成回调
+(BOOL)deleteFile:(NSString *)filePath finish:(BYFileOperationFinish)finish;

/// 读取沙盒某个目录下的文件，不遍历子文件夹，以树形模型形式返回
/// @param path 某个目录
/// @param level 当前层级
/// @param isContinue 是否遍历下一级目录
+ (BYFileTreeModel *)loadFilesInPath:(NSString *)path level:(NSNumber *)level isContinue:(BOOL)isContinue;

@end

NS_ASSUME_NONNULL_END
