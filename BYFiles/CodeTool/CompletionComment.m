//
//  CompletionComment.m
//  BYFiles
//
//  Created by Liu on 2021/11/29.
//

#import "CompletionComment.h"

@implementation CompletionComment

/// 启动入口
-(void)start {
    [self expectPodsFiles];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf startCompletion];
    });
    
}

-(void)startCompletion {
    if(self.files.count > 0 && IsRunning == NO) {
        IsRunning = YES;
        NSString *path = self.files.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始补全 %@", path] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf completionComment:path completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"补全完成 %@", path] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.files.count > 0) {
                    [strongSelf.files removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.files.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"当前进度：%.2lf%@ 补全完成:%@", process*100, @"%", [path componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startCompletion];
                }
            }];
        });
    } else {
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"补全完成！ %@", self.path] tag:[self className] toTextView:self.msgTextView];
        IsRunning = NO;
    }
}

/// 补全文件注释的主方法，负责读取文件并以此调用不同的补全方法处理注释缺失问题，最后写回到源文件
/// @param filePath 要转换的所有文件外层目录
/// @param completion 完成回调 用于递归执行转换操作
-(void)completionComment:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    if([filePath hasSuffix:@".m"]) {
        if(completion) {
            completion(YES, @"忽略.m文件");
        }
        return;
    }
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString *string = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    if(string.length > 0) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@"\n"]];
        
        // 补全Static注释模板
        if([[GeneralConfig shareInstance] readSettionWithKey:@"200"]) {
            [self completionStaticComment:arr];
        }
        // 补全协议注释模板
        if([[GeneralConfig shareInstance] readSettionWithKey:@"201"]) {
            [self completionProtocolComment:arr];
        }
        // 补全类注释模板
        if([[GeneralConfig shareInstance] readSettionWithKey:@"202"]) {
            [self completionInterfaceComment:arr];
        }
        // 补全属性注释模板
        if([[GeneralConfig shareInstance] readSettionWithKey:@"203"]) {
            [self completionPropertyComment:arr];
        }
        // 补全方法注释模板
        if([[GeneralConfig shareInstance] readSettionWithKey:@"204"]) {
            [self completionMethodComment:arr];
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
    }
}

/// 补全static注释
/// @param arr 代码行数组
-(void)completionStaticComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if([code hasPrefix:@"static"]) {
            if(i == 0) {
                continue;
            }
            NSString *preLineStr = arr[i-1];
            NSString *newLine = @"\n";
            if([preLineStr isEqual:@""]) {
                newLine = @"";
            }
            if(![preLineStr hasPrefix:SpecialCode_3]) {
                [arr insertObject:[NSString stringWithFormat:@"%@%@", newLine, StaticTemplateCode] atIndex:i];
                i++;
            }
        }
    }
}

/// 补全协议注释
/// @param arr 代码行数组
-(void)completionProtocolComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if([code hasPrefix:@"@protocol"]) {
            if(i == 0) {
                continue;
            }
            NSString *preLineStr = arr[i-1];
            NSString *newLine = @"\n";
            if([preLineStr isEqual:@""]) {
                newLine = @"";
            }
            if(![preLineStr hasPrefix:SpecialCode_3]) {
                [arr insertObject:[NSString stringWithFormat:@"%@%@", newLine, StaticTemplateCode] atIndex:i];
                i++;
            }
        }
    }
}

/// 补全类注释
/// @param arr 代码行数组
-(void)completionInterfaceComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if([code hasPrefix:@"@interface"]) {
            if(i == 0) {
                continue;
            }
            NSString *preLineStr = arr[i-1];
            NSString *newLine = @"\n";
            if([preLineStr isEqual:@""]) {
                newLine = @"";
            }
            if(![preLineStr hasPrefix:SpecialCode_3]) {
                [arr insertObject:[NSString stringWithFormat:@"%@%@", newLine, InterfaceTemplateCode] atIndex:i];
                i++;
            }
        }
    }
}

