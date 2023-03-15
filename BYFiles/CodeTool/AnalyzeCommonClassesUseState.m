//
//  AnalyzeCommonClassesUseState.m
//  BYFiles
//
//  Created by Liu on 2023/1/11.
//

#import "AnalyzeCommonClassesUseState.h"
#import "AnalyzeCode.h"

@interface AnalyzeCommonClassesUseState()

@property (nonatomic, strong) AnalyzeCode *analyzeCode;

@property (nonatomic, strong) NSMutableArray *fileModels;
@property (nonatomic, strong) NSMutableArray *subClassPathes;
@property (nonatomic, strong) NSMutableArray *subClassModels;
@property (nonatomic, strong) NSMutableArray *useSameCommonClasses;
@property (nonatomic, strong) NSMutableArray *unUseCommonClasses;
@property (nonatomic, strong) NSMutableArray *unUseBySelfClasses;

@end

@implementation AnalyzeCommonClassesUseState

/// 配置目标类路径 必须在调用start方法前
/// - Parameter orderClassesPath: 目标类路径
-(void)configOrderClassPaths:(NSArray * __nonnull)orderClassesPaths {
    [self bindUI];
    [self.subClassPathes removeAllObjects];
    [self.subClassModels removeAllObjects];
    [self.subClassPathes addObjectsFromArray:orderClassesPaths];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [self.analyzeCode loadHFilesInfoInPath:strongSelf.subClassPathes completion:^(NSArray<AnalyzeCodeModel *> * _Nonnull arr) {
            [strongSelf.subClassModels addObjectsFromArray:arr];
        }];
    });
}

/// 选择完依赖的文件夹主动调用，开始分析所有相关的类文件
-(void)analyzeFolder {
    [self bindUI];
    [self.fileModels removeAllObjects];
    [self.unUseBySelfClasses removeAllObjects];
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
            [strongSelf.unUseBySelfClasses addObjectsFromArray:[strongSelf sortClassesImportTree:strongSelf.fileModels]];
            [strongSelf analyzeImportRelation];
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
    self.fileCount = self.subClassPathes.count;
    [self startAnalyze];
}

-(void)bindUI {
    self.analyzeCode.msgTextView = self.msgTextView;
    self.analyzeCode.stateLabel = self.stateLabel;
    self.analyzeCode.progressView = self.progressView;
}

