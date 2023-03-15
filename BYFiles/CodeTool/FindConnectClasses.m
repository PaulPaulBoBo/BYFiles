//
//  FindConnectClasses.m
//  BYFiles
//
//  Created by Liu on 2022/12/20.
//

#import "FindConnectClasses.h"
#import "AnalyzeCode.h"

@interface FindConnectClasses()

@property (nonatomic, strong) AnalyzeCode *analyzeCode;

@property (nonatomic, strong) NSMutableArray *fileModels;
@property (nonatomic, strong) NSMutableSet *importFilePaths;
@property (nonatomic, strong) NSMutableArray *subClassPathes;
@property (nonatomic, strong) NSMutableArray *unusedImports;

@end

@implementation FindConnectClasses

/// 配置目标类路径 必须在调用start方法前
/// - Parameter orderClassesPath: 目标类路径
-(void)configOrderClassPaths:(NSArray * __nonnull)orderClassesPaths {
    [self bindUI];
    [self.importFilePaths removeAllObjects];
    [self.subClassPathes removeAllObjects];
//    [self.importFilePaths addObjectsFromArray:orderClassesPaths];
//    [self.subClassPathes addObjectsFromArray:orderClassesPaths];
}

/// 选择完依赖的文件夹主动调用，开始分析所有相关的类文件
-(void)analyzeFolder {
    [self bindUI];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [self.analyzeCode loadHFilesInfoInPath:strongSelf.files completion:^(NSArray<AnalyzeCodeModel *> * _Nonnull arr) {
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
    NSMutableArray *usedClassPaths = [NSMutableArray new];
    NSString *usedClass = @"";
    NSArray *usedClasses = [usedClass componentsSeparatedByString:@","];
    for (int i = 0; i < usedClasses.count; i++) {
        AnalyzeCodeModel *model = [self findCodeModelWithClassName:usedClasses[i]];
        [usedClassPaths addObject:model.filePath];
    }
    
    self.subClassPathes = [NSMutableArray arrayWithArray:[usedClassPaths copy]];
    self.fileCount = self.subClassPathes.count;
    
    [self startFind];
}

-(void)bindUI {
    self.analyzeCode.msgTextView = self.msgTextView;
    self.analyzeCode.stateLabel = self.stateLabel;
    self.analyzeCode.progressView = self.progressView;
}

-(void)startFind {
    if(self.subClassPathes.count > 0 && IsRunning == NO) {
        
        IsRunning = YES;
        NSString *filePath = self.subClassPathes.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始查找 %@", filePath] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf findClasses:filePath completion:^(BOOL isSuc, NSString * _Nullable msg) {
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
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"查找完成!"] tag:[self className] toTextView:self.msgTextView];
        if([[GeneralConfig shareInstance] readSettionWithKey:@"700"]) {
            if(self.findCompletion) {
                NSMutableSet *tmppathSets = [NSMutableSet new];
                [self.importFilePaths enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                    NSArray *items = obj[@"connectClassName"];
                    for (int i = 0; i < items.count; i++) {
                        NSString *className = items[i];
                        NSString *filePrePath = [className componentsSeparatedByString:@"."].firstObject;
                        [tmppathSets addObject:[NSString stringWithFormat:@"%@.h", filePrePath]];
                        [tmppathSets addObject:[NSString stringWithFormat:@"%@.m", filePrePath]];
                    }
                }];
                self.findCompletion([tmppathSets allObjects]);
                
                NSMutableArray *importClassNames = [NSMutableArray new];
                [self.importFilePaths enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                    NSArray *items = obj[@"connectClassName"];
                    for (int i = 0; i < items.count; i++) {
                        NSString *className = items[i];
                        if(className) {
                            [importClassNames addObject:className];
                        }
                    }
                }];
                NSString *unusedClass = @"";
                NSArray *unusedClasses = [unusedClass componentsSeparatedByString:@","];
                NSMutableArray *unusedFiles = [NSMutableArray new];
                __block BOOL isContains = NO;
                for (int i = 0; i < unusedClasses.count; i++) {
                    NSString *file = unusedClasses[i];
                    isContains = NO;
                    [importClassNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *filePrePath = [obj componentsSeparatedByString:@"."].firstObject;
                        if([filePrePath rangeOfString:file].length > 0){
                            isContains = YES;
                            *stop = YES;
                        }
                    }];
                    [importClassNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *filePrePath = [obj componentsSeparatedByString:@"."].firstObject;
                        if([filePrePath rangeOfString:file].length > 0){
                            isContains = YES;
                            *stop = YES;
                        }
                    }];
                    if(isContains == NO) {
                        [unusedFiles addObject:file];
                    }
                }
                NSLog(@"%@", unusedFiles);
            }
        }
    }
}