/// 补全属性注释
/// @param arr 代码行数组
-(void)completionPropertyComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if([code hasPrefix:@"@property"]) {
            if(i == 0) {
                continue;
            }
            NSString *preLineStr = arr[i-1];
            NSString *newLine = @"\n";
            if([preLineStr isEqual:@""]) {
                newLine = @"";
            }
            if(![preLineStr hasPrefix:SpecialCode_3]) {
                [arr insertObject:[NSString stringWithFormat:@"%@%@", newLine, PropertyTemplateCode] atIndex:i];
                i++;
            }
        }
    }
}

/// 补全方法注释
/// @param arr 代码行数组
-(void)completionMethodComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if(i > 0) {
            NSString *preLineCode = arr[i-1];
            if([preLineCode hasPrefix:@"//"] || [preLineCode hasPrefix:@"/*"]) {
                continue;
            }
        }
        if([code rangeOfString:@"//"].length > 0) {
            continue;
        }
        if([code hasPrefix:@"-("] || [code hasPrefix:@"- ("] || [code hasPrefix:@"+("] || [code hasPrefix:@"+ ("]) {
            if(i == 0) {
                continue;
            }
            while([self.loadFileTools hasMuchWhiteSpace:code]) {
                code = [code stringByReplacingCharactersInRange:[self.loadFileTools loadWhiteSpaceRangeInString:code] withString:@" "];
            }
            while ([code rangeOfString:@": ("].length > 0) {
                code = [self.loadFileTools replaceSpecStr:@": (" withString:@":(" inString:code];
            }
            
            NSString *originComment = @"";
            if([code rangeOfString:@"/*"].length > 0) {
                originComment = [code componentsSeparatedByString:@"/*"].lastObject;
                originComment = [self.loadFileTools removeSpecStr:@"*/" inString:originComment];
                originComment = [self.loadFileTools removeWhiteSpacePreSufInString:originComment];
                if([originComment hasPrefix:@"*"]) {
                    originComment = [originComment stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                originComment = [self.loadFileTools removeWhiteSpacePreSufInString:originComment];
                if([originComment hasPrefix:@"<"] && [originComment rangeOfString:@"<#"].length == 0 && [originComment rangeOfString:@">"].length == 0) {
                    originComment = [originComment stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                originComment = [self.loadFileTools removeWhiteSpacePreSufInString:originComment];
            }
            
            if([code rangeOfString:@"//"].length > 0) {
                originComment = [code componentsSeparatedByString:@"//"].lastObject;
                originComment = [self.loadFileTools removeSpecStr:@"*/" inString:originComment];
                originComment = [self.loadFileTools removeWhiteSpacePreSufInString:originComment];
                if([originComment hasPrefix:@"/"]) {
                    originComment = [originComment stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                originComment = [self.loadFileTools removeWhiteSpacePreSufInString:originComment];
            }
            
            NSString *preLineStr = arr[i-1];
            NSString *newLine = @"\n";
            if([preLineStr isEqual:@""]) {
                newLine = @"";
            }
            if(![preLineStr hasPrefix:SpecialCode_3]) {
                NSArray *params = [self.loadFileTools loadMethodParam:code arr:arr line:i];
                if(params.count == 0) {
                    // 无参数方法
                    if(originComment.length == 0) {
                        [arr insertObject:[NSString stringWithFormat:@"%@%@", newLine, MethodTemplateCode] atIndex:i];
                    } else {
                        [arr insertObject:[NSString stringWithFormat:@"%@/// %@", newLine, originComment] atIndex:i];
                    }
                    i++;
                } else {
                    // 多参数方法，参数个数大于等于1都需要使用动态模板
                    NSMutableString *multLineCommentTemplateStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@%@", newLine, MethodTemplateCode]];
                    if(originComment.length > 0) {
                        multLineCommentTemplateStr = [NSMutableString stringWithFormat:@"%@/// %@", newLine, originComment];
                    }
                    for (int i = 0; i < params.count; i++) {
                        NSString *paramName = params[i];
                        if(paramName && paramName.length > 0) {
                            [multLineCommentTemplateStr appendFormat:@"\n/// @param %@ <#%@ description%@%@", paramName, paramName, @"#", @">"];
                        }
                    }
                    if(multLineCommentTemplateStr && multLineCommentTemplateStr.length > 0) {
                        [arr insertObject:multLineCommentTemplateStr atIndex:i];
                        i++;
                    }
                }
            }
        }
    }
}

@end
