//
//  BYCodeClassImportWindowController.m
//  BYFiles
//
//  Created by Liu on 2022/11/11.
//

#import "BYCodeClassImportWindowController.h"
#import "AnalyzeCode.h"
#import <QuartzCore/CAShapeLayer.h>

@interface BYCodeClassImportWindowController ()

@end

static NSString *FirstAppearIntrpduce = @"操作步骤\n\
    第一步：点击”choose folder“按钮选择要处理的项目目录；\n\
    第二步：点击”start“按钮启动遍历；\n\
    第三步：打开sourcetree查看修改的代码是否符合预期；\n\
    \n\
    可选：点击”choose files“按钮可以选择某些文件,点击”clear paths“按钮可以清除已选择的文件；\n\
    \n\
    分析import引用关系\n\
    1. 导出某组件对其他组件的import列表\n\
    分析组件依赖关系\n\
    1. 导出某组件对其他组件的依赖\n\
";

@implementation BYCodeClassImportWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupViews];
    [self setupTool];
    __weak typeof(self) weakSelf = self;
    [LogMsgTool clearHistory:self.msgTextView tag:[self className] completion:^(NSString * _Nonnull msg) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [LogMsgTool updateMsg:FirstAppearIntrpduce tag:[strongSelf className] toTextView:strongSelf.msgTextView];
    }];
}

/// MARK: private

- (void)setupTool {
    if(self.tool == nil) {
        self.tool = [[AnalyzeCode alloc] init];
        self.tool.msgTextView = self.msgTextView;
        self.tool.stateLabel = self.stateLabel;
        self.tool.progressView = self.progressView;
    }
}

/// MARK: Action

-(void)choosePath {
    [super choosePath];
}

-(void)chooseFilss {
    [super chooseFilss];
}

-(void)clearPaths {
    [super clearPaths];
}

-(void)start {
    [super start];
}
@end
