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

@interface ViewController ()

@property (nonatomic, strong) BYFileTreeModel *fileModel;
@property (nonatomic, assign) NSInteger fileIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fileIndex = 0;
    [self openPanelCanChooseFiles:NO finish:^(NSString *path) {
        self.fileModel = [NSFileManager loadFilesInPath:path level:@0 isContinue:YES];
        
        [self beginDownloadNextFile];
    }];
}

-(void)appendUrl {
    [self openPanelCanChooseFiles:NO finish:^(NSString *path) {
        BYFileTreeModel *model = [NSFileManager loadFilesInPath:path level:@0 isContinue:YES];
        for (int i = 0; i < model.subPaths.count; i++) {
            BYFileTreeModel *subModel = model.subPaths[i];
            for (int j = 0; j < subModel.files.count; j++) {
                BYFileModel *file = subModel.files[j];
                if([file.fileName rangeOfString:@".m3u8"].length > 0) {
                    NSData *data = [NSFileManager readFileDataWithFilePath:file.filePath];
                    NSString *str = [data dataToString];
                    while ([str rangeOfString:@"transcode_"].length > 0) {
                        str = [str stringByReplacingOccurrencesOfString:@"transcode_" withString:[NSString stringWithFormat:@"https://play-tx-ugcpub.douyucdn2.cn/live/%@/++--++", subModel.pathName]];
                    }
                    while ([str rangeOfString:@"++--++"].length > 0) {
                        str = [str stringByReplacingOccurrencesOfString:@"++--++" withString:@"transcode_"];
                    }
                    NSString *newFile = [NSString stringWithFormat:@"%@/minana_%.0lf.m3u8", [NSFileManager cachePath], [[NSDate date] timeIntervalSince1970]];
                    __weak typeof(self) weakSelf = self;
                    [NSFileManager writeData:[NSData dataWithString:str] toFile:newFile finish:^(BOOL isSuc, NSString * _Nullable msg) {
                        NSLog(@"%@ %@", msg, newFile);
                        __weak typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf dealPlayListWithFilePath:newFile];
                    }];
                    break;
                }
            }
        }
    }];
}

-(void)beginDownloadNextFile {
    if(self.fileIndex >= self.fileModel.files.count) {
        return;
    }
    BYFileModel *file = self.fileModel.files[self.fileIndex];
    if([file.fileName rangeOfString:@".m3u8"].length > 0) {
        [self dealPlayListWithFilePath:file.filePath];
        self.fileIndex++;
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
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *destinationPath = [caches stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        [self downloadVideoWithArr:listArr andIndex:index+1 videoName:videoName];
        return;
    }
    
    __weak typeof(self)wkSelf = self;
    [self downloadURL:fileUrl destinationPath:destinationPath progress:nil completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            [wkSelf downloadVideoWithArr:listArr andIndex:index+1 videoName:videoName];
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
    NSString *fileName = [NSString stringWithFormat:@"video_%.0lf.mp4", [[NSDate date] timeIntervalSince1970] ];
    NSString *filePath = [[NSFileManager documentPath] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    
    NSArray *contentArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSFileManager cachePath] error:nil];
    NSMutableData *dataArr = [NSMutableData alloc];
    int videoCount = 0;
    for (NSString *str in contentArr) {
        // 按顺序拼接 TS 文件
        if ([str containsString:@"video_"]) {
            NSString *videoName = [NSString stringWithFormat:@"video_%d.%@",videoCount, str.pathExtension];
            NSString *videoPath = [[NSFileManager cachePath] stringByAppendingPathComponent:videoName];
            // 读出数据
            NSData *data = [[NSData alloc] initWithContentsOfFile:videoPath];
            // 合并数据
            [dataArr appendData:data];
            videoCount++;
            [NSFileManager deleteFile:videoPath finish:^(BOOL isSuc, NSString * _Nullable msg) {
                
            }];
        }
    }
    [NSFileManager writeData:dataArr toFile:filePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
        NSLog(@"%@  %@", msg, filePath);
        sleep(3);
        [self beginDownloadNextFile];
    }];
    
    //    [[FFmpegManager sharedManager] converWithInputPath:@""
    //                                            outputPath:@""
    //                                          processBlock:^(float process) {
    //        //        self.tipLab.text = [NSString stringWithFormat:@"转码中 %.2f%%", process * 100];
    //        //        self.progressView.progress = process;
    //    } completionBlock:^(NSError *error) {
    //        //        if (error) {
    //        //            NSLog(@"转码失败 : %@", error);
    //        //            self.tipLab.text = @"转码失败";
    //        //        } else {
    //        //            NSLog(@"转码成功，请在相应路径查看，默认在沙盒Documents路径");
    //        //            self.tipLab.text = @"恭喜，转码成功！";
    //        //        }
    //    }];
    
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



@end

