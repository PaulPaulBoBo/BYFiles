//
//  BYFindConnectClassesWindowController.m
//  BYFiles
//
//  Created by Liu on 2022/12/20.
//

#import "BYFindConnectClassesWindowController.h"
#import "FindConnectClasses.h"
#import "GBTask+Finder.h"

static NSString *FirstAppearIntrpduce = @"操作步骤\n\
    第一步：点击”choose class“按钮选择要查找关联类的类文件；\n\
    第二步：点击”choose folder“按钮选择要处理的项目目录；\n\
    第三步：点击”start“按钮启动遍历；\n\
    第四步：打开最后选择的文件目录查看筛选出的类文件是否符合预期；\n\
    \n\
    可选：点击”choose files“按钮可以选择某些文件,点击”clear paths“按钮可以清除已选择的文件；\n\
    \n\
    查找相关类控制器\n\
";

@interface BYFindConnectClassesWindowController ()

@property (weak) IBOutlet NSButton *chooseClass;

@end

@implementation BYFindConnectClassesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupViews];
    [self setupTool];
    [self.chooseClass setAction:@selector(clickChooseClass)];
    [LogMsgTool updateMsg:FirstAppearIntrpduce tag:[self className] toTextView:self.msgTextView];
}

- (void)setupTool {
    if(self.tool == nil) {
        self.tool = [[FindConnectClasses alloc] init];
        self.tool.msgTextView = self.msgTextView;
        self.tool.stateLabel = self.stateLabel;
        self.tool.progressView = self.progressView;
    }
}

/// MARK: Action

-(void)clickChooseClass {
    __weak typeof(self) weakSelf = self;
    [ChoosePathTool openPanelCanChooseFiles:YES canMultipleSelection:YES finish:^(NSArray * _Nonnull paths) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if(paths == nil || paths.count == 0) {
            return;
        }
        [((FindConnectClasses*)strongSelf.tool) configOrderClassPaths:paths];
    }];
    ((FindConnectClasses*)self.tool).findCompletion = ^(NSArray * _Nonnull paths) {
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
    [((FindConnectClasses *)self.tool) analyzeFolder];
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
