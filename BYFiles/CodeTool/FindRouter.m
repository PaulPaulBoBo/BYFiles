//
//  FindRouter.m
//  BYFiles
//
//  Created by Liu on 2023/1/5.
//

#import "FindRouter.h"

@interface FindRouter ()

@property (nonatomic, strong) NSMutableArray *fileModels;
@property (nonatomic, strong) NSMutableSet *routerFiles;

@end

@implementation FindRouter

/// 启动入口
-(void)start {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if(self.files.count > 0) {
            for (int i = 0; i < self.files.count; i++) {
                NSString *path = self.files[i];
                if([path rangeOfString:@"Target_"].length == 0) {
                    [self.files removeObjectAtIndex:i];
                }
            }
            self.fileCount = self.files.count;
            [strongSelf startFindRouter];
        }
    });
}

-(void)startFindRouter {
    if(self.files.count > 0 && IsRunning == NO) {
        __weak typeof(self) weakSelf = self;
        
        IsRunning = YES;
        NSString *path = self.files.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始查找 %@", path] tag:[self className] toTextView:self.msgTextView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf findRouter:[path componentsSeparatedByString:@"."].firstObject completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"查找完成 %@", path] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.files.count > 0) {
                    [strongSelf.files removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.files.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"%@ 当前进度：%.2lf%@ 查找完成:%@", @(strongSelf.files.count), process*100, @"%", [path componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startFindRouter];
                }
            }];
        });
    } else {
        NSArray *arr = [self.routerFiles allObjects];
        NSString *str = @"";
        for (int i = 0; i < arr.count; i++) {
            NSDictionary *dic = arr[i];
            NSString *tmpStr = [NSString stringWithFormat:@"%@&+&%@^+^", dic[@"comment"], dic[@"router"]];
            if(str.length == 0) {
                str = tmpStr;
            } else {
                str = [NSString stringWithFormat:@"%@%@", str, tmpStr];
            }
        }
        [LogMsgTool updateMsg:str tag:[self className] toTextView:self.msgTextView];
        [LogMsgTool updateMsg:@"查找完成!" tag:[self className] toTextView:self.msgTextView];
    }
}

-(void)findRouter:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    NSData *fileDataH = [[NSData alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@.h", filePath]];
    NSString *string = [[NSString alloc] initWithData:fileDataH encoding:NSUTF8StringEncoding];
    if(string.length > 0) {
        NSString *firstRouter = [[filePath componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"_R"].lastObject;
        if([[GeneralConfig shareInstance] readSettionWithKey:@"800"]) {
            NSArray *lines = [string componentsSeparatedByString:@"\n"];
            __weak typeof(self) weakSelf = self;
            [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull code, NSUInteger idx, BOOL * _Nonnull stop) {
                __weak typeof(weakSelf) strongSelf = weakSelf;
                if([code rangeOfString:@"Action_"].length > 0 && [code hasPrefix:@"-"] && [code rangeOfString:@":"].length > 0 && [code rangeOfString:@"///"].length == 0) {
                    NSString *secondRouter = [[code componentsSeparatedByString:@"Action_"].lastObject componentsSeparatedByString:@":"].firstObject;
                    if(secondRouter && secondRouter.length > 0) {
                        NSString *commentStr = @"";
                        for (NSUInteger i = idx-1; i > 0; i--) {
                            NSString *commentLine = lines[i];
                            if([commentLine rangeOfString:@"Action_"].length > 0 || [commentLine rangeOfString:@"@interface"].length > 0 || [commentLine isEqual:@"}"] || [commentLine isEqual:@""]) {
                                break;
                            } else {
                                if(commentStr.length > 0) {
                                    commentStr = [NSString stringWithFormat:@"%@\n%@", commentLine, commentStr];
                                } else {
                                    commentStr = commentLine;
                                }
                            }
                        }
                        NSString *newRouterPath = [NSString stringWithFormat:@"/%@/%@/R", firstRouter, secondRouter];
                        if(![self isContainsRouter:newRouterPath]) {
                            [strongSelf.routerFiles addObject:@{@"router":newRouterPath, @"comment":commentStr}];
                        }
                    }
                }
            }];
        }
        completion(YES, @"");
    } else {
        completion(NO, @"");
    }
}

-(BOOL)isContainsRouter:(NSString *)routerPath {
    if(routerPath == nil || routerPath.length == 0) {
        return NO;
    }
    BOOL isContains = NO;
    NSArray *arr = [self.routerFiles allObjects];
    for (int i = 0; i < arr.count; i++) {
        NSDictionary *dic = arr[i];
        NSString *tmpRouterPath = dic[@"router"];
        if([tmpRouterPath isEqual:routerPath]) {
            isContains = YES;
            break;
        }
    }
    return isContains;
}

- (NSMutableSet *)routerFiles {
    if(_routerFiles == nil) {
        _routerFiles = [[NSMutableSet alloc] init];
    }
    return _routerFiles;
}

@end
