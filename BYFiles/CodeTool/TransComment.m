//
//  TransComment.m
//  BYFiles
//
//  Created by Liu on 2021/11/29.
//

#import "TransComment.h"

@implementation TransComment

/// 启动入口
-(void)start {
    [self expectPodsFiles];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf startTrans];
    });
}

-(void)startTrans {
    if(self.files.count > 0 && IsRunning == NO) {
        IsRunning = YES;
        NSString *path = self.files.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始转换 %@", path] tag:[self className] toTextView:self.msgTextView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf transCodeComment:path completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"转换完成 %@", path] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.files.count > 0) {
                    [strongSelf.files removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.files.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"当前进度：%.2lf%@ 转换完成:%@", process*100, @"%", [path componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startTrans];
                }
            }];
        });
    } else {
        [LogMsgTool updateMsg:@"转换完成！" tag:[self className] toTextView:self.msgTextView];
        IsRunning = NO;
    }
}

// MARK: - 修复原有注释问题

/// 转换文件的主方法，负责读取文件并以此调用不同的修复方法处理注释问题，最后写回到源文件
/// @param filePath 要转换的所有文件外层目录
/// @param completion 完成回调 用于递归执行转换操作
-(void)transCodeComment:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString *string = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    if(string.length > 0) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@"\n"]];
        // 修复属性注释
        if([[GeneralConfig shareInstance] readSettionWithKey:@"100"]) {
            [self checkPropertyCommentWithLines:arr];
        }
        // 修复多行注释
        if([[GeneralConfig shareInstance] readSettionWithKey:@"101"]) {
            [self checkMutiLineCommentWithLines:arr];
        }
        // 修复interface文件注释
        if([[GeneralConfig shareInstance] readSettionWithKey:@"102"]) {
            [self checkInterfaceSingleLineCommentWithLines:arr];
        }
        // 修复枚举注释
        if([[GeneralConfig shareInstance] readSettionWithKey:@"103"]) {
            [self checkEnumCommentWithLines:arr];
        }
        // 修复方法参数注释
        if([[GeneralConfig shareInstance] readSettionWithKey:@"104"]) {
            [self checkParamCommentWithLines:arr];
        }
        // 修复方法注释，仅针对已有注释的方法，调整格式
        if([[GeneralConfig shareInstance] readSettionWithKey:@"105"]) {
            [self checkMethodCommentWithLines:arr];
        }
        // 修复缺少空格注释 warning：内部仅处理三斜杠开头缺少空格的注释
        if([[GeneralConfig shareInstance] readSettionWithKey:@"106"]) {
            [self checkMissWhiteSpaceCommentWithLines:arr];
        }
        // 修复多空格注释 warning：需最后处理，内部仅处理三斜杠开头的方法参数多空格注释
        if([[GeneralConfig shareInstance] readSettionWithKey:@"107"]) {
            [self checkMuchWhiteSpaceCommentWithLines:arr];
        }
        // 删除包含"FIXME #捡老鼠屎行动"的代码注释
        if([[GeneralConfig shareInstance] readSettionWithKey:@"108"]) {
            [self removeBadComment:arr];
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
        completion(NO, @"内容为空");
    }
}

