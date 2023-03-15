//
//  BaseComment.h
//  BYFiles
//
//  Created by Liu on 2021/11/29.
//

#import <Foundation/Foundation.h>
#import "LogMsgTool.h"
#import "TemplateCode.h"
#import "ChoosePathTool.h"
#import "BYFileTreeModel.h"
#import "NSFileManager+BY.h"
#import "LoadFileTools.h"
#import "GeneralConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// @"//\/"
#define SpecialCode_3 [NSString stringWithFormat:@"%@%@", @"//", @"/"]
/// @"//\/** "
#define SpecialCode_3_Star [NSString stringWithFormat:@"%@%@", @"//", @"/**"]
/// @"//\/\/"
#define SpecialCode_4 [NSString stringWithFormat:@"%@%@", @"//", @"//"]
/// 文件处理速度 n秒一个文件
static CGFloat Speed = 0.0001;

@interface BaseComment : NSObject

/// 代码处理方法工具类
@property (nonatomic, strong) LoadFileTools *loadFileTools;
/// 用于读取文件目录结构
@property (nonatomic, strong) BYFileTreeModel *fileModel;
/// 存储文件路径
@property (nonatomic, strong) NSMutableArray *files;
/// 文件总数记录
@property (nonatomic, assign) NSInteger fileCount;
/// 当前选择的文件路径
@property (nonatomic, copy) NSString *path;
/// 提示信息框
@property (nonatomic, strong) NSTextView *msgTextView;
/// 当前进度状态标签
@property (nonatomic, strong) NSTextField *stateLabel;
/// 进度条
@property (nonatomic, strong) NSProgressIndicator *progressView;

/// 启动转换入口
-(void)start;

/// 读取给定目录下的文件和文件夹，将文件存储到全局属性files中，递归遍历子文件夹
/// @param path 给定目录
-(void)findFileInPath:(NSString *)path;

/// 将给定文件路径存储在全局属性 files 中
/// .DS_Store不存储，仅存储.h和.m
/// @param filePath 给定文件路径
-(void)findFile:(NSString *)filePath;

/// 排除Pods目录下的文件
-(void)expectPodsFiles;

@end

NS_ASSUME_NONNULL_END
