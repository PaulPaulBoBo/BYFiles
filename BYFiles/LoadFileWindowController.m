//
//  LoadFileWindowController.m
//  BYFiles
//
//  Created by Liu on 2021/9/3.
//

#import "LoadFileWindowController.h"

@interface LoadFileWindowController ()

@end

@implementation LoadFileWindowController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self.window makeKeyWindow];
    }
    return self;
}

- (instancetype)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        self.fileIndex = 0;
        self.stateLabel.stringValue = @"";
        self.progressView.minValue = 0;
        self.progressView.maxValue = 100;
        self.progressView.doubleValue = 0;
        self.progressView.indeterminate = NO;
        [self createTmpPath];
        [self.window makeKeyWindow];
    }
    return self;
}

- (IBAction)choosePath:(id)sender {
    [self resetParam];
    [self createTmpPath];
    [self appendUrl];
}

#pragma mark - private

-(void)resetParam {
    self.fileIndex = 0;
    self.stateLabel.stringValue = @"";
    self.progressView.minValue = 0;
    self.progressView.maxValue = 100;
    self.progressView.doubleValue = 0;
    self.progressView.indeterminate = NO;
}

-(void)createTmpPath {
    NSString *dateStr = [NSDate stringWithDate:[NSDate date] formatStr:@"yyyyMMddHHmmss"];
    
    self.sourcePath = [NSString stringWithFormat:@"%@/%@", [NSFileManager cachePath], dateStr];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.sourcePath]) {
        __weak typeof(self) weakSelf = self;
        [NSFileManager createPath:self.sourcePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf updateMsg:[NSString stringWithFormat:@"文件夹创建成功 %@", strongSelf.sourcePath]];
        }];
    }
    
    self.tsFilesPath = [NSString stringWithFormat:@"%@/TmpFolder", self.sourcePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.tsFilesPath]) {
        [NSFileManager createPath:self.tsFilesPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            
        }];
    }
    
    self.categoryFolderPath = [NSString stringWithFormat:@"%@/%@", self.sourcePath, [NSString stringWithFormat:@"outputFolder"]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.categoryFolderPath]) {
        __weak typeof(self) weakSelf = self;
        [NSFileManager createPath:self.categoryFolderPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf updateMsg:[NSString stringWithFormat:@"%@  %@", msg, self.categoryFolderPath]];
        }];
    }
}

-(void)appendUrl {
    __weak typeof(self) weakSelf = self;
    [ChoosePathTool openPanelCanChooseFiles:NO finish:^(NSString *path) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [NSFileManager createPath:strongSelf.sourcePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            BYFileTreeModel *model = [NSFileManager loadFilesInPath:path level:@0 isContinue:YES];
            NSMutableArray *mArr = [NSMutableArray new];
            for (int i = 0; i < model.subPaths.count; i++) {
                BYFileTreeModel *subModel = model.subPaths[i];
                for (int j = 0; j < subModel.files.count; j++) {
                    BYFileModel *file = subModel.files[j];
                    if([file.fileName rangeOfString:@".m3u8"].length > 0) {
                        [mArr addObject:file];
                        break;
                    }
                }
            }
            [strongSelf writeFileIndex:0 array:mArr];
            [ChoosePathTool openFinderPath:strongSelf.sourcePath];
        }];
    }];
}

-(void)writeFileIndex:(NSInteger)index array:(NSArray *)array {
    if(index == array.count) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.fileModel = [NSFileManager loadFilesInPath:strongSelf.sourcePath level:@0 isContinue:YES];
            if(strongSelf.fileModel.files.count > 0) {
                [strongSelf updateMsg:[NSString stringWithFormat:@"当前路径下共有%ld个文件", strongSelf.fileModel.files.count]];
                [strongSelf beginDownloadNextFile];
            } else {
                [strongSelf updateMsg:@"当前目录无文件"];
            }
        });
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    BYFileModel *subModel = array[index];
    [ConvertFileTool convertFilePath:subModel.filePath toPath:self.sourcePath baseURLStr:@"https://play-tx-recpub.douyucdn2.cn/live" log:^(NSString * _Nonnull msg) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateMsg:msg];
    } completion:^(NSString * _Nonnull filePath) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf writeFileIndex:index+1 array:array];
    }];
}

-(void)beginDownloadNextFile {
    if(self.fileIndex >= self.fileModel.files.count) {
        [self updateMsg:@"下载完成！！！！"];
        return;
    }
    BYFileModel *file = self.fileModel.files[self.fileIndex];
    if([file.fileName rangeOfString:@".m3u8"].length > 0) {
        [self dealPlayListWithFilePath:file];
        self.fileIndex++;
    } else {
        self.fileIndex++;
        [self beginDownloadNextFile];
    }
}

// 处理文件
- (void)dealPlayListWithFilePath:(BYFileModel *)file {
    // 读取文件内容
    NSString *content = [NSString stringWithContentsOfFile:file.filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [content componentsSeparatedByString:@"\n"];
    // 筛选文件
    NSMutableArray *listArr = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *str in array) {
        if ([str hasPrefix:@"http"]) {
            [listArr addObject:str];
        }
    }
    // 下载文件
    __weak typeof(self) weakSelf = self;
    [DownloadFileTool downloadVideoWithArr:listArr andIndex:0 cacheFilePath:self.tsFilesPath log:^(NSString * _Nonnull msg) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateMsg:msg];
    } progress:^(NSProgress * _Nonnull downloadProgress, NSString * _Nonnull downloadingUrl) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.progressView.doubleValue = downloadProgress.completedUnitCount*100./downloadProgress.totalUnitCount;
            strongSelf.stateLabel.stringValue = downloadingUrl;
        });
    } completion:^(NSString * _Nonnull filePath) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [CombineFileTool combVideosInPath:filePath outputPath:self.categoryFolderPath log:^(NSString * _Nonnull msg) {
            [strongSelf updateMsg:msg];
        } completion:^(NSString * _Nonnull filePath) {
            [strongSelf beginDownloadNextFile];
            strongSelf.progressView.doubleValue = 0;
            strongSelf.stateLabel.stringValue = @"";
        }];
    }];
}

-(void)updateMsg:(NSString *)msg {
    [LogMsgTool updateMsg:msg toTextView:self.msgTextView];
}

@end
