//
//  ConvertFileTool.m
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import "ConvertFileTool.h"
#import "BYFileTreeModel.h"
#import "NSFileManager+BY.h"
#import "NSData+BY.h"
#import "NSDate+BY.h"

@implementation ConvertFileTool

+(void)convertFilePath:(NSString *)filePath toPath:(NSString *)orderPath baseURLStr:(NSString *)baseURLStr log:(void (^)(NSString *msg))log completion:(void (^)(NSString *filePath))completion {
    NSString *dateStr = [NSDate stringWithDate:[NSDate date] formatStr:@"yyyyMMddHHmmss"];
    NSData *data = [NSFileManager readFileDataWithFilePath:filePath];
    NSString *str = [data dataToString];
    while ([str rangeOfString:@"transcode_"].length > 0) {
        str = [str stringByReplacingOccurrencesOfString:@"transcode_" withString:[NSString stringWithFormat:@"%@/%@/++--++", baseURLStr, @""]];
    }
    while ([str rangeOfString:@"++--++"].length > 0) {
        str = [str stringByReplacingOccurrencesOfString:@"++--++" withString:@"transcode_"];
    }
    NSString *newFile = [NSString stringWithFormat:@"%@/file_%@.m3u8", orderPath, dateStr];
    [NSFileManager writeData:[NSData dataWithString:str] toFile:newFile finish:^(BOOL isSuc, NSString * _Nullable msg) {
        if(log) {
            log([NSString stringWithFormat:@"文件已转换完成 %@", filePath]);
            log(@"1秒后开始下一个文件转化");
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(completion) {
                completion(newFile);
            }
        });
    }];
}

@end
