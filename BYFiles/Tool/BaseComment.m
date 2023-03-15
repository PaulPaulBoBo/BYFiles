//
//  BaseComment.m
//  BYFiles
//
//  Created by Liu on 2021/11/29.
//

#import "BaseComment.h"

@implementation BaseComment

/// 启动转换入口
-(void)start {
    // 交由子类实现
}

/// 读取给定目录下的文件和文件夹，将文件存储到全局属性files中，递归遍历子文件夹
/// @param path 给定目录
-(void)findFileInPath:(NSString *)path {
    BYFileTreeModel *model = [NSFileManager loadFilesInPath:path level:@1 isContinue:NO];
    if(model.files && model.files.count > 0) {
        for (int i = 0; i < model.files.count; i++) {
            BYFileModel *file = model.files[i];
            if(file && file.filePath.length > 0) {
                [self findFile:file.filePath];
            }
        }
    }
    if(model.subPaths && model.subPaths.count > 0) {
        for (int i = 0; i < model.subPaths.count; i++) {
            BYFileTreeModel *subModel = (BYFileTreeModel *)model.subPaths[i];
            if([subModel.fullPath rangeOfString:@".DS_Store"].length == 0) {
                [self findFileInPath:subModel.fullPath];
            }
        }
    }
}

/// 将给定文件路径存储在全局属性 files 中
/// .DS_Store不存储，仅存储.h和.m
/// @param filePath 给定文件路径
-(void)findFile:(NSString *)filePath {
    if([filePath hasSuffix:@".h"] || [filePath hasSuffix:@".m"] || [filePath hasSuffix:@".png"]) {
        [self.files addObject:filePath];
    }
}

-(void)expectPodsFiles {
    for (int i = 0; i < self.files.count; i++) {
        NSString *podsPath = self.files[i];
        if([podsPath rangeOfString:@"Pods/"].length > 0) {
            [self.files removeObjectAtIndex:i];
            i--;
        }
    }
    self.fileCount = self.files.count;
    [LogMsgTool updateMsg:[NSString stringWithFormat:@"去除Pods目录下不需要处理的文件，还有%@个文件将要被处理", @(self.files.count)] tag:[self className] toTextView:self.msgTextView];
}

-(LoadFileTools *)loadFileTools {
    if(_loadFileTools == nil) {
        _loadFileTools = [[LoadFileTools alloc] init];
    }
    return _loadFileTools;
}

-(BYFileTreeModel *)fileModel {
    if(_fileModel == nil) {
        _fileModel = [[BYFileTreeModel alloc] init];
    }
    return _fileModel;
}

-(NSMutableArray *)files {
    if(_files == nil) {
        _files = [[NSMutableArray alloc] init];
    }
    return _files;
}

@end
