//
//  BYBaseWindowController.h
//  BYFiles
//
//  Created by Liu on 2022/11/11.
//

#import <Cocoa/Cocoa.h>
#import "ChoosePathTool.h"
#import "BYFileTreeModel.h"
#import "NSFileManager+BY.h"
#import "BaseComment.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BYBaseWindowControllerProtocol;

@interface BYBaseWindowController : NSWindowController

/// windows代理
@property (nonatomic, weak) id<BYBaseWindowControllerProtocol> windowsDelegate;

/// 配置字典
@property (nonatomic, strong) NSMutableDictionary *config;
/// 单独文件处理数组
@property (nonatomic, strong) NSMutableArray *filePaths;

/// 整个页面的容器视图
@property (nonatomic, strong) NSBox *boxView;
/// 复选按钮背景视图
@property (nonatomic, strong) NSStackView *btnBgView;
/// 日志文本框滚动容器视图
@property (nonatomic, strong) NSScrollView *msgTextScrollView;
/// 日志文本框
@property (nonatomic, strong) NSTextView *msgTextView;
/// 状态标签
@property (nonatomic, strong) NSTextField *stateLabel;
/// 进度条
@property (nonatomic, strong) NSProgressIndicator *progressView;
/// 选择路径文本框
@property (nonatomic, strong) NSTextView *pathTextView;
/// 代码注释转换类
@property (nonatomic, strong) BaseComment *tool;

/// 设置各个页面共用的控件
-(void)setupViews;

/// 选择路径并开始处理，具体实现类需要在子类控制器中创建子类工具
-(void)choosePath;

/// 选择路径完成 选择的路径存储在tool属性中 通过self.tool.path获取 由子类按需重写
-(void)choosePathFinish;

/// 选择多个文件
-(void)chooseFilss;

/// 清除多个文件
-(void)clearPaths;

/// 开始处理选择的文件
-(void)start;

@end

@protocol BYBaseWindowControllerProtocol <NSObject>

/// 窗口关闭
-(void)windowClose:(BYBaseWindowController *)window;

/// 窗口最小化
-(void)windowMiniaturize:(BYBaseWindowController *)window;

@end

NS_ASSUME_NONNULL_END
