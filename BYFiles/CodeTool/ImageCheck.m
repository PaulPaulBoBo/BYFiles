//
//  ImageCheck.m
//  BYFiles
//
//  Created by Liu on 2022/12/19.
//

#import "ImageCheck.h"

@interface ImageCheck ()

@property (nonatomic, strong) NSMutableArray *fileModels;
@property (nonatomic, strong) NSMutableSet *imageNames;

@end

@implementation ImageCheck

/// 启动入口
-(void)start {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if(self.files.count > 0) {
            [self.files enumerateObjectsUsingBlock:^(NSString *  _Nonnull filePath, NSUInteger idx, BOOL * _Nonnull stop) {
                __weak typeof(weakSelf) strongSelf = weakSelf;
                if([filePath rangeOfString:@".imageset"].length > 0) {
                    NSString *imageName = [[filePath componentsSeparatedByString:@".imageset"].firstObject componentsSeparatedByString:@"/"].lastObject;
                    if(imageName && imageName.length > 0) {
                        [strongSelf.imageNames addObject:imageName];
                    }
                }
            }];
            [strongSelf startCheck];
        }
    });
}

-(void)startCheck {
    if(self.files.count > 0 && IsRunning == NO) {
        __weak typeof(self) weakSelf = self;
        
        IsRunning = YES;
        NSString *path = self.files.firstObject;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"即将开始查找 %@", path] tag:[self className] toTextView:self.msgTextView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf checkImage:path completion:^(BOOL isSuc, NSString * _Nullable msg) {
                [LogMsgTool updateMsg:[NSString stringWithFormat:@"查找完成 %@", path] tag:[self className] toTextView:strongSelf.msgTextView];
                if(strongSelf.files.count > 0) {
                    [strongSelf.files removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGFloat process = (strongSelf.fileCount - strongSelf.files.count)*1.0/strongSelf.fileCount;
                        strongSelf.stateLabel.stringValue = [NSString stringWithFormat:@"%@ 当前进度：%.2lf%@ 查找完成:%@", @(strongSelf.files.count), process*100, @"%", [path componentsSeparatedByString:@"/"].lastObject];
                        [strongSelf.progressView setDoubleValue:process];
                    });
                    IsRunning = NO;
                    [strongSelf startCheck];
                }
            }];
        });
    } else {
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"查找完成!无用的图片文件名如下：\n%@", self.imageNames] tag:[self className] toTextView:self.msgTextView];
    }
}

-(void)checkImage:(NSString *)filePath completion:(BYFileOperationFinish)completion {
    if([filePath rangeOfString:@".png"].length > 0) {
        completion(YES, @"");
        return;
    }
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString *string = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    if(string.length > 0) {
        if([[GeneralConfig shareInstance] readSettionWithKey:@"600"]) {
            if(self.imageNames.count > 0) {
                [self.imageNames enumerateObjectsUsingBlock:^(NSString *  _Nonnull imageNameString, BOOL * _Nonnull stop) {
                    if([string rangeOfString:imageNameString].length > 0) {
                        [self.imageNames removeObject:imageNameString];
                    }
                }];
            }
        }
        completion(YES, @"");
    } else {
        completion(NO, @"");
    }
}

- (NSMutableSet *)imageNames {
    if(_imageNames == nil) {
        _imageNames = [[NSMutableSet alloc] init];
    }
    return _imageNames;
}

@end
