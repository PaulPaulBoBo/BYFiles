//
//  AnalyzeCode.m
//  BYFiles
//
//  Created by Liu on 2022/10/19.
//

#import "AnalyzeCode.h"

@interface AnalyzeCode ()

@property (nonatomic, strong) NSMutableArray<AnalyzeCodeModel *> *fileModels;
@property (nonatomic, strong) NSMutableSet<NSString *> *connectionModules;
@property (nonatomic, strong) NSMutableSet<NSString *> *connectionRModules;

@end

@implementation AnalyzeCode

-(void)start {
//    [self expectPodsFiles];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf startAnalyze];
    });
}

- (void)startAnalyze {
    if(self.files.count > 0 && IsRunning == NO) {
        IsRunning = YES;
        NSString *path = self.files.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始读取 %@", path] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf analyzeCode:path completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"读取完成 %@", path] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.files.count > 0) {
                    [strongSelf.files removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.files.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"读取完成  当前进度：%.2lf%@ %@", process*100, @"%", [path componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startAnalyze];
                }
            }];
        });
    } else {
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"读取完成！ %@", self.path] tag:[self className] toTextView:self.msgTextView];
        [self analyzeAllCode];
    }
}

-(void)loadHFilesInfoInPath:(NSArray *)files completion:(void(^)(NSArray<AnalyzeCodeModel *> *arr))completion {
    [self.fileModels removeAllObjects];
    self.files = [NSMutableArray arrayWithArray:files];
    self.fileCount = files.count;
    [self startLoadHCompletion:completion];
}

-(void)startLoadHCompletion:(void(^)(NSArray<AnalyzeCodeModel *> *arr))completion {
    if(self.files.count > 0 && IsRunning == NO) {
        IsRunning = YES;
        NSString *path = self.files.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始读取 %@", path] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf analyzeCode:path completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"读取完成 %@", path] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.files.count > 0) {
                    [strongSelf.files removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.files.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"%@ 当前进度：%.2lf%@ 读取完成:%@", @(strongSelf.files.count), process*100, @"%", [path componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startLoadHCompletion:completion];
                }
            }];
        });
    } else {
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"读取完成！"] tag:[self className] toTextView:self.msgTextView];
        if(completion) {
            completion([self.fileModels mutableCopy]);
        }
    }
}

-(void)analyzeAllCode {
    // 分析import引用关系
    if([[GeneralConfig shareInstance] readSettionWithKey:@"400"]) {
        __weak typeof(self) weakSelf = self;
        [self startLoadHCompletion:^(NSArray<AnalyzeCodeModel *> *arr) {
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.fileModels enumerateObjectsUsingBlock:^(AnalyzeCodeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj.importFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull objIM, NSUInteger idxIM, BOOL * _Nonnull stop) {
                    if([objIM rangeOfString:@"<"].length > 0 && [objIM rangeOfString:@"/"].length > 0) {
                        NSString *moduleName = [[objIM componentsSeparatedByString:@"<"].lastObject componentsSeparatedByString:@"/"].firstObject;
                        if([moduleName hasPrefix:@"R"]) {
                            [strongSelf.connectionRModules addObject:[NSString stringWithFormat:@"%@", moduleName]];
                        } else {
                            [strongSelf.connectionModules addObject:[NSString stringWithFormat:@"%@", moduleName]];
                        }
                    }
                }];
            }];
        }];
        NSLog(@"%@ %@", self.connectionModules, self.connectionRModules);
    }
    // 分析组件依赖关系
    if([[GeneralConfig shareInstance] readSettionWithKey:@"401"]) {
        
    }
    // 分析方法
    if([[GeneralConfig shareInstance] readSettionWithKey:@"402"]) {
        
    }
    // 分析继承关系
    if([[GeneralConfig shareInstance] readSettionWithKey:@"403"]) {
        NSMutableArray *rootArr = [NSMutableArray new];
        NSMutableArray *subArr = [NSMutableArray new];
        for (int i = 0; i < self.fileModels.count; i++) {
            AnalyzeCodeModel *model = self.fileModels[i];
            if([model.parentName hasPrefix:@"UI"] || [model.parentName hasPrefix:@"NS"]) {
                [rootArr addObject:model];
            } else {
                [subArr addObject:model];
            }
        }
        
        for (int i = 0; i < subArr.count; i++) {
            AnalyzeCodeModel *model = subArr[i];
            AnalyzeCodeModel *parentModel = nil;
            int i = 0;
            for (; i < rootArr.count; i++) {
                AnalyzeCodeModel *obj = rootArr[i];
                if(![obj.className isEqual:model.className] && [model.parentName isEqual:obj.className]) {
                    parentModel = obj;
                    break;
                }
            }
            if(parentModel) {
                model.level = model.level+1;
                if(![self containModel:model inArr:parentModel.subClasses]) {
                    [parentModel.subClasses addObject:model];
                    [rootArr replaceObjectAtIndex:i withObject:parentModel];
                }
            }
        }
        NSMutableArray *results = [NSMutableArray new];
        for (int i = 0; i < rootArr.count; i++) {
            AnalyzeCodeModel *model = rootArr[i];
            if(model.subClasses.count > 0 && [model.className hasPrefix:@"R"]) {
                [results addObject:model];
            }
        }
        NSString *msg = [self formatFileModels:results];
        NSString *outputPath = [LogMsgTool singleMDLogMsg:msg tag:[self className]];
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"导出文件完成！路径：%@", outputPath] tag:[self className] toTextView:self.msgTextView];
    }
    // 分析引用关系
    if([[GeneralConfig shareInstance] readSettionWithKey:@"404"]) {
        
    }
    
}