/// 检查并修复属性的注释问题
/// @param arr 代码行数组
- (void)checkPropertyCommentWithLines:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *commentStr = arr[i];
        NSString *commentNextStr = arr[i+1];
        commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
        commentNextStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentNextStr];
        if([commentStr isEqual:@"/**/"]) {
            commentStr = @"///";
            [arr replaceObjectAtIndex:i withObject:commentStr];
        }
        if([commentStr hasPrefix:SpecialCode_3_Star] || [commentStr hasPrefix:SpecialCode_4]) {
            continue;
        }
        
        if([commentNextStr hasPrefix:@"@property"] || [commentNextStr hasPrefix:@"static"]) {
            // 当前行的下一行是"@property"或"@static"
            if([commentStr hasPrefix:@"/*"] && [commentStr hasSuffix:@"*/"]) {
                // 当前行有注释 "/* xxx */"、"/** xxx */"或"/**<xxx */"
                commentStr = [self.loadFileTools removeSpecStr:@"/*" inString:commentStr];
                commentStr = [self.loadFileTools removeSpecStr:@"*/" inString:commentStr];
                if([commentStr rangeOfString:@"<"].length > 0 && [commentStr rangeOfString:@"<#"].length == 0 && [commentStr rangeOfString:@">"].length == 0) {
                    commentStr = [self.loadFileTools removeSpecStr:@"<" inString:commentStr];
                }
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                if([commentStr hasPrefix:@"*"]) {
                    commentStr = [commentStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@", commentStr]];
            } else if([commentStr hasPrefix:@"//"]) {
                // 当前行有注释 "//"、"// "、"///"或"/// " 统一为"/// "
                commentStr = [commentStr componentsSeparatedByString:@"//"].lastObject;
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                if([commentStr hasPrefix:@"/"]) {
                    commentStr = [commentStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                if([commentStr rangeOfString:@"<"].length > 0 && [commentStr rangeOfString:@"<#"].length == 0 && [commentStr rangeOfString:@">"].length == 0) {
                    commentStr = [self.loadFileTools removeSpecStr:@"<" inString:commentStr];
                }
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@", commentStr]];
            } else {
                // 当前行没有注释不处理，交由补全方法处理
            }
        }
        
        if([commentStr hasPrefix:@"@property"] || [commentStr hasPrefix:@"static"]) {
            //当前行是"@property"或"@static"
            if([commentStr rangeOfString:@"//"].length > 0 && [commentStr rangeOfString:@"http:"].length == 0 && [commentStr rangeOfString:@"https:"].length == 0) {
                // 单行末尾有注释 "//"、"// "、"///"或"/// "
                NSArray *lineArr = [commentStr componentsSeparatedByString:@"//"];
                if(lineArr.count == 2) {
                    NSString *lineCode = lineArr.firstObject;
                    NSString *lineComment = lineArr.lastObject;
                    lineCode = [self.loadFileTools removeWhiteSpacePreSufInString:lineCode];
                    if([lineComment rangeOfString:@"<"].length > 0 && [lineComment rangeOfString:@"<#"].length == 0 && [lineComment rangeOfString:@">"].length == 0) {
                        lineComment = [self.loadFileTools removeSpecStr:@"<" inString:lineComment];
                    }
                    lineComment = [self.loadFileTools removeWhiteSpacePreSufInString:lineComment];
                    if([lineComment hasPrefix:@"/"]) {
                        lineComment = [lineComment substringFromIndex:1];
                    }
                    lineComment = [self.loadFileTools removeWhiteSpacePreSufInString:lineComment];
                    [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@\n%@", lineComment, lineCode]];
                }
            }
            
            if([commentStr rangeOfString:@"/*"].length > 0 && [commentStr rangeOfString:@"*/"].length > 0) {
                // 单行末尾有注释 "/* xxx */"、"/** xxx */"或"/**<xxx */"
                NSArray *lineArr = [commentStr componentsSeparatedByString:@"/*"];
                if(lineArr.count == 2) {
                    NSString *lineCode = lineArr.firstObject;
                    NSString *lineComment = lineArr.lastObject;
                    lineCode = [self.loadFileTools removeWhiteSpacePreSufInString:lineCode];
                    lineComment = [self.loadFileTools removeSpecStr:@"*/" inString:lineComment];
                    if([lineComment rangeOfString:@"<"].length > 0 && [lineComment rangeOfString:@"<#"].length == 0 && [lineComment rangeOfString:@">"].length == 0) {
                        lineComment = [self.loadFileTools removeSpecStr:@"<" inString:lineComment];
                    }
                    lineComment = [self.loadFileTools removeWhiteSpacePreSufInString:lineComment];
                    if([lineComment hasPrefix:@"*"]) {
                        lineComment = [lineComment stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                    }
                    if([lineComment hasPrefix:@" "]) {
                        lineComment = [self.loadFileTools removeWhiteSpacePreSufInString:lineComment];
                    }
                    [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@\n%@", lineComment, lineCode]];
                }
            }
            
        }
        
    }
}

/// 检查并修复多行注释的注释问题
/// @param arr 代码行数组
- (void)checkMutiLineCommentWithLines:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *commentStr = arr[i];
        NSString *commentNextStr = arr[i+1];
        commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
        commentNextStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentNextStr];
        if([commentStr hasPrefix:SpecialCode_3_Star] || [commentStr hasPrefix:SpecialCode_4]) {
            continue;
        }
        if(![commentStr hasPrefix:@"/**"] && [commentStr hasPrefix:@"/*"] && [commentNextStr hasPrefix:@"*"]) {
            [arr replaceObjectAtIndex:i withObject:@"/**"];
        }
        
        commentStr = arr[i];
        commentNextStr = arr[i+1];
        commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
        commentNextStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentNextStr];
        
        if([commentStr hasPrefix:@"/**"] && ![commentStr hasSuffix:@"*/"]) {
            NSString *mainComment = [commentStr componentsSeparatedByString:@"/**"].lastObject;
            mainComment = [self.loadFileTools removeWhiteSpacePreSufInString:mainComment];
            if(mainComment.length > 0) {
                [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@", mainComment]];
                i++;
            } else {
                [arr removeObjectAtIndex:i];
            }
            int j = i;
            for (; j < arr.count-1; j++) {
                commentNextStr = arr[j];
                commentNextStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentNextStr];
                if([commentNextStr isEqual:@"*/"] || [commentNextStr isEqual:@"**/"]) {
                    [arr removeObjectAtIndex:j];
                    break;
                } else {
                    commentNextStr = [self.loadFileTools removeSpecStr:@"*" inString:commentNextStr];
                    commentNextStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentNextStr];
                    if(commentNextStr.length == 0) {
                        [arr removeObjectAtIndex:j];
                        j--;
                    } else {
                        [arr replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"/// %@", commentNextStr]];
                    }
                }
            }
            i = j;
        }
    }
}

