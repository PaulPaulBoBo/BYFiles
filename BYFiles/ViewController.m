//
//  ViewController.m
//  BYFiles
//
//  Created by Liu on 2021/8/28.
//

#import "ViewController.h"
#import "NSFileManager+BY.h"
#import "NSData+BY.h"
#import "AFNetworking.h"
#import "NSDate+BY.h"

@interface ViewController ()

@property (nonatomic, strong) BYFileTreeModel *fileModel;
@property (nonatomic, assign) NSInteger fileIndex;
@property (unsafe_unretained) IBOutlet NSTextView *msgTextView;
@property (nonatomic, strong) NSString *categoryFolderPath;
@property (nonatomic, strong) NSString *tsFilesPath;

@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, strong) NSString *orderPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.fileIndex = 0;
//    self.tsFilesPath = [NSString stringWithFormat:@"%@/TSFiles", [NSFileManager documentPath]];
//    [NSFileManager createPath:self.tsFilesPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
//
//    }];
    
    
}

-(void)updateMsg:(NSString *)msg {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *dateStr = [NSDate stringWithDate:[NSDate date] type:(BY_DateFormatterType_ymdhms)];
        if(self.msgTextView.string.length == 0) {
            self.msgTextView.string = [NSString stringWithFormat:@"%@:%@", dateStr, msg];
        } else {
            self.msgTextView.string = [NSString stringWithFormat:@"%@:%@\n%@", dateStr, msg, self.msgTextView.string];
        }
    });
}

- (IBAction)choosePath:(id)sender {
    [self openPanelCanChooseFiles:NO finish:^(NSString *path) {
        
    }];
//    NSString *dateStr = [NSDate stringWithDate:[NSDate date] type:(BY_DateFormatterType_ymdhms)];
//    self.categoryFolderPath = [NSString stringWithFormat:@"%@/%@",[NSFileManager documentPath], [NSString stringWithFormat:@"videosFolder_%@", dateStr]];
//    [NSFileManager createPath:self.categoryFolderPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
//        [self updateMsg:[NSString stringWithFormat:@"%@  %@", msg, self.categoryFolderPath]];
//    }];
//    [self appendUrl];
}

-(void)appendUrl {
    __weak typeof(self) weakSelf = self;
    [self openPanelCanChooseFiles:NO finish:^(NSString *path) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        BYFileTreeModel *model = [NSFileManager loadFilesInPath:path level:@0 isContinue:YES];
        NSString *listFilePath = [NSString stringWithFormat:@"%@/%.0lf", [NSFileManager documentPath], [[NSDate date] timeIntervalSince1970]];
        [NSFileManager createPath:listFilePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
            NSMutableArray *mArr = [NSMutableArray new];
            NSMutableArray *names = [NSMutableArray new];
            for (int i = 0; i < model.subPaths.count; i++) {
                BYFileTreeModel *subModel = model.subPaths[i];
                [names addObject:subModel.pathName];
                for (int j = 0; j < subModel.files.count; j++) {
                    BYFileModel *file = subModel.files[j];
                    if([file.fileName rangeOfString:@".m3u8"].length > 0) {
                        [mArr addObject:file];
                        break;
                    }
                }
            }
            [strongSelf writeFileIndex:0 array:mArr names:names listFilePath:listFilePath];
        }];
        
    }];
}

