//
//  ChoosePathTool.h
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/// pannel选择工具类
@interface ChoosePathTool : NSObject

/// 打开选择目录或文件面板
/// @param canChooseFiles 能否选择文件 NO-只能选一个文件目录，YES-只能选一个文件
/// @param finish 完成回调
+(void)openPanelCanChooseFiles:(BOOL)canChooseFiles finish:(void(^)(NSArray *paths))finish;

/// 打开选择目录或文件面板
/// @param canChooseFiles 能否选择文件 NO-只能选文件目录，YES-只能选文件
/// @param canMultipleSelection 能否选择多个文件或目录
/// @param finish 完成回调
+(void)openPanelCanChooseFiles:(BOOL)canChooseFiles canMultipleSelection:(BOOL)canMultipleSelection finish:(void(^)(NSArray *paths))finish;

/// 在Finder中打开指定路径
/// @param path 路径
+(void)openFinderPath:(NSString *)path;

+(BOOL)accessFileURL:(NSURL *)fileURL withBlock:(void(^)(void))block;

+(void)persistPermissionURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
