//
//  LoadFileTools.m
//  BYFiles
//
//  Created by Liu on 2021/11/29.
//

#import "LoadFileTools.h"

@implementation LoadFileTools

/// 移除string中首尾空格，如果首尾有多个空格也会全部移除
/// @param string 原字符串
-(NSString *)removeWhiteSpacePreSufInString:(NSString *)string {
    while ([string hasPrefix:@" "] || [string hasSuffix:@" "]) {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return string;
}

/// 移除string中所有的str
/// @param str 查询子串
/// @param string 原字符串
-(NSString *)removeSpecStr:(NSString *)str inString:(NSString *)string {
    return [self replaceSpecStr:str withString:@"" inString:string];
}

/// 把string中所有的str替换为newStr
/// @param str 查询子串
/// @param newStr 替换子串
/// @param string 原字符串
-(NSString *)replaceSpecStr:(NSString *)str withString:(NSString *)newStr inString:(NSString *)string {
    if(string == nil || string.length == 0) {
        return @"";
    }
    while ([string rangeOfString:str].length > 0) {
        string = [string stringByReplacingOccurrencesOfString:str withString:newStr];
    }
    return string;
}

/// 获取字符串中首个连续的空格字符串的range
/// @param str 原字符串
-(NSRange)loadWhiteSpaceRangeInString:(NSString *)str {
    BOOL hasMuchSpace = [self hasMuchWhiteSpace:str];
    if(!hasMuchSpace) {
        return NSMakeRange(0, 0);
    }
    NSRange spaceRange = NSMakeRange(0, 0);
    for (int i = 0; i < str.length; i++) {
        if(spaceRange.length == 0) {
            if([[str substringWithRange:NSMakeRange(i, 1)] isEqual:@" "]) {
                spaceRange.length = 1;
                spaceRange.location = i;
            } else {
                spaceRange.length = 0;
                spaceRange.location = i;
            }
        } else {
            if([[str substringWithRange:NSMakeRange(i, 1)] isEqual:@" "]) {
                spaceRange.length += 1;
            } else {
                if(spaceRange.length >= 2) {
                    break;
                } else {
                    spaceRange.length = 0;
                    spaceRange.location = i;
                }
            }
        }
    }
    return spaceRange;
}

/// 判断字符串里是否有连续空格
/// @param str 要判断的字符串
-(BOOL)hasMuchWhiteSpace:(NSString *)str {
    return [str containsString:@"  "];
}

/// 获取方法的参数
/// @param code 方法代码行
/// @param arr 代码行数组 多行方法时使用
/// @param line 当前方法行 多行方法时使用
-(NSArray *)loadMethodParam:(NSString *)code arr:(NSArray *)arr line:(NSInteger)line {
    NSArray *results = @[];
    code = [self removeWhiteSpacePreSufInString:code];
    if([code hasSuffix:@";"]) {
        // 单行
        results =  [self loadMethodParams:code];
    } else {
        // 多行
        NSMutableString *codeStr = [NSMutableString stringWithString:code];
        for (NSInteger i = line+1; i < arr.count - 1; i++) {
            NSString *tmpCode = arr[i];
            if([tmpCode rangeOfString:@";"].length > 0) {
                [codeStr appendFormat:@"%@", tmpCode];
                break;
            } else {
                [codeStr appendFormat:@"%@", tmpCode];
            }
        }
        results = [self loadMethodParams:codeStr];
    }
    return results;
}

/// 获取单行方法代码的参数
/// @param code 单行代码字符串 必须是以分号结尾的单行字符串方法
- (NSArray *)loadMethodParams:(NSString *)code {
    NSMutableArray *results = [NSMutableArray new];
    NSString *tmpCode = [NSString stringWithFormat:@"%@", code];
    if([tmpCode rangeOfString:@":"].length == 0) {
        // 无参数
        return [results copy];
    }
    
    // 移除同行注释
    if([tmpCode rangeOfString:@"//"].length > 0) {
        tmpCode = [tmpCode componentsSeparatedByString:@"//"].firstObject;
        tmpCode = [self removeWhiteSpacePreSufInString:tmpCode];
    }
    if([tmpCode rangeOfString:@"/*"].length > 0) {
        tmpCode = [tmpCode componentsSeparatedByString:@"/*"].firstObject;
        tmpCode = [self removeWhiteSpacePreSufInString:tmpCode];
    }
    
    // 移除连续空格
    while([self hasMuchWhiteSpace:tmpCode]) {
        tmpCode = [tmpCode stringByReplacingOccurrencesOfString:[tmpCode substringWithRange:[self loadWhiteSpaceRangeInString:tmpCode]] withString:@" "];
    }
    while([tmpCode rangeOfString:@"("].length > 0) {
        tmpCode = [tmpCode stringByReplacingCharactersInRange:[self findParamTypeRange:tmpCode] withString:@""];
    }
    
    // 移除无用空格
    if([tmpCode rangeOfString:@"- ("].length > 0) {
        tmpCode = [self replaceSpecStr:@"- (" withString:@"-(" inString:tmpCode];
    }
    if([tmpCode rangeOfString:@"+ ("].length > 0) {
        tmpCode = [self replaceSpecStr:@"+ (" withString:@"+(" inString:tmpCode];
    }
    if([tmpCode rangeOfString:@"; "].length > 0) {
        tmpCode = [self replaceSpecStr:@"; " withString:@";" inString:tmpCode];
    }
    
    NSString *paramName = @"";
    if([tmpCode rangeOfString:@" "].length == 0) {
        // 一个参数
        NSString *paramName = [tmpCode componentsSeparatedByString:@":"].lastObject;
        if(paramName && paramName.length > 0 &&
           [paramName rangeOfString:@":"].length == 0 &&
           [paramName rangeOfString:@"("].length == 0 &&
           [paramName rangeOfString:@")"].length == 0 &&
           [paramName rangeOfString:@"-"].length == 0) {
            if([paramName rangeOfString:@";"].length > 0) {
                paramName = [self removeSpecStr:@";" inString:paramName];
            }
            [results addObject:paramName];
        }
    } else {
        // 多个参数
        NSArray *arr = [tmpCode componentsSeparatedByString:@" "];
        for (int i = 0; i < arr.count; i++) {
            NSString *tmpCode = arr[i];
            if([tmpCode rangeOfString:@":"].length == 0) {
                continue;
            }
            tmpCode = [tmpCode componentsSeparatedByString:@":"].lastObject;
            tmpCode = [tmpCode stringByReplacingCharactersInRange:[self findParamTypeRange:tmpCode] withString:@""];
            tmpCode = [self removeWhiteSpacePreSufInString:tmpCode];
            NSString *paramName = tmpCode;
            if(paramName && paramName.length > 0 &&
               [paramName rangeOfString:@":"].length == 0 &&
               [paramName rangeOfString:@"("].length == 0 &&
               [paramName rangeOfString:@")"].length == 0 &&
               [paramName rangeOfString:@"-"].length == 0) {
                if([paramName rangeOfString:@";"].length > 0) {
                    paramName = [self removeSpecStr:@";" inString:paramName];
                }
                [results addObject:paramName];
            }
        }
    }
    
    return [results copy];
}

/// 获取string中str的个数
/// @param str 指定子串
/// @param string 源字符串
-(NSInteger)findSpecStrCount:(NSString *)str inString:(NSString *)string {
    NSInteger count = 0;
    NSString *tmpStr = [NSString stringWithFormat:@"%@", string];
    while ([tmpStr rangeOfString:str].length > 0) {
        count++;
        tmpStr = [tmpStr stringByReplacingCharactersInRange:[tmpStr rangeOfString:@":"] withString:@""];
    }
    return count;
}

/// 获取方法中"()"及"()"内的代码range
/// @param code 方法代码字符串
-(NSRange)findParamTypeRange:(NSString *)code {
    NSRange range = NSMakeRange(0, 0);
    
    if([code rangeOfString:@"("].length == 0 && [code rangeOfString:@")"].length == 0) {
        return range;
    }
    
    range = [code rangeOfString:@"("];
    NSRange closeRange = [code rangeOfString:@")"];
    range.length = closeRange.location-range.location+1;
    NSString *tmpCodeSubStr = [code substringWithRange:range];
    NSString *tmpCodeSubStrPre = [code substringWithRange:NSMakeRange(0, range.location+1)];
    if([tmpCodeSubStr rangeOfString:@"^"].length > 0) {
        tmpCodeSubStr = [code substringWithRange:NSMakeRange(range.location+1, code.length-range.location-1)];
        for (int i = 0; i < 2; i++) {
            tmpCodeSubStr = [tmpCodeSubStr stringByReplacingCharactersInRange:[tmpCodeSubStr rangeOfString:@"("] withString:@"%"];
        }
        for (int i = 0; i < 2; i++) {
            tmpCodeSubStr = [tmpCodeSubStr stringByReplacingCharactersInRange:[tmpCodeSubStr rangeOfString:@")"] withString:@"%"];
        }
        tmpCodeSubStr = [tmpCodeSubStr stringByReplacingOccurrencesOfString:@"^" withString:@"$"];
        NSString *newCode = [NSString stringWithFormat:@"%@%@", tmpCodeSubStrPre, tmpCodeSubStr];
        range = [self findParamTypeRange:newCode];
    }
    return range;
}

@end