-(void)writeFileIndex:(NSInteger)index array:(NSArray *)array names:(NSArray *)names listFilePath:(NSString *)listFilePath {
    if(index == array.count) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.fileModel = [NSFileManager loadFilesInPath:listFilePath level:@0 isContinue:YES];
            if(strongSelf.fileModel.files.count > 0) {
                [strongSelf updateMsg:[NSString stringWithFormat:@"当前路径下共有%ld个文件", strongSelf.fileModel.files.count]];
                [strongSelf beginDownloadNextFile];
            } else {
                [strongSelf updateMsg:@"当前目录无文件"];
            }
        });
        return;
    }
    BYFileModel *subModel = array[index];
    NSData *data = [NSFileManager readFileDataWithFilePath:subModel.filePath];
    NSString *str = [data dataToString];
    while ([str rangeOfString:@"transcode_"].length > 0) {
        str = [str stringByReplacingOccurrencesOfString:@"transcode_" withString:[NSString stringWithFormat:@"https://play-tx-recpub.douyucdn2.cn/live/%@/++--++", names[index]]];
    }
    while ([str rangeOfString:@"++--++"].length > 0) {
        str = [str stringByReplacingOccurrencesOfString:@"++--++" withString:@"transcode_"];
    }
    NSString *newFile = [NSString stringWithFormat:@"%@/file_%.0lf.m3u8", listFilePath, [[NSDate date] timeIntervalSince1970]];
    __weak typeof(self) weakSelf = self;
    [NSFileManager writeData:[NSData dataWithString:str] toFile:newFile finish:^(BOOL isSuc, NSString * _Nullable msg) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf writeFileIndex:index+1 array:array names:names listFilePath:listFilePath];
        });
    }];
}

-(void)beginDownloadNextFile {
    if(self.fileIndex >= self.fileModel.files.count) {
        [self updateMsg:@"下载完成！！！！"];
        return;
    }
    BYFileModel *file = self.fileModel.files[self.fileIndex];
    if([file.fileName rangeOfString:@".m3u8"].length > 0) {
        [self dealPlayListWithFilePath:file.filePath];
        self.fileIndex++;
    } else {
        self.fileIndex++;
        [self beginDownloadNextFile];
    }
}

// 处理m3u8文件
- (void)dealPlayListWithFilePath:(NSString *)filePath {
    // 读取m3u8文件内容
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [content componentsSeparatedByString:@"\n"];
    // 筛选出 .ts 文件
    NSMutableArray *listArr = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *str in array) {
        if ([str hasPrefix:@"http"]) {
            [listArr addObject:str];
        }
    }
    NSString *firstStr = listArr.firstObject;
    NSString *videoName = [firstStr componentsSeparatedByString:@"."].firstObject;
    // 下载 ts 文件
    [self downloadVideoWithArr:listArr andIndex:0 videoName:videoName];
}

// 循环下载 ts 文件
- (void)downloadVideoWithArr:(NSArray *)listArr andIndex:(NSInteger)index videoName:(NSString *)videoName {
    if (index >= listArr.count) {
        [self combVideos];
        return;
    }
    NSString *fileUrl = listArr[index];
    NSString *fileType = [[fileUrl componentsSeparatedByString:@"?"].firstObject componentsSeparatedByString:@"."].lastObject;
    if(fileType == nil || fileType.length == 0) {
        fileType = @"ts";
    }
    NSString *fileName = [NSString stringWithFormat:@"video_%ld.%@", (long)index, fileType];
    NSString *destinationPath = [self.tsFilesPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        [self downloadVideoWithArr:listArr andIndex:index+1 videoName:videoName];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self downloadURL:fileUrl destinationPath:destinationPath progress:nil completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf updateMsg:[NSString stringWithFormat:@"文件\"%@\"下载成功!", fileUrl]];
            [strongSelf downloadVideoWithArr:listArr andIndex:index+1 videoName:videoName];
        } else {
            [strongSelf updateMsg:[NSString stringWithFormat:@"下载失败:%@", error.localizedDescription]];
        }
    }];
}

- (void)downloadURL:(NSString *)downloadURL
    destinationPath:(NSString *)destinationPath
           progress:(void (^)(NSProgress *downloadProgress))progress
         completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion {
    AFHTTPSessionManager *manage  = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: downloadURL]];
    
    NSURLSessionDownloadTask *downloadTask =
    [manage downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *filePathUrl = nil;
        if (destinationPath) {
            filePathUrl = [NSURL fileURLWithPath:destinationPath];
        }
        if (filePathUrl) {
            return filePathUrl;
        }
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fullpath = [caches stringByAppendingPathComponent:response.suggestedFilename];
        filePathUrl = [NSURL fileURLWithPath:fullpath];
        return filePathUrl;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        if (completion) {
            completion(response, filePath, error);
        }
    }];
    
    [downloadTask resume];
}


