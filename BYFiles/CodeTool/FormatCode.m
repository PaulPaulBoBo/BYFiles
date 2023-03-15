//
//  FormatCode.m
//  BYFiles
//
//  Created by Liu on 2021/11/29.
//

#import "FormatCode.h"

@implementation FormatCode

/// 启动入口
-(void)start {
    [self expectPodsFiles];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf startFormat];
    });
}

-(void)startFormat {
    if(self.files.count > 0 && IsRunning == NO) {
        IsRunning = YES;
        NSString *path = self.files.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始格式化 %@", path] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf formatComment:path completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"格式化完成 %@", path] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.files.count > 0) {
                    [strongSelf.files removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.files.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"当前进度：%.2lf%@ 格式化完成:%@", process*100, @"%", [path componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startFormat];
                }
            }];
        });
    } else {
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"格式化完成！ %@", self.path] tag:[self className] toTextView:self.msgTextView];
    }
}

-(void)formatComment:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString *string = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    if(string.length > 0) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@"\n"]];
        
        // 格式化方法
        if([[GeneralConfig shareInstance] readSettionWithKey:@"300"]) {
            [self formatMethodComment:arr];
        }
        // 删除连续多空行
        if([[GeneralConfig shareInstance] readSettionWithKey:@"301"]) {
            [self formatMultWhiteLineComment:arr];
        }
        // @end前加换行
        if([[GeneralConfig shareInstance] readSettionWithKey:@"302"]) {
            [self formatEndLineComment:arr];
        }
        // #pragma mark 改为 /// MARK:
        if([[GeneralConfig shareInstance] readSettionWithKey:@"303"]) {
            [self formatMarkLineComment:arr];
        }
        // "typedef NS_ENUM ("转"typedef NS_ENUM("
        if([[GeneralConfig shareInstance] readSettionWithKey:@"304"]) {
            [self formatEnumLineComment:arr];
        }
        // property注释格式化
        if([[GeneralConfig shareInstance] readSettionWithKey:@"305"]) {
            [self formatPropertyComment:arr];
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

/// 格式化方法
/// @param arr 代码行数组
-(void)formatMethodComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
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
            while ([code rangeOfString:@") "].length > 0) {
                code = [self.loadFileTools replaceSpecStr:@") " withString:@")" inString:code];
            }
            code = [self.loadFileTools removeWhiteSpacePreSufInString:code];
            
            if ([code hasSuffix:@"{"]) {
                if(![[code substringWithRange:NSMakeRange(code.length-2, 1)] isEqual:@" "]) {
                    code = [code stringByReplacingCharactersInRange:NSMakeRange(code.length-1, 1) withString:@" {"];
                }
            } else {
                if(i+1 < arr.count) {
                    NSString *nextCode = arr[i+1];
                    nextCode = [self.loadFileTools removeWhiteSpacePreSufInString:nextCode];
                    if([nextCode isEqual:@"{"]) {
                        code = [NSString stringWithFormat:@"%@ {", code];
                        [arr removeObjectAtIndex:i+1];
                    }
                }
            }
            
            if ([code hasPrefix:@"-("]) {
                code = [code stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"- ("];
            }
            
            if ([code hasPrefix:@"+("]) {
                code = [code stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"+ ("];
            }
            
            [arr replaceObjectAtIndex:i withObject:code];
        }
    }
}

/// 删除连续多空行
/// @param arr 代码行数组
-(void)formatMultWhiteLineComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        code = [self.loadFileTools removeWhiteSpacePreSufInString:code];
        if([code isEqual:@""]) {
            if(i+1 < arr.count) {
                NSString *nextCode = arr[i+1];
                nextCode = [self.loadFileTools removeWhiteSpacePreSufInString:nextCode];
                if([nextCode isEqual:@""]) {
                    [arr removeObjectAtIndex:i+1];
                    i--;
                }
            }
        }
    }
}

/// @end前加换行
/// @param arr 代码行数组
-(void)formatEndLineComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if([code isEqual:@"@end"]) {
            NSString *preLineCode = arr[i-1];
            if(![preLineCode isEqual:@""]) {
                [arr insertObject:@"" atIndex:i];
                i++;
            }
        }
    }
}

/// #pragma mark 改为 /// MARK:
/// @param arr 代码行数组
-(void)formatMarkLineComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if([code hasPrefix:@"#pragma mark"]) {
            NSString *commentStr = [code componentsSeparatedByString:@"#pragma mark"].lastObject;
            if(commentStr.length > 0) {
                commentStr = [self.loadFileTools removeSpecStr:@"-" inString:commentStr];
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                while([self.loadFileTools hasMuchWhiteSpace:commentStr]) {
                    NSRange range = [self.loadFileTools loadWhiteSpaceRangeInString:commentStr];
                    commentStr = [commentStr stringByReplacingCharactersInRange:range withString:@""];
                }
                [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// MARK: %@", commentStr]];;
                if(i+1 < arr.count-1) {
                    NSString *nextLineCode = arr[i+1];
                    if(![nextLineCode isEqual:@""]) {
                        [arr insertObject:@"" atIndex:i+1];
                        i++;
                    }
                }
            }
        }
    }
}

/// "typedef NS_ENUM ("转"typedef NS_ENUM("
/// @param arr 代码行数组
-(void)formatEnumLineComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if([code hasPrefix:@"typedef NS_ENUM ("]) {
            code = [code stringByReplacingOccurrencesOfString:@"typedef NS_ENUM (" withString:@"typedef NS_ENUM("];
            [arr replaceObjectAtIndex:i withObject:code];
        }
    }
}

/// property注释格式化
/// @param arr 代码行数组
-(void)formatPropertyComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        if([code hasPrefix:@"@property"]) {
            if(i+1 > arr.count-1 || i+2 > arr.count-1 || i+3 > arr.count-1 || [code hasPrefix:@"@end"]) {
                break;
            }
            NSString *nextCode = arr[i+1];
            NSString *thirdCode = arr[i+2];
            NSString *forthCode = arr[i+3];
            if(nextCode.length == 0 && [thirdCode hasPrefix:@"///"] && [forthCode hasPrefix:@"@property"]) {
                [arr removeObjectAtIndex:i+1];
                i++;
                continue;
            } else {
                i += 2;
                continue;
            }
        } else if([code hasPrefix:@"@interface"] && ![code hasSuffix:@"{"]) {
            if(i+1 > arr.count-1 || [code hasPrefix:@"@end"]) {
                break;
            }
            NSString *nextCode = arr[i+1];
            if(nextCode.length > 0) {
                [arr insertObject:@"" atIndex:i+1];
                i++;
            }
        }
    }
}

/// else 格式统一
/// @param arr 代码行数组
-(void)formatElseCode:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *code = arr[i];
        code = [self.loadFileTools removeWhiteSpacePreSufInString:code];
        if([code hasPrefix:@"else"] && [code hasSuffix:@"{"]) {
            NSString *preLineCode = arr[i-1];
            preLineCode = [self.loadFileTools removeWhiteSpacePreSufInString:preLineCode];
            [arr replaceObjectAtIndex:i withObject:code];
        }
    }
}

@end
