//
//  ImportCode.m
//  BYFiles
//
//  Created by Liu on 2022/11/4.
//

#import "ImportCode.h"
#import "AnalyzeCode.h"

@interface ImportCode()

@property (nonatomic, strong) NSMutableArray *filesCopy;
@property (nonatomic, strong) NSMutableArray *fileModels;
@property (nonatomic, strong) AnalyzeCode *analyze;

@end

@implementation ImportCode

/// 启动入口
-(void)start {
    if(self.fileModels == nil || self.fileModels.count == 0) {
        [LogMsgTool updateMsg:@"请先通过‘select pods folder’按钮选择基础分析仓库代码（当前要规范化的库依赖的所有其他库的Pods）" tag:[self className] toTextView:self.msgTextView];
        return;
    }
    [self expectPodsFiles];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf startImport];
    });
}

-(void)startImport {
    if(self.files.count > 0 && IsRunning == NO) {
        IsRunning = YES;
        NSString *path = self.files.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始规范化 %@", path] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf formatComment:path completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"规范化完成 %@", path] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.files.count > 0) {
                    [strongSelf.files removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.files.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"%@ 当前进度：%.2lf%@ 规范化完成:%@", @(strongSelf.files.count), process*100, @"%", [path componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startImport];
                }
            }];
        });
    } else {
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"规范化完成!"] tag:[self className] toTextView:self.msgTextView];
    }
}

-(void)setupBaseFilesInPaths:(NSArray *)paths {
    self.fileModels = [NSMutableArray array];
    self.filesCopy = [NSMutableArray arrayWithArray:paths];
    self.analyze.msgTextView = self.msgTextView;
    self.analyze.stateLabel = self.stateLabel;
    self.analyze.progressView = self.progressView;
    __weak typeof(self) weakSelf = self;
    [self.analyze loadHFilesInfoInPath:self.filesCopy completion:^(NSArray<AnalyzeCodeModel *> * _Nonnull arr) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.fileModels = [NSMutableArray arrayWithArray:arr];
        [strongSelf expectPodsFiles];
    }];
}

-(void)formatComment:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    if([filePath rangeOfString:@"Pods/"].length > 0) {
        completion(NO, @"");
    } else {
        NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
        NSString *string = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        if(string.length > 0) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@"\n"]];
            
            // import规范化
            if([[GeneralConfig shareInstance] readSettionWithKey:@"500"]) {
                NSString *fileName = [[filePath componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject;
                [self formatImportComment:arr fileName:fileName];
            }
            
            NSMutableString *mStr = [NSMutableString new];
            for (int i= 0; i < arr.count; i++) {
                if(i == arr.count-1) {
                    [mStr appendFormat:@"%@", arr[i]];
                } else {
                    [mStr appendFormat:@"%@\n", arr[i]];
                }
                
            }
            NSData *data = [mStr dataUsingEncoding:NSUTF8StringEncoding];
            if(data) {
                [NSFileManager writeData:data toFile:[NSString stringWithFormat:@"%@", filePath] finish:completion];
            }
        } else {
            completion(NO, @"");
        }
    }
}

/// import规范化
/// @param arr 代码行数组
-(void)formatImportComment:(NSMutableArray *)arr fileName:(NSString *)fileName {
    AnalyzeCodeModel *currentFileModel = [self findInfoWithClassName:fileName];
    if(currentFileModel) {
        for (int i = 0; i < arr.count-1; i++) {
            NSString *lineCode = arr[i];
            NSString *importClassName = @"";
            if([lineCode hasPrefix:@"#import"]){
                if([lineCode rangeOfString:@"<"].length > 0 && [lineCode rangeOfString:@"/"].length == 0) {
                    // #import <file.h>
                    importClassName = [lineCode substringWithRange:NSMakeRange([lineCode rangeOfString:@"<"].location+[lineCode rangeOfString:@"<"].length, [lineCode rangeOfString:@".h>"].location-([lineCode rangeOfString:@"<"].location+[lineCode rangeOfString:@"<"].length))];
                    AnalyzeCodeModel *importClassFileModel = [self findInfoWithClassName:importClassName];
                    if(importClassFileModel.moduleName.length > 0 && ![[importClassFileModel.moduleName lowercaseString] isEqual:[currentFileModel.moduleName lowercaseString]]) {
                        lineCode = [self.loadFileTools replaceSpecStr:[NSString stringWithFormat:@"<%@.h>", importClassName] withString:[NSString stringWithFormat:@"<%@/%@.h>", importClassFileModel.moduleName, importClassName] inString:lineCode];
                        [arr replaceObjectAtIndex:i withObject:lineCode];
                    }
                } else if([lineCode rangeOfString:@"<"].length == 0 && [lineCode rangeOfString:@"\""].length > 0) {
                    // #import ""
                    importClassName = [lineCode substringWithRange:NSMakeRange([lineCode rangeOfString:@" \""].location+[lineCode rangeOfString:@" \""].length, [lineCode rangeOfString:@".h\""].location-([lineCode rangeOfString:@" \""].location+[lineCode rangeOfString:@" \""].length))];
                    AnalyzeCodeModel *importClassFileModel = [self findInfoWithClassName:importClassName];
                    if(importClassFileModel.moduleName.length > 0 && ![importClassFileModel.moduleName isEqual:currentFileModel.moduleName]) {
                        lineCode = [self.loadFileTools replaceSpecStr:[NSString stringWithFormat:@"\"%@.h\"", importClassName] withString:[NSString stringWithFormat:@"<%@/%@.h>", importClassFileModel.moduleName, importClassName] inString:lineCode];
                        [arr replaceObjectAtIndex:i withObject:lineCode];
                    }
                }
            }
        }
    }
}

-(AnalyzeCodeModel *)findInfoWithClassName:(NSString *)className {
    if([className rangeOfString:@"."].length > 0) {
        className = [className componentsSeparatedByString:@"."].firstObject;
    }
    AnalyzeCodeModel *classModel = nil;
    for (int i = 0; i < self.fileModels.count; i++) {
        AnalyzeCodeModel *model = self.fileModels[i];
        if([model.className isEqual:className]) {
            classModel = model;
            break;
        }
    }
    return classModel;
}

- (AnalyzeCode *)analyze {
    if(_analyze == nil) {
        _analyze = [[AnalyzeCode alloc] init];
    }
    return _analyze;
}

@end