// 合成为一个ts文件
- (void)combVideos {
    [self updateMsg:@"开始合并数据"];
    NSString *filePath = [NSString stringWithFormat:@"%@/video_%.0lf.mp4", self.categoryFolderPath, [[NSDate date] timeIntervalSince1970]];
    NSArray *contentArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.tsFilesPath error:nil];
    NSMutableData *dataArr = [NSMutableData alloc];
    int videoCount = 0;
    for (NSString *str in contentArr) {
        // 按顺序拼接 TS 文件
        if ([str containsString:@"video_"]) {
            NSString *videoName = [NSString stringWithFormat:@"video_%d.%@", videoCount, str.pathExtension];
            NSString *videoPath = [self.tsFilesPath stringByAppendingPathComponent:videoName];
            // 读出数据
            NSData *data = [[NSData alloc] initWithContentsOfFile:videoPath];
            // 合并数据
            [dataArr appendData:data];
            videoCount++;
            [NSFileManager deleteFile:videoPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
                
            }];
        }
    }
    __weak typeof(self) weakSelf = self;
    [NSFileManager writeData:dataArr toFile:filePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateMsg:[NSString stringWithFormat:@"%@  %@", msg, filePath]];
    }];
    [self updateMsg:@"2秒后开始下一个文件下载"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf beginDownloadNextFile];
    });
}

-(void)openPanelCanChooseFiles:(BOOL)canChooseFiles finish:(void(^)(NSString *path))finish {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    //是否可以创建文件夹
    panel.canCreateDirectories = !canChooseFiles;
    //是否可以选择文件夹
    panel.canChooseDirectories = !canChooseFiles;
    //是否可以选择文件
    panel.canChooseFiles = canChooseFiles;
    //是否可以多选
    [panel setAllowsMultipleSelection:canChooseFiles];
    //显示
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSInteger result) {
        //是否点击open 按钮
        if (result == NSModalResponseOK) {
            if(finish) {
                NSString *pathString = [panel.URLs.firstObject path];
                finish(pathString);
            }
        }
    }];
}

#pragma mark - single function

-(void)moveFile {
    __weak typeof(self) weakSelf = self;
    [self openPanelCanChooseFiles:NO finish:^(NSString *path) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.sourcePath = path;
        BYFileTreeModel *model = [NSFileManager loadFilesInPath:path level:@0 isContinue:YES];
        for (int i = 0; i < model.subPaths.count; i++) {
            BYFileTreeModel *subModel = model.subPaths[i];
            for (int j = 0; j < subModel.files.count; j++) {
                BYFileModel *fileModel = subModel.files[j];
                strongSelf.orderPath = [NSString stringWithFormat:@"%@/%@", strongSelf.sourcePath, fileModel.fileName];
                NSError *error = nil;
                BOOL isSuc = [[NSFileManager defaultManager] moveItemAtPath:fileModel.filePath toPath:strongSelf.orderPath error:&error];
                if(isSuc) {
                    [strongSelf updateMsg:[NSString stringWithFormat:@"移动完成 %@", strongSelf.orderPath]];
                    [NSFileManager deleteFile:[NSString stringWithFormat:@"%@/%@", strongSelf.sourcePath, subModel.pathName] finish:^(BOOL isSuc, NSString * _Nullable msg) {
                        [strongSelf updateMsg:[NSString stringWithFormat:@"文件夹操作: %@", msg]];
                    }];
                } else {
                    [strongSelf updateMsg:[NSString stringWithFormat:@"移动失败: %@", error.localizedDescription]];
                }
            }
            
        }
    }];
}

@end