/// 检查并修复类的注释问题
/// @param arr 代码行数组
- (void)checkInterfaceSingleLineCommentWithLines:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *commentStr = arr[i];
        NSString *commentNextStr = arr[i+1];
        commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
        commentNextStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentNextStr];
        if([commentStr hasPrefix:SpecialCode_3_Star] || [commentStr hasPrefix:SpecialCode_4]) {
            continue;
        }
        if([commentNextStr hasPrefix:@"@interface"] || [commentNextStr hasPrefix:@"@protocol"]) {
            if([commentStr hasPrefix:@"/**"] && [commentStr hasSuffix:@"*/"]) {
                commentStr = [[commentStr componentsSeparatedByString:@"/**"].lastObject componentsSeparatedByString:@"*/"].firstObject;
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@", commentStr]];
            }
        }
    }
}

/// 检查并修复枚举的注释问题
/// @param arr 代码行数组
- (void)checkEnumCommentWithLines:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *commentStr = arr[i];
        commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
        if([commentStr hasPrefix:@"};"]) {
            continue;
        }
        if([commentStr hasPrefix:SpecialCode_3_Star] || [commentStr hasPrefix:SpecialCode_4]) {
            continue;
        }
        NSString *commentNextStr = arr[i+1];
        commentNextStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentNextStr];
        if([commentNextStr hasPrefix:@"typedef NS_ENUM"]) {
            int j = i+1;
            if([commentStr hasPrefix:@"///"]) {
                // "typedef NS_ENUM"前一行有三斜杠注释，但可能格式不规范，此处统一使用"/// "格式化
                commentStr = [commentStr componentsSeparatedByString:@"///"].lastObject;
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                commentStr = [NSString stringWithFormat:@"/// %@", commentStr];
                [arr replaceObjectAtIndex:i withObject:commentStr];
                j = i+2;
            }
            
            if([commentStr hasPrefix:@"/**"] && [commentStr hasSuffix:@"*/"]) {
                // "typedef NS_ENUM"前一行有"/** xxx */"注释，统一使用"/// "格式化
                commentStr = [commentStr componentsSeparatedByString:@"/**"].lastObject;
                commentStr = [self.loadFileTools removeSpecStr:@"*/" inString:commentStr];
                if([commentStr rangeOfString:@"<"].length > 0 && [commentStr rangeOfString:@"<#"].length == 0 && [commentStr rangeOfString:@">"].length == 0) {
                    commentStr = [self.loadFileTools removeSpecStr:@"<" inString:commentStr];
                }
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                commentStr = [NSString stringWithFormat:@"/// %@", commentStr];
                [arr replaceObjectAtIndex:i withObject:commentStr];
                j = i+2;
            }
            // 遍历枚举定义
            for (; j < arr.count-1; j++) {
                commentStr = arr[j];
                commentNextStr = arr[j+1];
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                if([commentStr isEqual:@"};"]) {
                    // 枚举遍历结束
                    i = j+1;
                    break;
                }
                commentStr = [self.loadFileTools removeSpecStr:@" " inString:commentStr];
                NSString *tmpStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                if([tmpStr hasPrefix:@"/**"] && [commentNextStr hasPrefix:@"    "] && ![commentNextStr hasPrefix:@"    /**"] && ![commentNextStr hasPrefix:@"    //"]) {
                    // 枚举行没有注释
                    if([tmpStr rangeOfString:@"/**"].length > 0 && [tmpStr rangeOfString:@"*/"].length > 0) {
                        // 枚举前一行有单行注释"/** xxx */",转为"/// "
                        commentStr = [commentStr stringByReplacingOccurrencesOfString:@"/**" withString:@""];
                        commentStr = [commentStr stringByReplacingOccurrencesOfString:@"*/" withString:@""];
                        if([commentStr rangeOfString:@"<"].length > 0 && [commentStr rangeOfString:@"<#"].length == 0 && [commentStr rangeOfString:@">"].length == 0) {
                            commentStr = [self.loadFileTools removeSpecStr:@"<" inString:commentStr];
                        }
                        commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                        [arr replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"    /// %@", commentStr]];
                        j++;
                    } else if([tmpStr hasPrefix:SpecialCode_3] || [tmpStr hasSuffix:@"//"]) {
                        // 枚举前一行有单行注释"//"、"///"、"// "或"/// "，转为"/// "
                        tmpStr = [tmpStr componentsSeparatedByString:@"//"].lastObject;
                        if([tmpStr rangeOfString:@"<"].length > 0 && [tmpStr rangeOfString:@"<#"].length == 0 && [tmpStr rangeOfString:@">"].length == 0) {
                            tmpStr = [self.loadFileTools removeSpecStr:@"<" inString:tmpStr];
                        }
                        if([tmpStr rangeOfString:@"/"].length > 0) {
                            tmpStr = [self.loadFileTools removeSpecStr:@"/" inString:tmpStr];
                        }
                        tmpStr = [self.loadFileTools removeWhiteSpacePreSufInString:tmpStr];
                        [arr replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"    /// %@", tmpStr]];
                        j++;
                    } else {
                        // 枚举前一行没有单行注释，此处不作处理，交由补全注释类处理
                    }
                } else {
                    // 枚举行有注释
                    if(![tmpStr hasPrefix:@"//"] && ![tmpStr hasPrefix:SpecialCode_3]) {
                        // 前一行没有注释
                        if([commentStr rangeOfString:@"//"].length > 0 && [commentStr rangeOfString:@"http:"].length == 0 && [commentStr rangeOfString:@"https:"].length == 0) {
                            // 枚举行末尾有单行注释 "//"
                            NSArray *lineArr = [commentStr componentsSeparatedByString:@"//"];
                            if(lineArr.count == 2) {
                                NSString *code = lineArr.firstObject;
                                code = [self.loadFileTools removeWhiteSpacePreSufInString:code];
                                code = [self.loadFileTools removeSpecStr:@"," inString:code];
                                
                                NSString *comment = lineArr.lastObject;
                                if([comment rangeOfString:@"<"].length > 0 && [comment rangeOfString:@"<#"].length == 0 && [comment rangeOfString:@">"].length == 0) {
                                    comment = [self.loadFileTools removeSpecStr:@"<" inString:comment];
                                }
                                comment = [self.loadFileTools removeWhiteSpacePreSufInString:comment];
                                if([comment hasPrefix:@"/"]) {
                                    comment = [comment stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                                }
                                comment = [self.loadFileTools removeWhiteSpacePreSufInString:comment];
                                [arr replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"    /// %@\n    %@,", comment, code]];
                            }
                        }
                        if([commentStr rangeOfString:@"/**"].length > 0 && [commentStr rangeOfString:@"*/"].length > 0) {
                            // 枚举行末尾有单行注释 "/** xxx */"
                            NSArray *lineArr = [commentStr componentsSeparatedByString:@"/**"];
                            if(lineArr.count == 2) {
                                NSString *lineCode = lineArr.firstObject;
                                NSString *lineComment = lineArr.lastObject;
                                lineCode = [self.loadFileTools removeWhiteSpacePreSufInString:lineCode];
                                lineCode = [self.loadFileTools removeSpecStr:@"," inString:lineCode];
                                lineComment = [lineComment stringByReplacingOccurrencesOfString:@"*/" withString:@""];
                                if([lineComment rangeOfString:@"<"].length > 0 && [lineComment rangeOfString:@"<#"].length == 0 && [lineComment rangeOfString:@">"].length == 0) {
                                    lineComment = [self.loadFileTools removeSpecStr:@"<" inString:lineComment];
                                }
                                lineComment = [self.loadFileTools removeWhiteSpacePreSufInString:lineComment];
                                [arr replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"    /// %@\n    %@,", lineComment, lineCode]];
                            }
                        }
                    }
                }
            }
            i = j;
        }
    }
}