-(BOOL)containModel:(AnalyzeCodeModel *)model inArr:(NSArray *)arr {
    if(arr.count == 0) {
        return NO;
    }
    for (AnalyzeCodeModel *obj in arr) {
        if([model.className isEqual:obj.className]) {
            return YES;
        }
    }
    return NO;
}

-(AnalyzeCodeModel *)findParentModel:(AnalyzeCodeModel *)subModel inArr:(NSArray *)arr {
    AnalyzeCodeModel *resultModel = nil;
    for (AnalyzeCodeModel *model in arr) {
        if(![subModel.className isEqual:model.classMethods] && [subModel.parentName isEqual:model.className]) {
            resultModel = model;
            break;
        }
    }
    return resultModel;
}

-(NSString *)formatFileModels:(NSArray *)arr {
    NSMutableString *msg = [NSMutableString stringWithFormat:@"# %@", [self.path componentsSeparatedByString:@"/"].lastObject];
    for (AnalyzeCodeModel *model in arr) {
        [msg appendString:model.description];
    }
    return msg;
}

- (void)createFileModel:(NSMutableArray *)arr fileName:(NSString *)fileName filePath:(NSString *)filePath {
    AnalyzeCodeModel * model = [self readInfo:arr];
    model.filePath = filePath;
    model.fileRelatePath = [filePath stringByReplacingOccurrencesOfString:@"/Users/liu/Code/RAuto/Assembly" withString:@"~"];
    model.fileName = fileName;
    NSString *className = [fileName componentsSeparatedByString:@"."].firstObject;
    if(![className isEqual:model.className]) {
        model.className = className;
    }
    if([filePath rangeOfString:@"Pods/"].length) {
        model.moduleName = [[filePath componentsSeparatedByString:@"Pods/"].lastObject componentsSeparatedByString:@"/"].firstObject;
    } else {
        if([filePath rangeOfString:@"/Users/liu/Code/RAuto/Assembly/"].length > 0) {
            model.moduleName = [[filePath stringByReplacingOccurrencesOfString:@"/Users/liu/Code/RAuto/Assembly/" withString:@""] componentsSeparatedByString:@"/"].firstObject;
        } else if([filePath rangeOfString:@"/Users/liu/Code/projects/"].length > 0) {
            model.moduleName = [[filePath stringByReplacingOccurrencesOfString:@"/Users/liu/Code/projects/" withString:@""] componentsSeparatedByString:@"/"].firstObject;
        } else {
            model.moduleName = @"";
        }
    }
    if([model.moduleName isEqual:@"Headers"]) {
        model.moduleName = @"";
    }
    if(model.className && model.className.length > 0) {
        [self.fileModels addObject:model];
    }
}

