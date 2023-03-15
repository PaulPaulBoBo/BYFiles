//
//  BYAnalyzeCommonClassUseStateWindowController.m
//  BYFiles
//
//  Created by Liu on 2023/1/11.
//

#import "BYAnalyzeCommonClassUseStateWindowController.h"
#import "AnalyzeCommonClassesUseState.h"
#import "GBTask+Finder.h"

static NSString *FirstAppearIntrpduce = @"操作步骤\n\
    第一步：点击”choose classes“按钮选择要处理的文件目录；\n\
    第二步：点击”choose folder“按钮选择要处理的文件所依赖的所有类（包含自身）；\n\
    第三步：点击”start“按钮启动遍历；\n\
    第四步：打开sourcetree查看修改的代码是否符合预期；\n\
    \n\
    可选：点击”choose files“按钮可以选择某些文件,点击”clear paths“按钮可以清除已选择的文件；\n\
    \n\
    找出无用的import引用\n\
";

@interface BYAnalyzeCommonClassUseStateWindowController ()

@property (weak) IBOutlet NSButton *chooseClasses;

@end

@implementation BYAnalyzeCommonClassUseStateWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupViews];
    [self setupTool];
    [self.chooseClasses setAction:@selector(clickChooseClasses)];
    [LogMsgTool updateMsg:FirstAppearIntrpduce tag:[self className] toTextView:self.msgTextView];
}

- (void)setupTool {
    if(self.tool == nil) {
        self.tool = [[AnalyzeCommonClassesUseState alloc] init];
        self.tool.msgTextView = self.msgTextView;
        self.tool.stateLabel = self.stateLabel;
        self.tool.progressView = self.progressView;
    }
}

/// MARK: Action

-(void)clickChooseClasses {
    __weak typeof(self) weakSelf = self;
    [ChoosePathTool openPanelCanChooseFiles:NO canMultipleSelection:NO finish:^(NSArray * _Nonnull paths) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if(paths == nil || paths.count == 0) {
            return;
        }
        BaseComment *pathTool = [[BaseComment alloc] init];
        [pathTool findFileInPath:paths.firstObject];
        [((AnalyzeCommonClassesUseState*)strongSelf.tool) configOrderClassPaths:pathTool.files];
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"共选择了%@个文件待处理：\n%@", @(pathTool.files.count), pathTool.files] tag:[self className] toTextView:self.msgTextView];
    }];
    ((AnalyzeCommonClassesUseState*)self.tool).findCompletion = ^(NSArray * _Nonnull paths) {
        [ChoosePathTool openPanelCanChooseFiles:NO canMultipleSelection:NO finish:^(NSArray * _Nonnull folders) {
            __weak typeof(weakSelf) strongSelf = weakSelf;
            if(folders == nil || folders.count == 0) {
                return;
            }
            [strongSelf copyConnectedClassesToOrderFolder:folders.firstObject paths:paths];
        }];
    };
}

/// 将相关联文件复制到目标文件夹
/// - Parameters:
///   - folder: 目标文件夹
///   - paths: 相关的文件路径数组
-(void)copyConnectedClassesToOrderFolder:(NSString *)folder paths:(NSArray *)paths {
    [paths enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj rangeOfString:@"RAutoExploreViewController+GioEvent"].length > 0) {
            NSLog(@"");
        }
        NSString *fileName = [obj componentsSeparatedByString:@"/"].lastObject;
        if([[fileName lowercaseString] rangeOfString:@"controller"].length > 0 ||
           [fileName rangeOfString:@"VC"].length > 0) {
            [self copyToSortFolderWithFileName:fileName folder:folder obj:obj newFolderName:@"Controller"];
        } else if([[fileName lowercaseString] rangeOfString:@"tool"].length > 0 ||
                  [[fileName lowercaseString] rangeOfString:@"manager"].length > 0 ||
                  [[fileName lowercaseString] rangeOfString:@"service"].length > 0) {
            [self copyToSortFolderWithFileName:fileName folder:folder obj:obj newFolderName:@"Services"];
        } else if([[fileName lowercaseString] rangeOfString:@"model"].length > 0) {
            [self copyToSortFolderWithFileName:fileName folder:folder obj:obj newFolderName:@"Model"];
        } else if([[fileName lowercaseString] rangeOfString:@"presenter"].length > 0) {
            [self copyToSortFolderWithFileName:fileName folder:folder obj:obj newFolderName:@"Presenter"];
        } else if([[fileName lowercaseString] rangeOfString:@"protocol"].length > 0) {
            [self copyToSortFolderWithFileName:fileName folder:folder obj:obj newFolderName:@"Protocol"];
        } else if([[fileName lowercaseString] rangeOfString:@"view"].length > 0 ||
                  [[fileName lowercaseString] rangeOfString:@"cell"].length > 0 ||
                  [[fileName lowercaseString] rangeOfString:@"bar"].length > 0) {
            [self copyToSortFolderWithFileName:fileName folder:folder obj:obj newFolderName:@"View"];
        } else {
            [self copyToSortFolderWithFileName:fileName folder:folder obj:obj newFolderName:@"Else"];
        }
    }];
}

- (void)copyToSortFolderWithFileName:(NSString *)fileName folder:(NSString *)folder obj:(NSString * _Nonnull)obj newFolderName:(NSString *)newFolderName {
    NSString *orderPath = [NSString stringWithFormat:@"%@/%@", folder, newFolderName];
    [GBTask mkdir:orderPath completion:^{
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [GBTask copy:obj orderFilePath:[NSString stringWithFormat:@"%@/%@", orderPath, fileName] completion:^{
            
        }];
    });
}

-(void)choosePath {
    [super choosePath];
}

/// 选择路径完成
-(void)choosePathFinish {
    [((AnalyzeCommonClassesUseState *)self.tool) analyzeFolder];
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
