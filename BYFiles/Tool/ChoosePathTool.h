//
//  ChoosePathTool.h
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChoosePathTool : NSObject

/// 打开选择目录或文件面板
/// @param canChooseFiles 能否选择文件
/// @param finish 完成回调
+(void)openPanelCanChooseFiles:(BOOL)canChooseFiles finish:(void(^)(NSString *path))finish;

/// 在Finder中打开指定路径
/// @param path 路径
+(void)openFinderPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