/// 检查并修复方法参数的注释问题
/// @param arr 代码行数组
- (void)checkParamCommentWithLines:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *commentStr = arr[i];
        if([commentStr hasPrefix:SpecialCode_3_Star] || [commentStr hasPrefix:SpecialCode_4]) {
            continue;
        }
        if([commentStr rangeOfString:@"@param"].length > 0) {
            NSMutableArray *lineArr = [NSMutableArray arrayWithArray:[commentStr componentsSeparatedByString:@"@param"]];
            if(lineArr.count == 2) {
                NSString *comment = lineArr.lastObject;
                comment = [self.loadFileTools removeWhiteSpacePreSufInString:comment];
                if([comment hasPrefix:@":"]) {
                    comment = [comment substringFromIndex:1];
                }
                if([comment rangeOfString:@","].length == 0 && [comment rangeOfString:@"{"].length == 0 && [comment rangeOfString:@"\""].length == 0 && [comment rangeOfString:@"-"].length == 0 && [comment rangeOfString:@"("].length == 0) {
                    if([comment rangeOfString:@": "].length > 0) {
                        comment = [self.loadFileTools replaceSpecStr:@": " withString:@" " inString:comment];
                    }
                    if([comment rangeOfString:@":"].length > 0) {
                        comment = [self.loadFileTools replaceSpecStr:@":" withString:@" " inString:comment];
                    }
                }
                comment = [self.loadFileTools removeWhiteSpacePreSufInString:comment];
                if(comment) {
                    [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// @param %@", comment]];
                }
            }
        }
    }
}