- (AnalyzeCodeModel *)combineImpletionFileModel:(NSMutableArray *)arr interfaceModel:(AnalyzeCodeModel *)interfaceModel {
    AnalyzeCodeModel *impletionModel = [self readInfo:arr];
    if(impletionModel.properties && impletionModel.properties.count > 0) {
        [interfaceModel.properties addObjectsFromArray:impletionModel.properties];
    }
    
    if(impletionModel.protocols && impletionModel.protocols.count > 0) {
        [interfaceModel.protocols addObjectsFromArray:impletionModel.protocols];
    }
    
    if(impletionModel.instanceMethods && impletionModel.instanceMethods.count > 0) {
        [interfaceModel.instanceMethods addObjectsFromArray:impletionModel.instanceMethods];
    }
    
    if(impletionModel.classMethods && impletionModel.classMethods.count > 0) {
        [interfaceModel.classMethods addObjectsFromArray:impletionModel.classMethods];
    }
    
    if(impletionModel.subClasses && impletionModel.subClasses.count > 0) {
        [interfaceModel.subClasses addObjectsFromArray:impletionModel.subClasses];
    }
    
    if(impletionModel.enums && impletionModel.enums.count > 0) {
        [interfaceModel.enums addObjectsFromArray:impletionModel.enums];
    }
    
    if(impletionModel.importFiles && impletionModel.importFiles.count > 0) {
        [interfaceModel.importFiles addObjectsFromArray:impletionModel.importFiles];
    }
    return interfaceModel;
}

-(void)analyzeCode:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    if([filePath rangeOfString:@"Pods/Headers"].length > 0) {
        completion(NO, @"");
        return;
    }
    if([filePath rangeOfString:@"RNewsDetailsViewController"].length > 0) {
        NSLog(@"");
    }
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString *string = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    if(string.length > 0) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@"\n"]];
        // 读取所有文件信息
        NSString *fileName = [filePath componentsSeparatedByString:@"/"].lastObject;
        if([fileName rangeOfString:@".h"].length > 0 || [fileName rangeOfString:@".m"].length > 0) {
            NSDictionary *existDic = [self isExistInterfaceFile:fileName fileModels:self.fileModels];
            NSNumber *index = existDic[@"index"];
            AnalyzeCodeModel *model = existDic[@"model"];
            if(index && model) {
                AnalyzeCodeModel *combineModel = [self combineImpletionFileModel:arr interfaceModel:model];
                [self.fileModels replaceObjectAtIndex:index.integerValue withObject:combineModel];
            } else {
                [self createFileModel:arr fileName:fileName filePath:filePath];
            }
        }
        completion(YES, @"");
    } else {
        completion(NO, @"");
    }
}

-(NSDictionary *)isExistInterfaceFile:(NSString *)fileName fileModels:(NSArray<AnalyzeCodeModel *> *)fileModels {
    __block NSMutableDictionary *existDic = [NSMutableDictionary new];
    [fileModels enumerateObjectsUsingBlock:^(AnalyzeCodeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([[fileName componentsSeparatedByString:@"."].firstObject isEqual:[obj.fileName componentsSeparatedByString:@"."].firstObject]) {
            [existDic setValue:@(idx) forKey:@"index"];
            [existDic setValue:obj forKey:@"model"];
            *stop = YES;
        }
    }];
    return existDic;
}

/// MARK: private

