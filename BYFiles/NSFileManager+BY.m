//
//  NSFileManager+BY.m
//  BYCategory
//
//  Created by Liu on 2021/8/26.
//

#import "NSFileManager+BY.h"

@implementation NSFileManager (BY)

+(NSString *)homePath {
    NSString *tmpPath = NSHomeDirectory();
    return tmpPath;
}

+(NSString *)documentPath {
    NSString *tmpPath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    tmpPath = [paths objectAtIndex:0];
    return tmpPath;
}

+(NSString *)libraryPath {
    NSString *tmpPath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    tmpPath = [paths objectAtIndex:0];
    return tmpPath;
}

+(NSString *)cachePath {
    NSString *tmpPath = @"";
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    tmpPath = [cacPath objectAtIndex:0];
    return tmpPath;
}

+(NSString *)tmpPath {
    NSString *tmpPath = NSTemporaryDirectory();;
    return tmpPath;
}

+(NSString *)createPath:(NSString *)pathName finish:(BYFileOperationFinish)finish {
    NSString *tmpPath = pathName;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:pathName]) {
        BOOL isSuc = [fileManager createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:nil];
        if(isSuc) {
            if(finish) {
                finish(YES, @"创建成功");
            }
        } else {
            if(finish) {
                finish(NO, @"创建失败");
            }
        }
    } else {
        if(finish) {
            finish(NO, @"路径已存在");
        }
    }
    return tmpPath;
}

+(NSString *)createFile:(NSString *)filePath finish:(BYFileOperationFinish)finish {
    NSString *tmpPath = [NSString stringWithFormat:@"%@", filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        BOOL isSuc = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        if(isSuc) {
            if(finish) {
                finish(YES, @"创建成功");
            }
        } else {
            if(finish) {
                finish(NO, @"创建失败");
            }
        }
    } else {
        if(finish) {
            finish(NO, @"文件已存在");
        }
    }
    return tmpPath;
}

+(NSString *)writeData:(NSData *)data toFile:(NSString *)filePath finish:(BYFileOperationFinish)finish {
    NSString *tmpPath = @"";
    [NSFileManager createFile:filePath finish:^(BOOL isSuc, NSString * _Nullable msg) {
        
    }];
    BOOL isSuc = [data writeToFile:filePath atomically:YES];
    if(isSuc) {
        if(finish) {
            finish(YES, @"创建成功");
        }
    } else {
        if(finish) {
            finish(NO, @"创建失败");
        }
    }
    return tmpPath;
}

+(NSData *)readFileDataWithFilePath:(NSString *)filePath {
    if(filePath == nil || filePath.length == 0) {
        return nil;
    }
    NSData *tmpData = [[NSData alloc] initWithContentsOfFile:filePath];
    return tmpData;
}

+(BYFileAttributeModel *)readFileAttribute:(NSString *)filePath {
    BYFileAttributeModel *tmpFileAttribute = [[BYFileAttributeModel alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:filePath traverseLink:YES];
    if (fileAttributes != nil) {
        tmpFileAttribute.type = [fileAttributes objectForKey:NSFileType];
        tmpFileAttribute.fileSize = [fileAttributes objectForKey:NSFileSize];
        tmpFileAttribute.owner = [fileAttributes objectForKey:NSFileOwnerAccountName];
        tmpFileAttribute.createDate = [fileAttributes objectForKey:NSFileCreationDate];
        tmpFileAttribute.changeDate = [fileAttributes objectForKey:NSFileModificationDate];
    }
    return tmpFileAttribute;
}

+(BOOL)deleteFile:(NSString *)filePath finish:(BYFileOperationFinish)finish {
    BOOL isSuc = YES;
    BOOL isDir = NO;
    BOOL isExist = NO;
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    isExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if(isExist) {
        isSuc = [fileManager removeItemAtPath:filePath error:&error];
        if(isSuc) {
            if(finish) {
                finish(YES, @"删除成功");
            }
        } else {
            if(finish) {
                finish(NO, @"删除失败");
            }
        }
    } else {
        if(finish) {
            finish(NO, @"文件不存在");
        }
    }
    return isSuc;
}

+ (BYFileTreeModel *)loadFilesInPath:(NSString *)path level:(NSNumber *)level isContinue:(BOOL)isContinue {
    BYFileTreeModel *tmpFileTreeModel = [[BYFileTreeModel alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:path];
    BOOL isDir = NO;
    BOOL isExist = NO;
    NSMutableArray *subPaths = [NSMutableArray new];
    NSMutableArray *files = [NSMutableArray new];
    NSArray *arr = directoryEnumerator.allObjects;
    if(arr == nil || arr.count == 0) {
        return nil;
    }
    for (int i = 0; i < arr.count; i++) {
        NSString *tmpPath = arr[i];
        if([tmpPath rangeOfString:@"/"].length > 0) {
            continue;
        }
        NSString *tmpFullPath = [NSString stringWithFormat:@"%@/%@", path, tmpPath];
        isExist = [fileManager fileExistsAtPath:tmpFullPath isDirectory:&isDir];
        if (isDir) {
            if(isContinue) {
                BYFileTreeModel *nextModel = [self loadFilesInPath:tmpFullPath level:level isContinue:NO];
                // 目录路径
                BYFileTreeModel *model = [[BYFileTreeModel alloc] init];
                model.pathName = tmpPath;
                model.fullPath = tmpFullPath;
                model.pathAttribute = [NSFileManager readFileAttribute:tmpFullPath];
                model.files = nextModel.files;
                model.subPaths = nextModel.subPaths;
                model.level = level;
                model.isOpen = NO;
                if(model) {
                    [subPaths addObject:model];
                }
            } else {
                // 目录路径
                BYFileTreeModel *model = [[BYFileTreeModel alloc] init];
                model.pathName = tmpPath;
                model.fullPath = tmpFullPath;
                model.pathAttribute = [NSFileManager readFileAttribute:tmpFullPath];
                model.files = @[];
                model.subPaths = @[];
                model.level = level;
                model.isOpen = NO;
                if(model) {
                    [subPaths addObject:model];
                }
            }
        } else {
            // 文件路径
            BYFileModel *fileModel = [[BYFileModel alloc] init];
            fileModel.fileName = [tmpFullPath componentsSeparatedByString:@"/"].lastObject;
            fileModel.filePath = tmpFullPath;
            fileModel.fileAttribute = [NSFileManager readFileAttribute:tmpFullPath];
            fileModel.level = level;
            fileModel.isOpen = NO;
            if(fileModel) {
                [files addObject:fileModel];
            }
        }
    }
    tmpFileTreeModel.subPaths = [subPaths copy];
    tmpFileTreeModel.files = [files copy];
    tmpFileTreeModel.pathName = [path componentsSeparatedByString:@"/"].lastObject;
    tmpFileTreeModel.fullPath = path;
    tmpFileTreeModel.pathAttribute = [NSFileManager readFileAttribute:path];
    tmpFileTreeModel.level = level;
    tmpFileTreeModel.isOpen = NO;
    return tmpFileTreeModel;
}

@end
