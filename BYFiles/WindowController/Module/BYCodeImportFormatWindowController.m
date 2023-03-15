//
//  BYCodeImportFormatWindowController.m
//  BYFiles
//
//  Created by Liu on 2022/11/11.
//

#import "BYCodeImportFormatWindowController.h"
#import "ImportCode.h"

@interface BYCodeImportFormatWindowController ()

@property (weak) IBOutlet NSButton *selectPodsBtn;

@end

static NSString *FirstAppearIntrpduce = @"操作步骤\n\
    第一步：点击”select pods folder“按钮选择项目依赖的pods文件目录，以构建类与组件的关联关系，为下一步格式化做准备；此步骤必不可少；如需格式化新的项目此步骤仍需重新执行。\n\
    第二步：点击”choose folder“按钮选择要处理的项目目录；\n\
    第三步：点击”start“按钮启动遍历；\n\
    第四步：打开sourcetree查看修改的代码是否符合预期；\n\
    \n\
    可选：点击”choose files“按钮可以选择某些文件,点击”clear paths“按钮可以清除已选择的文件；\n\
    \n\
    import引用文件规范\n\
    1. 非当前组件的头文件引用转换为<模块名/类名.h>\n\
";

@implementation BYCodeImportFormatWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.selectPodsBtn setAction:@selector(clickSelectPodsBtn)];
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
        self.tool = [[ImportCode alloc] init];
        self.tool.msgTextView = self.msgTextView;
        self.tool.stateLabel = self.stateLabel;
        self.tool.progressView = self.progressView;
    }
}

/// MARK: Action

-(void)clickSelectPodsBtn {
    __weak typeof(self) weakSelf = self;
    [ChoosePathTool openPanelCanChooseFiles:NO canMultipleSelection:NO finish:^(NSArray * _Nonnull paths) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if(paths == nil || paths.count == 0) {
            return;
        }
        NSString *path = paths.firstObject;
        [((ImportCode*)strongSelf.tool) findFileInPath:path];
        ((ImportCode*)strongSelf.tool).path = path;
        ((ImportCode*)strongSelf.tool).fileCount = ((ImportCode*)strongSelf.tool).files.count;
        [((ImportCode*)strongSelf.tool) setupBaseFilesInPaths:((ImportCode*)strongSelf.tool).files];
    }];
}

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