-(AnalyzeCodeModel *)readInfo:(NSArray *)arr {
    AnalyzeCodeModel *model = [AnalyzeCodeModel new];
    for (int i = 0; i < arr.count-1; i++) {
        NSString *lineCode = arr[i];
        if([lineCode hasPrefix:@"@interface"]) {
            // 类
            lineCode = [lineCode stringByReplacingOccurrencesOfString:@"@interface" withString:@""];
            lineCode = [self.loadFileTools removeWhiteSpacePreSufInString:lineCode];
            lineCode = [self.loadFileTools removeSpecStr:@" " inString:lineCode];
            if([lineCode rangeOfString:@":"].length > 0) {
                model.className = [lineCode componentsSeparatedByString:@":"].firstObject;
                NSString *parentName = [lineCode componentsSeparatedByString:@":"].lastObject;
                if([parentName rangeOfString:@"<"].length > 0) {
                    parentName = [parentName componentsSeparatedByString:@"<"].firstObject;
                }
                model.parentName = parentName;
            }
        }
        if([lineCode hasPrefix:@"@property"]) {
            // 属性
            if(model.properties == nil) {
                model.properties = [NSMutableArray new];
            }
            if([lineCode rangeOfString:@"*"].length > 0) {
                lineCode = [lineCode componentsSeparatedByString:@"*"].lastObject;
                [model.properties addObject:[lineCode componentsSeparatedByString:@";"].firstObject];
            }
        }
        if([lineCode hasPrefix:@"-"]) {
            // 实例方法
            if(model.instanceMethods == nil) {
                model.instanceMethods = [NSMutableArray new];
            }
            lineCode = [lineCode stringByReplacingOccurrencesOfString:@"- " withString:@"-"];
            if([lineCode rangeOfString:@"{"].length > 0) {
                lineCode = [self.loadFileTools removeSpecStr:@"{" inString:lineCode];
            }
            lineCode = [self.loadFileTools removeWhiteSpacePreSufInString:lineCode];
            [model.instanceMethods addObject:lineCode];
            
            if([lineCode rangeOfString:@";"].length > 0) {
                [model.publicMethods addObject:[NSString stringWithFormat:@"%@", lineCode]];
            }
        }
        if([lineCode hasPrefix:@"+"]) {
            // 类方法
            if(model.classMethods == nil) {
                model.classMethods = [NSMutableArray new];
            }
            if([lineCode rangeOfString:@"{"].length > 0) {
                lineCode = [self.loadFileTools removeSpecStr:@"{" inString:lineCode];
            }
            lineCode = [self.loadFileTools removeWhiteSpacePreSufInString:lineCode];
            [model.classMethods addObject:lineCode];
            
            if([lineCode rangeOfString:@";"].length > 0) {
                [model.publicMethods addObject:[NSString stringWithFormat:@"%@", lineCode]];
            }
        }
        if([lineCode hasPrefix:@"#import"]) {
            // 引入文件
            if(model.importFiles == nil) {
                model.importFiles = [NSMutableArray new];
            }
            lineCode = [lineCode stringByReplacingOccurrencesOfString:@"#import" withString:@""];
            lineCode = [lineCode stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            lineCode = [self.loadFileTools removeSpecStr:@" " inString:lineCode];
            [model.importFiles addObject:lineCode];
        }
        
        if([lineCode hasPrefix:@"@import"]) {
            // 引入文件
            if(model.importFiles == nil) {
                model.importFiles = [NSMutableArray new];
            }
            lineCode = [lineCode stringByReplacingOccurrencesOfString:@"@import" withString:@""];
            lineCode = [self.loadFileTools removeSpecStr:@" " inString:lineCode];
            [model.importFiles addObject:lineCode];
        }
        
        if([lineCode hasPrefix:@"@protocol"]) {
            // 协议定义
            if(model.protocols == nil) {
                model.protocols = [NSMutableArray new];
            }
            [model.protocols addObject:lineCode];
        }
        if([lineCode hasPrefix:@"//  Created by "]) {
            // 创建人+日期
            lineCode = [lineCode stringByReplacingOccurrencesOfString:@"//  Created by " withString:@""];
            lineCode = [lineCode stringByReplacingOccurrencesOfString:@"." withString:@""];
            lineCode = [lineCode stringByReplacingOccurrencesOfString:@"on " withString:@""];
            model.authorName = [lineCode componentsSeparatedByString:@" "].firstObject;
            model.createTime = [lineCode componentsSeparatedByString:@" "].lastObject;
        }
    }
    return model;
}

- (NSMutableArray *)fileModels {
    if(_fileModels == nil) {
        _fileModels = [[NSMutableArray alloc] init];
    }
    return _fileModels;
}

- (NSMutableSet *)connectionModules {
    if(_connectionModules == nil) {
        _connectionModules = [[NSMutableSet alloc] init];
    }
    return _connectionModules;
}

- (NSMutableSet *)connectionRModules {
    if(_connectionRModules == nil) {
        _connectionRModules = [[NSMutableSet alloc] init];
    }
    return _connectionRModules;
}

@end
