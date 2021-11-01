//
//  LoadFileWindowController.m
//  BYFiles
//
//  Created by Liu on 2021/9/3.
//

#import "LoadFileWindowController.h"

@interface LoadFileWindowController ()

@property (weak) IBOutlet NSTextField *mUrl;

/** baseUrl */
@property (nonatomic, strong) NSString *baseUrl;

@end

@implementation LoadFileWindowController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self.window makeKeyWindow];
    }
    return self;
}

- (IBAction)start:(id)sender {
    if(self.mUrl.stringValue.length > 0 && [self.mUrl.stringValue rangeOfString:@"playlist.m3u8"].length > 0) {
        [self resetParam];
        [self createTmpPath];
        self.baseUrl = [self.mUrl.stringValue componentsSeparatedByString:@"playlist.m3u8"].firstObject;
        [self downloadMFile];
        [ChoosePathTool openFinderPath:self.mPath];
    } else {
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"地址无效，请重新输入:%@", self.mUrl.stringValue] toTextView:self.msgTextView];
    }
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
    
    self.mPath = [NSString stringWithFormat:@"%@/m", self.sourcePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.mPath]) {
        __weak typeof(self) weakSelf = self;
        [NSFileManager createPath:self.mPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf updateMsg:[NSString stringWithFormat:@"文件夹创建成功 %@", strongSelf.mPath]];
        }];
    }
    
    self.mFilePath = [NSString stringWithFormat:@"%@/%@.m3u8",self.mPath, dateStr];
    
    self.transMPath = [NSString stringWithFormat:@"%@/trans", self.sourcePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.transMPath]) {
        __weak typeof(self) weakSelf = self;
        [NSFileManager createPath:self.transMPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf updateMsg:[NSString stringWithFormat:@"文件夹创建成功 %@", strongSelf.transMPath]];
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

-(void)downloadMFile {
    [DownloadFileTool downloadURL:self.mUrl.stringValue destinationPath:self.mFilePath progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completion:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        NSString *path = self.mPath;
        BYFileTreeModel *model = [NSFileManager loadFilesInPath:path level:@0 isContinue:YES];
        NSMutableArray *mArr = [NSMutableArray new];
        for (int i = 0; i < model.files.count; i++) {
            BYFileModel *file = model.files[i];
            if([file.fileName rangeOfString:@".m3u8"].length > 0) {
                [mArr addObject:file];
                break;
            }
        }
        [self writeFileIndex:0 array:mArr];
    }];
}

-(void)writeFileIndex:(NSInteger)index array:(NSArray *)array {
    if(index == array.count) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.fileModel = [NSFileManager loadFilesInPath:strongSelf.transMPath level:@0 isContinue:YES];
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
    [ConvertFileTool convertFilePath:subModel.filePath toPath:self.transMPath baseURLStr:self.baseUrl log:^(NSString * _Nonnull msg) {
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
    if(listArr.count == 0) {
        return;
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