-(void)findClasses:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    if([filePath rangeOfString:@".h"].length > 0) {
        if([[GeneralConfig shareInstance] readSettionWithKey:@"700"]) {
            NSString *fileClassName = [[filePath componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject;
            AnalyzeCodeModel *fileClassModel = [self findCodeModelWithClassName:fileClassName];
            fileClassModel = [self findConnectClasses:fileClassModel index:0];
            [self.importFilePaths addObject:@{@"className":fileClassName, @"connectClassName":fileClassModel.importFiles}];;
            completion(YES, @"");
        } else {
            completion(NO, @"");
        }
    } else {
        completion(NO, @"");
    }
}

-(AnalyzeCodeModel *)findConnectClasses:(AnalyzeCodeModel *)model index:(NSInteger)index {
    if(index >= model.importFiles.count) {
        return model;
    }
    for (int i = 0; i < model.importFiles.count; i++) {
        NSString *importFileName = model.importFiles[i];
        AnalyzeCodeModel *tmpModel = [self findCodeModelWithClassName:importFileName];
        if(tmpModel && tmpModel.importFiles && ![tmpModel.className isEqual:model.className]) {
            for (int i = 0; i < tmpModel.importFiles.count; i++) {
                NSString *tmpClassName = tmpModel.importFiles[i];
                BOOL isContain = NO;
                for (int j = 0; j < model.importFiles.count; j++) {
                    NSString *originClassName = model.importFiles[j];
                    if([originClassName rangeOfString:tmpClassName].length > 0) {
                        isContain = YES;
                        break;
                    }
                }
                if(isContain == NO) {
                    [model.importFiles addObject:tmpClassName];
                }
            }
        }
    }
    
    NSSet *importFilesSet = [[NSSet alloc] initWithArray:model.importFiles];
    model.importFiles = [NSMutableArray arrayWithArray:[importFilesSet allObjects]];
    
    for (int i = 0; i < model.importFiles.count; i++) {
        NSString *tmpClassName = model.importFiles[i];
        if([tmpClassName rangeOfString:@"<"].length > 0) {
            [model.importFiles removeObjectAtIndex:i];
            i--;
        }
    }
    
    index++;
    return [self findConnectClasses:model index:index];
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

-(BOOL)isContainsImportFilePath:(NSString *)importFilePath inFiles:(NSArray *)files {
    if(importFilePath == nil || importFilePath.length == 0 || [importFilePath rangeOfString:@"<"].length > 0) {
        return NO;
    }
    NSString *tmpPath = [NSString stringWithFormat:@"%@", importFilePath];
    tmpPath = [self.loadFileTools removeWhiteSpacePreSufInString:tmpPath];
    tmpPath = [tmpPath componentsSeparatedByString:@"."].firstObject;
    __block BOOL isContains = NO;
    [files enumerateObjectsUsingBlock:^(AnalyzeCodeModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [[model.filePath componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject;
        if([name isEqual:tmpPath]) {
            isContains = YES;
            *stop = YES;
        }
    }];
    return isContains;
}

-(NSString *)findImportFilePath:(NSString *)importFilePath inFiles:(NSArray *)files {
    if(importFilePath == nil || importFilePath.length == 0) {
        return @"";
    }
    NSString *tmpPath = [NSString stringWithFormat:@"%@", importFilePath];
    if([tmpPath rangeOfString:@"/"].length > 0) {
        tmpPath = [tmpPath componentsSeparatedByString:@"/"].lastObject;
    }
    tmpPath = [self.loadFileTools removeWhiteSpacePreSufInString:tmpPath];
    tmpPath = [tmpPath componentsSeparatedByString:@"."].firstObject;
    __block NSString *resultPath = @"";
    [files enumerateObjectsUsingBlock:^(AnalyzeCodeModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [[model.filePath componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject;
        if([name isEqual:tmpPath]) {
            resultPath = model.filePath;
            *stop = YES;
        }
    }];
    return resultPath;
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

- (NSMutableSet *)importFilePaths {
    if(_importFilePaths == nil) {
        _importFilePaths = [[NSMutableSet alloc] init];
    }
    return _importFilePaths;
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
