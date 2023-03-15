//
//  FindUnusedImport.m
//  BYFiles
//
//  Created by Liu on 2023/1/10.
//

#import "FindUnusedImport.h"
#import "AnalyzeCode.h"

@interface FindUnusedImport()

@property (nonatomic, strong) AnalyzeCode *analyzeCode;

@property (nonatomic, strong) NSMutableArray *fileModels;
@property (nonatomic, strong) NSMutableArray *subClassPathes;
@property (nonatomic, strong) NSMutableArray *unusedImports;

@end

@implementation FindUnusedImport

/// 配置目标类路径 必须在调用start方法前
/// - Parameter orderClassesPath: 目标类路径
-(void)configOrderClassPaths:(NSArray * __nonnull)orderClassesPaths {
    [self bindUI];
    [self.subClassPathes removeAllObjects];
    [self.subClassPathes addObjectsFromArray:orderClassesPaths];
}

/// 选择完依赖的文件夹主动调用，开始分析所有相关的类文件
-(void)analyzeFolder {
    [self bindUI];
    [self.fileModels removeAllObjects];
    __block NSMutableArray *arr = [NSMutableArray new];
    for (int i = 0; i < self.files.count; i++) {
        if([self.files[i] rangeOfString:@".h"].length > 0 || [self.files[i] rangeOfString:@".m"].length > 0) {
            [arr addObject:self.files[i]];
        }
    }
    self.fileCount = arr.count;
    [LogMsgTool updateMsg:[NSString stringWithFormat:@"筛选出%@个文件", @(arr.count)] tag:[self className] toTextView:self.msgTextView];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [self.analyzeCode loadHFilesInfoInPath:arr completion:^(NSArray<AnalyzeCodeModel *> * _Nonnull arr) {
            [strongSelf.fileModels addObjectsFromArray:arr];
        }];
    });
}

/// 启动入口
-(void)start {
    [self bindUI];
    if(self.fileModels.count == 0) {
        [LogMsgTool updateMsg:@"请先选择依赖的文件路径" tag:[self className] toTextView:self.msgTextView];
        return;
    }
    [self startFind];
}

-(void)bindUI {
    self.analyzeCode.msgTextView = self.msgTextView;
    self.analyzeCode.stateLabel = self.stateLabel;
    self.analyzeCode.progressView = self.progressView;
}

-(void)startFind {
    if(self.subClassPathes.count > 0 && IsRunning == NO) {
        self.fileCount = self.subClassPathes.count;
        IsRunning = YES;
        NSString *filePath = self.subClassPathes.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始查找 %@", filePath] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf findUnusedImport:filePath completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"查找完成 %@", filePath] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.subClassPathes.count > 0) {
                    [strongSelf.subClassPathes removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.subClassPathes.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"%@ 当前进度：%.2lf%@ 查找完成:%@", @(strongSelf.files.count), process*100, @"%", [filePath componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startFind];
                }
            }];
        });
    } else {
        if([[GeneralConfig shareInstance] readSettionWithKey:@"900"]) {
            [LogMsgTool updateMsg:[NSString stringWithFormat:@"查找完成!\n"] tag:[self className] toTextView:self.msgTextView];
            if(self.unusedImports.count > 0) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"共找到%@个可能有问题的import\n%@", @(self.unusedImports.count), self.unusedImports] tag:[self className] toTextView:self.msgTextView];
            } else {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"没有找到有问题的import!\n"] tag:[self className] toTextView:self.msgTextView];
            }
        }
    }
}

