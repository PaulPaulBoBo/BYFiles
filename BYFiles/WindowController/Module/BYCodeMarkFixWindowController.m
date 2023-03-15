//
//  BYCodeMarkFixWindowController.m
//  BYFiles
//
//  Created by Liu on 2022/11/11.
//

#import "BYCodeMarkFixWindowController.h"
#import "TransComment.h"

@interface BYCodeMarkFixWindowController ()

@end

static NSString *FirstAppearIntrpduce = @"操作步骤\n\
    第一步：点击”choose folder“按钮选择要处理的项目目录；\n\
    第二步：点击”start“按钮启动遍历；\n\
    第三步：打开sourcetree查看修改的代码是否符合预期；\n\
    \n\
    可选：点击”choose files“按钮可以选择某些文件,点击”clear paths“按钮可以清除已选择的文件；\n\
    \n\
    将已有注释的格式转换\n\
    1. 所有类、方法、属性、枚举、协议、static均改为三斜杠方式注释\n\
    2. 注释中多余的空格和冒号会删掉，必要的空格会补全\n\
    3. 部分特殊注释不作处理，例如（xxx代表注释内容）：”///** xxx */“、\"////\"、\"////////\"\n\
    4. 代码和注释在一行的统一改为注释在代码前一行，与代码左对齐\n\
";


@implementation BYCodeMarkFixWindowController

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
        self.tool = [[TransComment alloc] init];
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