/// 检查并修复方法注释问题
/// @param arr 代码行数组
- (void)checkMethodCommentWithLines:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *commentStr = arr[i];
        NSString *commentNextStr = arr[i+1];
        if([commentStr isEqual:@"}"]) {
            continue;
        }
        if([commentStr hasPrefix:SpecialCode_3_Star] || [commentStr hasPrefix:SpecialCode_4]) {
            continue;
        }
        commentNextStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentNextStr];
        commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
        if([commentStr hasPrefix:@"- ("] || [commentStr hasPrefix:@"-("]) {
            if([commentStr rangeOfString:@";"].length > 0) {
                if([commentStr rangeOfString:@"//"].length > 0) {
                    NSString *codeStr = [commentStr componentsSeparatedByString:@"//"].firstObject;
                    codeStr = [self.loadFileTools removeWhiteSpacePreSufInString:codeStr];
                    commentStr = [commentStr componentsSeparatedByString:@"//"].lastObject;
                    if([commentStr hasPrefix:@"/"]) {
                        commentStr = [commentStr stringByReplacingCharactersInRange:[commentStr rangeOfString:@"/"] withString:@""];
                    }
                    commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                    [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@\n%@", commentStr, codeStr]];
                }
                if([commentStr rangeOfString:@"/**"].length > 0 && [commentStr rangeOfString:@"*/"].length > 0) {
                    NSString *codeStr = [commentStr componentsSeparatedByString:@"/**"].firstObject;
                    codeStr = [self.loadFileTools removeWhiteSpacePreSufInString:codeStr];
                    commentStr = [commentStr componentsSeparatedByString:@"/**"].lastObject;
                    commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                    commentStr = [self.loadFileTools removeSpecStr:@"*/" inString:commentStr];
                    [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@\n%@", commentStr, codeStr]];
                }
            }
        }
        if([commentNextStr hasPrefix:@"- ("] || [commentNextStr hasPrefix:@"-("]) {
            if([commentStr hasPrefix:@"/**"] && [commentStr hasSuffix:@"*/"]) {
                commentStr = [self.loadFileTools removeSpecStr:@"/**" inString:commentStr];
                commentStr = [self.loadFileTools removeSpecStr:@"*/" inString:commentStr];
                if([commentStr rangeOfString:@"<"].length > 0 && [commentStr rangeOfString:@"<#"].length == 0 && [commentStr rangeOfString:@">"].length == 0) {
                    commentStr = [self.loadFileTools removeSpecStr:@"<" inString:commentStr];
                }
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@", commentStr]];
            }
            
            if([commentStr hasPrefix:@"//"] && [commentStr rangeOfString:@"@param"].length == 0) {
                commentStr = [commentStr componentsSeparatedByString:@"//"].lastObject;
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                if([commentStr hasPrefix:@"/"]) {
                    commentStr = [commentStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                if([commentStr hasPrefix:@"<"] && [commentStr rangeOfString:@"<#"].length == 0 && [commentStr rangeOfString:@">"].length == 0) {
                    commentStr = [commentStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                
                commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
                [arr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"/// %@", commentStr]];
            }
        }
    }
}

/// 检查并修复三斜杠后多个无用空格的注释问题
/// @param arr 代码行数组
- (void)checkMuchWhiteSpaceCommentWithLines:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *commentStr = arr[i];
        if([commentStr hasPrefix:SpecialCode_3_Star] || [commentStr hasPrefix:SpecialCode_4]) {
            continue;
        }
        if([commentStr rangeOfString:@"@param"].length > 0 || [commentStr hasPrefix:SpecialCode_3]) {
            if([self.loadFileTools hasMuchWhiteSpace:commentStr]) {
                NSRange range = [self.loadFileTools loadWhiteSpaceRangeInString:commentStr];
                while(range.length >= 2 && range.length != NSNotFound) {
                    commentStr = [commentStr stringByReplacingOccurrencesOfString:[commentStr substringWithRange:range] withString:@" "];
                    range = [self.loadFileTools loadWhiteSpaceRangeInString:commentStr];
                }
            }
            commentStr = [self.loadFileTools removeWhiteSpacePreSufInString:commentStr];
            [arr replaceObjectAtIndex:i withObject:commentStr];
        }
    }
}

/// 检查并修复三斜杠后缺少空格的注释问题
/// @param arr 代码行数组
- (void)checkMissWhiteSpaceCommentWithLines:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count-1; i++) {
        NSString *commentStr = arr[i];
        if([commentStr hasPrefix:SpecialCode_3_Star] || [commentStr hasPrefix:SpecialCode_4]) {
            continue;
        }
        if([commentStr hasPrefix:SpecialCode_3]) {
            if(commentStr.length > 3 && ![[commentStr substringWithRange:NSMakeRange(3, 1)] isEqual:@" "]) {
                commentStr = [commentStr stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"/// "];
                [arr replaceObjectAtIndex:i withObject:commentStr];
            }
        }
    }
}

/// 移除包含“FIXME #捡老鼠屎行动”的老旧代码注释
/// @param arr 代码行数组
-(void)removeBadComment:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count; i++) {
        NSString *commentStr = arr[i];
        if([commentStr rangeOfString:@"FIXME #捡老鼠屎行动"].length > 0) {
            [arr removeObjectAtIndex:i];
            i--;
        }
    }
}

@end