-(void)findUnusedImport:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    if([filePath rangeOfString:@".m"].length > 0) {
        completion(NO, @"");
    } else if([filePath rangeOfString:@".h"].length > 0) {
        NSData *fileHData = [[NSData alloc] initWithContentsOfFile:filePath];
        NSString *stringH = [[NSString alloc] initWithData:fileHData encoding:NSUTF8StringEncoding];
        __block NSMutableArray *arrH = [[NSMutableArray alloc] initWithArray:[stringH componentsSeparatedByString:@"\n"]];
        NSData *fileMData = [[NSData alloc] initWithContentsOfFile:[filePath stringByReplacingOccurrencesOfString:@".h" withString:@".m"]];
        NSString *stringM = [[NSString alloc] initWithData:fileMData encoding:NSUTF8StringEncoding];
        __block NSMutableArray *arrM = [[NSMutableArray alloc] initWithArray:[stringM componentsSeparatedByString:@"\n"]];
        if(stringM.length == 0) {
            arrM = [NSMutableArray array];
        }
        NSString *string = [NSString stringWithFormat:@"%@\n%@", stringH, stringM];
        
        if(string.length > 0) {
            if([[GeneralConfig shareInstance] readSettionWithKey:@"900"]) {
                AnalyzeCodeModel *model = [self findCodeModelWithClassName:[[filePath componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject];
                BOOL isIgnoreClass = [self isIgnoreClasses:model.className];
                if(isIgnoreClass) {
                    completion(YES, @"");
                    return;
                }
                [model.importFiles enumerateObjectsUsingBlock:^(NSString *  _Nonnull importFilePath, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *importClass = @"";
                    if([importFilePath rangeOfString:@"/"].length > 0) {
                        importClass = [importFilePath componentsSeparatedByString:@"/"].lastObject;
                        importClass = [importClass componentsSeparatedByString:@"."].firstObject;
                    } else if([importFilePath rangeOfString:@"."].length > 0) {
                        importClass = [importFilePath componentsSeparatedByString:@"."].firstObject;
                    }
                    __block BOOL isUsing = NO;
                    if([importClass isEqual:model.className]) {
                        isUsing = YES;
                    } else {
                        if([string rangeOfString:[NSString stringWithFormat:@"%@ ", importClass]].length > 0 ||
                           [string rangeOfString:[NSString stringWithFormat:@"%@*", importClass]].length > 0 ||
                           [string rangeOfString:[NSString stringWithFormat:@": %@", importClass]].length > 0 ) {
                            isUsing = YES;
                        } else {
                            AnalyzeCodeModel *meditorModel = [self findCodeModelWithClassName:importClass];
                            NSMutableArray *classes = [NSMutableArray arrayWithArray:meditorModel.classMethods];
                            [classes addObjectsFromArray:meditorModel.instanceMethods];
                            [classes addObjectsFromArray:meditorModel.publicMethods];
                            [classes enumerateObjectsUsingBlock:^(NSString * _Nonnull methodName, NSUInteger idx, BOOL * _Nonnull st) {
                                if([methodName rangeOfString:@";"].length > 0) {
                                    NSString *tmpMethodName = @"";
                                    if([methodName rangeOfString:@")"].length > 0 && [methodName rangeOfString:@":"].length > 0) {
                                        NSInteger start = [methodName rangeOfString:@")"].location;
                                        NSInteger len = [methodName rangeOfString:@":"].location - start - 1;
                                        tmpMethodName = [methodName substringWithRange:NSMakeRange(start+1, len)];
                                    } else {
                                        tmpMethodName = [[methodName componentsSeparatedByString:@")"].lastObject componentsSeparatedByString:@";"].firstObject;
                                    }
                                    tmpMethodName = [NSString stringWithFormat:@" %@:", tmpMethodName];
                                    if([string rangeOfString:tmpMethodName].length > 0) {
                                        isUsing = YES;
                                        *st = true;
                                    }
                                }
                            }];
                            if(!isUsing) {
                                [meditorModel.properties enumerateObjectsUsingBlock:^(NSString *  _Nonnull lineCode, NSUInteger idx, BOOL * _Nonnull stop) {
                                    NSString *propertyName = [[lineCode componentsSeparatedByString:@" "].lastObject stringByReplacingOccurrencesOfString:@";" withString:@""];
                                    if([string rangeOfString:[NSString stringWithFormat:@".%@", propertyName]].length > 0) {
                                        isUsing = YES;
                                        *stop = true;
                                    }
                                }];
                            }
                        }
                        
                        if(!isUsing) {
                            BOOL isIgnore = [self isIgnoreClasses:importClass];
                            if(isIgnore) {
                                // 不用处理的类
                            } else {
                                NSString *formatString = [NSString stringWithFormat:@"%@:%@", model.fileRelatePath, importClass];
                                if(![self.unusedImports containsObject:formatString]) {
                                    [self.unusedImports addObject:[NSString stringWithFormat:@"%@:%@", model.fileRelatePath, importClass]];
                                }
                                if(arrH.count > 0) {
                                    NSMutableArray *mArrH = [NSMutableArray new];
                                    for (int i = 0; i < arrH.count; i++) {
                                        NSString *lineCode = arrH[i];
                                        if([lineCode rangeOfString:@"#import"].length > 0 && [lineCode rangeOfString:importClass].length > 0) {
                                            
                                        } else {
                                            [mArrH addObject:lineCode];
                                        }
                                    }
                                    arrH = [mArrH mutableCopy];
                                }
                                if(arrM.count > 0) {
                                    NSMutableArray *mArrM = [NSMutableArray new];
                                    for (int i = 0; i < arrM.count; i++) {
                                        NSString *lineCode = arrM[i];
                                        if([lineCode rangeOfString:@"#import"].length > 0 && [lineCode rangeOfString:importClass].length > 0) {
                                            
                                        } else {
                                            [mArrM addObject:lineCode];
                                        }
                                    }
                                    arrM = [mArrM mutableCopy];
                                }
                            }
                        } else {
                            NSLog(@"%@:%@", model.className, importClass);
                        }
                    }
                }];
                if(arrH.count > 0) {
                    NSData *dataH = [[arrH componentsJoinedByString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
                    if(dataH) {
                        [NSFileManager writeData:dataH toFile:[NSString stringWithFormat:@"%@", filePath] finish:^(BOOL isSuc, NSString * _Nullable msg) {
                            
                        }];
                    }
                }
                
                if(arrM.count > 0) {
                    NSData *dataM = [[arrM componentsJoinedByString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
                    if(dataM) {
                        [NSFileManager writeData:dataM toFile:[NSString stringWithFormat:@"%@", [filePath stringByReplacingOccurrencesOfString:@".h" withString:@".m"]] finish:^(BOOL isSuc, NSString * _Nullable msg) {
                            
                        }];
                    }
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion(YES, @"");
                });
            }
        } else {
            completion(NO, @"");
        }
        
    } else {
        completion(NO, @"");
    }
}

-(BOOL)isIgnoreClasses:(NSString *)className {
    NSSet *ignoreClasses = [[NSSet alloc] initWithArray:@[
        @"UIKit",
        @"CoreLocation",
        @"Foundation",
        @"MapKit",
        @"CoreText",
        @"runtime",
        @"Photos",
        @"OSAtomic",
        @"utsname",
        @"AVKit",
        @"AVFoundation",
        @"message",
        @"NSObjCRuntime",
        @"REmptyDataView",
        @"RMSession",
        @"MJRefresh",
        @"Somo",
        @"RAutoCommunityBaseModel",
        @"RACommunityPreloadProvider",
        @"RACVideoPlayerAdapter",
        @"RIB_Utilities",
        @"RIB_IconManager",
        @"RIB_VideoData+Internal",
        @"RIB_ImageCache+Internal",
        @"RIB_WebImageMediator",
        @"RCTransCodeConfiguration",
        @"RCommunityShareService",
        @"AFNetworkReachabilityManager",
        @"BMKSearchComponent",
        @"YYKit"
    ]];
    if(className == nil ||
       className.length == 0 ||
       [[className lowercaseString] rangeOfString:@"header"].length > 0 ||
       [[className lowercaseString] rangeOfString:@"protocol"].length > 0 ||
       [[className lowercaseString] rangeOfString:@"delegate"].length > 0 ||
       [[className lowercaseString] rangeOfString:@"lottie"].length > 0 ||
       [[className lowercaseString] rangeOfString:@"common"].length > 0 ||
       [ignoreClasses containsObject:className]) {
        return YES;
    } else {
        return NO;
    }
}

-(AnalyzeCodeModel *)findCodeModelWithClassName:(NSString *)className {
    NSString *tmpClassName = [NSString stringWithFormat:@"%@", className];
    if([tmpClassName rangeOfString:@"."].length > 0) {
        tmpClassName = [tmpClassName componentsSeparatedByString:@"."].firstObject;
    }
    __block AnalyzeCodeModel *resultModel = nil;
    [self.fileModels enumerateObjectsUsingBlock:^(AnalyzeCodeModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if([model.className isEqual:tmpClassName]) {
            resultModel = model;
            *stop = YES;
        }
    }];
    return resultModel;
}

/// MARK: lazy

- (NSMutableArray *)fileModels {
    if(_fileModels == nil) {
        _fileModels = [[NSMutableArray alloc] init];
    }
    return _fileModels;
}

- (AnalyzeCode *)analyzeCode {
    if(_analyzeCode == nil) {
        _analyzeCode = [[AnalyzeCode alloc] init];
    }
    return _analyzeCode;
}

- (NSMutableArray *)subClassPathes {
    if(_subClassPathes == nil) {
        _subClassPathes = [[NSMutableArray alloc] init];
    }
    return _subClassPathes;
}

- (NSMutableArray *)unusedImports {
    if(_unusedImports == nil) {
        _unusedImports = [[NSMutableArray alloc] init];
    }
    return _unusedImports;
}


@end