-(void)startAnalyze {
    if(self.subClassPathes.count > 0 && IsRunning == NO) {
        IsRunning = YES;
        NSString *filePath = self.subClassPathes.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始分析 %@", filePath] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf analyzeCommonClasses:filePath completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"分析完成 %@", filePath] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.subClassPathes.count > 0) {
                    [strongSelf.subClassPathes removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.subClassPathes.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"%@ 当前进度：%.2lf%@ 分析完成:%@", @(strongSelf.subClassPathes.count), process*100, @"%", [filePath componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startAnalyze];
                }
            }];
        });
    } else {
        if([[GeneralConfig shareInstance] readSettionWithKey:@"1000"]) {
            // 仅有一个业务模块在用的类
            NSMutableArray *mArr = [NSMutableArray new];
            NSMutableArray *singleModuleMArr = [NSMutableArray new];
            NSMutableArray *classNamesMArr = [NSMutableArray new];
            for (int i = 0; i < self.useSameCommonClasses.count; i++) {
                AnalyzeCodeModel *commonModel = self.useSameCommonClasses[i][@"commonClass"];
                NSArray *items = self.useSameCommonClasses[i][@"useSameCommonClassModels"];
                NSArray *modules = self.useSameCommonClasses[i][@"modules"];
                NSMutableArray *subMarr = [NSMutableArray new];
                for (int j = 0; j < items.count; j++) {
                    AnalyzeCodeModel *subItemModel = items[j];
                    [subMarr addObject:subItemModel.className];
                }
                NSDictionary *dic = @{@"commonClassName":commonModel.className, @"useSameCommonClassNames":subMarr, @"modules":modules};
                if(modules.count == 1) {
                    [singleModuleMArr addObject:dic];
                } else {
                    [mArr addObject:dic];
                }
                [classNamesMArr addObject:commonModel.className];
            }
            
            [LogMsgTool updateMsg:[NSString stringWithFormat:@"分析完成!\n仅有一个业务模块在用的类：\n%@", singleModuleMArr] tag:[self className] toTextView:self.msgTextView];
            
            // common组件中未被引用的类
            NSMutableSet *mSet = [[NSMutableSet alloc] init];
            for (int i = 0; i < classNamesMArr.count; i++) {
                AnalyzeCodeModel *commonModel = [self findCodeModelWithClassName:classNamesMArr[i]];
                commonModel = [self findConnectClasses:commonModel index:0];
                [mSet addObjectsFromArray:commonModel.importFiles];
            }
            classNamesMArr = [NSMutableArray arrayWithArray:[mSet allObjects]];
            for (int i = 0; i < self.fileModels.count; i++) {
                AnalyzeCodeModel *commonModel = self.fileModels[i];
                BOOL isCon = NO;
                for (int j = 0; j < classNamesMArr.count; j++) {
                    NSString *tmpClassName = classNamesMArr[j];
                    if([tmpClassName rangeOfString:@"<"].length > 0) {
                        tmpClassName = [[tmpClassName componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject;
                    } else if([tmpClassName rangeOfString:@"."].length > 0) {
                        tmpClassName = [tmpClassName componentsSeparatedByString:@"."].firstObject;
                    }
                    if([commonModel.className isEqual:tmpClassName]) {
                        isCon = YES;
                        break;
                    }
                }
                if(isCon == NO) {
                    [self.unUseCommonClasses addObject:commonModel.className];
                }
            }
            [LogMsgTool updateMsg:[NSString stringWithFormat:@"common组件中未被引用的类：\n%@", self.unUseCommonClasses] tag:[self className] toTextView:self.msgTextView];
            
            // 仅被社区组件引用的类
            NSMutableArray *onlyUseByCommunityClasses = [NSMutableArray new];
            for (int i = 0; i < singleModuleMArr.count; i++) {
                NSString *commonClassName = singleModuleMArr[i][@"commonClassName"];
                if(![self.unUseBySelfClasses containsObject:commonClassName]) {
                    [onlyUseByCommunityClasses addObject:singleModuleMArr[i]];
                }
            }
            [LogMsgTool updateMsg:[NSString stringWithFormat:@"仅被社区组件引用的类：\n%@", onlyUseByCommunityClasses] tag:[self className] toTextView:self.msgTextView];
            
            // 多个业务模块在用的类
            NSArray *srotedMarr = [self sortUsedClass:[mArr copy]];
            NSMutableArray *sortedClassNameMarr = [NSMutableArray new];
            for (int i = 0; i < srotedMarr.count; i++) {
                [sortedClassNameMarr addObject:srotedMarr[i][@"commonClassName"]];
            }
            [LogMsgTool updateMsg:[NSString stringWithFormat:@"多个业务模块在用的类：\n%@", srotedMarr] tag:[self className] toTextView:self.msgTextView];
            [LogMsgTool updateMsg:[NSString stringWithFormat:@"多个业务模块在用的类排序结果如下：\n%@", sortedClassNameMarr] tag:[self className] toTextView:self.msgTextView];
            
        }
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


-(void)analyzeCommonClasses:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    if([filePath rangeOfString:@".m"].length > 0) {
        completion(NO, @"");
    } else if([filePath rangeOfString:@".h"].length > 0) {
        if([[GeneralConfig shareInstance] readSettionWithKey:@"1000"]) {
            // 遍历所有待处理的类model
            for (int i = 0; i < self.subClassModels.count; i++) {
                AnalyzeCodeModel *subClassModel = self.subClassModels[i];
                // 检查所有引用的文件是否属于common组件
                for (int j = 0; j < subClassModel.importFiles.count; j++) {
                    NSString *importClasses = subClassModel.importFiles[j];
                    AnalyzeCodeModel *importClassesModel = [self findCodeModelWithClassName:importClasses];
                    if(importClassesModel && [importClassesModel.moduleName isEqualToString:@"RCommunityCommonModule"]) {
                        // 找到引用RCommunityCommonModule相关的类
                        AnalyzeCodeModel *commonClassModel = [self findCodeModelWithClassName:importClasses];
                        if(commonClassModel) {
                            [subClassModel.importCommonFiles addObject:commonClassModel];
                        }
                    }
                }
                NSSet *importCommonFilesSet = [[NSSet alloc] initWithArray:subClassModel.importCommonFiles];
                subClassModel.importCommonFiles = [NSMutableArray arrayWithArray:[importCommonFilesSet allObjects]];
                // 将属于common组件的model存储到importCommonFiles并更新到subClassModels
                [self.subClassModels replaceObjectAtIndex:i withObject:subClassModel];
            }
            // 重新遍历所有待检查类model
            for (int i = 0; i < self.subClassModels.count; i++) {
                AnalyzeCodeModel *subClassModel = self.subClassModels[i];
                // 遍历所有被业务代码引用的common组件类
                for (int j = 0; j < subClassModel.importCommonFiles.count; j++) {
                    AnalyzeCodeModel *tmpModel = subClassModel.importCommonFiles[j];
                    // 找出引用过common组件中相关类的所有业务类及其子模块名称
                    NSArray *useSameCommonClassModels = [self fetchSameCommonModel:tmpModel];
                    if(useSameCommonClassModels && useSameCommonClassModels.count > 0) {
                        if(![self isContaintSubClassModel:tmpModel]) {
                            NSMutableArray *subModules = [NSMutableArray new];
                            for (int k = 0; k < useSameCommonClassModels.count; k++) {
                                AnalyzeCodeModel *communityModel = useSameCommonClassModels[k];
                                if([communityModel.filePath rangeOfString:@"RCommunityModule/"].length > 0) {
                                    NSString *subModuleName = [[communityModel.filePath componentsSeparatedByString:@"Classes/"].lastObject componentsSeparatedByString:@"/"].firstObject;
                                    [subModules addObject:subModuleName];
                                } else {
                                    [subModules addObject:communityModel.moduleName];
                                }
                            }
                            NSSet *subModuleSets = [[NSSet alloc] initWithArray:subModules];
                            [self.useSameCommonClasses addObject:@{@"commonClass":tmpModel, @"useSameCommonClassModels":useSameCommonClassModels, @"modules":[subModuleSets allObjects]}];
                        }
                    }
                }
            }
            completion(YES, @"");
        } else {
            completion(NO, @"");
        }
    } else {
        completion(NO, @"");
    }
}

-(NSMutableArray *)sortClassesImportTree:(NSArray *)classModels {
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:classModels];
    for (int i = 0; i < mArr.count; i++) {
        AnalyzeCodeModel *model = mArr[i];
        for (int j = 0; j < classModels.count; j++) {
            AnalyzeCodeModel *innerModel = classModels[j];
            __block BOOL isContains = NO;
            [innerModel.importFiles enumerateObjectsUsingBlock:^(NSString *  _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
                if([className rangeOfString:model.className].length > 0) {
                    isContains = YES;
                    *stop = YES;
                }
            }];
            if((![innerModel.className isEqual:model.className]) && isContains) {
                [mArr removeObjectAtIndex:i];
                i--;
                break;
            }
        }
    }
    return [mArr copy];
}

-(NSArray *)sortUsedClass:(NSArray *)usedClasses {
    NSMutableArray *mArr = [NSMutableArray new];
    for (int i = 0; i < usedClasses.count; i++) {
        NSDictionary *dic = usedClasses[i];
        NSArray *arr = dic[@"useSameCommonClassNames"];
        if(mArr.count == 0) {
            [mArr addObject:dic];
        } else {
            for (int j = 0; j < mArr.count; j++) {
                NSDictionary *innerDic = mArr[j];
                NSArray *innerArr = innerDic[@"useSameCommonClassNames"];
                if(arr.count > innerArr.count) {
                    [mArr insertObject:dic atIndex:j];
                    break;
                }
                if(j == mArr.count - 1) {
                    [mArr addObject:dic];
                    j++;
                }
            }
        }
    }
    return [mArr copy];
}


-(BOOL)isContaintSubClassModel:(AnalyzeCodeModel *)model {
    if(model == nil || model.className.length == 0) {
        return YES;
    }
    if(self.useSameCommonClasses.count == 0) {
        return NO;
    }
    BOOL isContaint = NO;
    for (int i = 0; i < self.useSameCommonClasses.count; i++) {
        AnalyzeCodeModel *tmpModel = self.useSameCommonClasses[i][@"commonClass"];
        if([tmpModel.className isEqual:model.className]) {
            isContaint = YES;
            break;
        }
    }
    return isContaint;
}

// 找出某个被业务代码引用的common组件类，都被那些业务引用的类引用
-(NSArray<AnalyzeCodeModel *> *)fetchSameCommonModel:(AnalyzeCodeModel *)model {
    NSMutableArray *mArr = [NSMutableArray new];
    NSMutableArray *models = [NSMutableArray arrayWithArray:self.subClassModels];
    [models addObjectsFromArray:self.fileModels];
    for (int i = 0; i < models.count; i++) {
        AnalyzeCodeModel *subClassModel = models[i];
        if(![subClassModel.className isEqual:model.className]) {
            for (int j = 0; j < subClassModel.importFiles.count; j++) {
                NSString *importClassName = subClassModel.importFiles[j];
                if([importClassName rangeOfString:model.className].length > 0) {
                    [mArr addObject:subClassModel];
                    break;
                }
            }
        }
    }
    return [mArr copy];
}

-(AnalyzeCodeModel *)findCodeModelWithClassName:(NSString *)className {
    NSString *tmpClassName = [NSString stringWithFormat:@"%@", className];
    if([tmpClassName rangeOfString:@"<"].length > 0) {
        tmpClassName = [[tmpClassName componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject;
    }
    if([tmpClassName rangeOfString:@"."].length > 0) {
        tmpClassName = [tmpClassName componentsSeparatedByString:@"."].firstObject;
    }
    __block AnalyzeCodeModel *resultModel = nil;
    NSMutableArray *models = [NSMutableArray arrayWithArray:self.subClassModels];
    [models addObjectsFromArray:self.fileModels];
    [models enumerateObjectsUsingBlock:^(AnalyzeCodeModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if([model.className isEqual:tmpClassName]) {
            resultModel = model;
            *stop = YES;
        }
    }];
    return resultModel;
}

-(void)analyzeImportRelation {
    // 根节点 self.unUseBySelfClasses
    // 递归遍历所有根节点引用的类
    for (int i = 0; i < self.unUseBySelfClasses.count; i++) {
        AnalyzeCodeModel *rootModel = self.unUseBySelfClasses[i];
        [self findConnectCommonClasses:rootModel];
    }
    NSString *formatString = @"";
    NSMutableArray *mArr = [NSMutableArray new];
    NSMutableArray *nameMArr = [NSMutableArray new];
    for (int i = 0; i < self.unUseBySelfClasses.count; i++) {
        AnalyzeCodeModel *rootModel = self.unUseBySelfClasses[i];
        NSString *msg = [self formatMarkdown:rootModel markdownString:[NSString stringWithFormat:@"# %@", rootModel.className] level:1];
        formatString = [NSString stringWithFormat:@"%@\n#%@", formatString, msg];
        [mArr addObject:msg];
        [nameMArr addObject:rootModel.className];
    }
    [LogMsgTool singleMDLogMsg:formatString tag:[self className]];
    [self logImportRelation:mArr formatStringNames:nameMArr];
}

-(void)logImportRelation:(NSMutableArray *)formatStringArr formatStringNames:(NSMutableArray *)formatStringNames {
    NSString *msg = formatStringArr.lastObject;
    __weak typeof(self) weakSelf = self;
    [LogMsgTool singleMDLogMsg:msg tag:[self className] fileName:formatStringNames.lastObject finish:^(BOOL isSuc, NSString * _Nullable msg) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [formatStringArr removeLastObject];
        [formatStringNames removeLastObject];
        [strongSelf logImportRelation:formatStringArr formatStringNames:formatStringNames];
    }];
}

-(NSString *)formatMarkdown:(AnalyzeCodeModel *)model markdownString:(NSString *)mdStr level:(NSUInteger)level {
    if(model.importCommonFiles.count == 0) {
        return mdStr;
    }
    // 创建Markdown格式化空格
    NSString *preSpeace = @"";
    if(level > 2) {
        for (int i = 0; i < level-2; i++) {
            preSpeace = [NSString stringWithFormat:@"%@  ", preSpeace];
        }
    }
    
    NSString *preShapeSpeace = @"";
    for (int i = 0; i < level+1; i++) {
        if(level <= 2) {
            preShapeSpeace = [NSString stringWithFormat:@"%@#", preShapeSpeace];
        } else {
            preShapeSpeace = @"-";
            break;
        }
    }
    
    // 遍历引用的common class model
    for (int i = 0; i < model.importCommonFiles.count; i++) {
        AnalyzeCodeModel *commonClassModel = model.importCommonFiles[i];
        // 格式化输出
        mdStr = [NSString stringWithFormat:@"%@\n%@%@ %@", mdStr, preSpeace, preShapeSpeace, commonClassModel.className];
        if(commonClassModel.importCommonFiles.count > 0) {
            mdStr = [self formatMarkdown:commonClassModel markdownString:mdStr level:level+1];
        }
    }
    
    return mdStr;
}

-(void)findConnectCommonClasses:(AnalyzeCodeModel *)model {
    // 找出根节点引用的 common组件的 className
    NSMutableArray *commonImportClasses = [NSMutableArray array];
    for (int i = 0; i < model.importFiles.count; i++) {
        NSString *className = model.importFiles[i];
        if([className rangeOfString:@"<"].length > 0) {
            className = @"";
        } else if([className rangeOfString:@"."].length > 0) {
            className = [className componentsSeparatedByString:@"."].firstObject;
        }
        if(className && className.length > 0 && ![model.className isEqualToString:className]) {
            [commonImportClasses addObject:className];
        }
    }
    
    // 没有引用common组件的类时，到达该分支的最末端的叶子节点
    if(commonImportClasses.count == 0) {
        return;
    }
    
    // 遍历查询叶子节点的model，存储在importCommonFiles数组中
    for (int i = 0; i < commonImportClasses.count; i++) {
        NSString *className = commonImportClasses[i];
        AnalyzeCodeModel *nextLevelCommonModel = [self findCodeModelWithClassName:className];
        if([model.className isEqualToString:@"RCommunityPostLayoutModel"] ||
           [model.className isEqualToString:@"RCommunityPostContentDetailsAtTextTool"] ||
           [model.className isEqualToString:@"RCommunityCommentInputView+RInputTool"] ||
           [model.className rangeOfString:@"RIB_"].length > 0) {
            // 存在import循环引用
            NSLog(@"skip");
        } else {
            if(nextLevelCommonModel && [nextLevelCommonModel.moduleName isEqual:@"RCommunityCommonModule"] && ![nextLevelCommonModel.className isEqual:model.className]) {
                [model.importCommonFiles addObject:nextLevelCommonModel];
                NSSet *importCommonFilesSet = [[NSSet alloc] initWithArray:model.importCommonFiles];
                model.importCommonFiles = [NSMutableArray arrayWithArray:[importCommonFilesSet allObjects]];
                NSLog(@"nextLevelCommonModel.className:%@", nextLevelCommonModel.className);
                [self findConnectCommonClasses:nextLevelCommonModel];
            }
        }
    }
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

- (NSMutableArray *)subClassModels {
    if(_subClassModels == nil) {
        _subClassModels = [[NSMutableArray alloc] init];
    }
    return _subClassModels;
}

- (NSMutableArray *)useSameCommonClasses {
    if(_useSameCommonClasses == nil) {
        _useSameCommonClasses = [[NSMutableArray alloc] init];
    }
    return _useSameCommonClasses;
}

- (NSMutableArray *)unUseCommonClasses {
    if(_unUseCommonClasses == nil) {
        _unUseCommonClasses = [[NSMutableArray alloc] init];
    }
    return _unUseCommonClasses;
}

- (NSMutableArray *)unUseBySelfClasses {
    if(_unUseBySelfClasses == nil) {
        _unUseBySelfClasses = [[NSMutableArray alloc] init];
    }
    return _unUseBySelfClasses;
}

@end
