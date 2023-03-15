//
//  AnalyzeCodeModel.m
//  BYFiles
//
//  Created by Liu on 2022/10/19.
//

#import "AnalyzeCodeModel.h"

@implementation AnalyzeCodeModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.className = @"";
        self.authorName = @"";
        self.parentName = @"";
        self.filePath = @"";
        self.fileRelatePath = @"";
        self.fileName = @"";
        self.createTime = @"";
        self.properties = [NSMutableArray new];
        self.protocols = [NSMutableArray new];
        self.instanceMethods = [NSMutableArray new];
        self.classMethods = [NSMutableArray new];
        self.publicMethods = [NSMutableArray new];
        self.subClasses = [NSMutableArray new];
        self.enums = [NSMutableArray new];
        self.importFiles = [NSMutableArray new];
        self.importCommonFiles = [NSMutableArray new];
        self.level = 0;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *titleShape = [NSMutableString stringWithString:@"##"];
    if(self.level < 1) {
        for(int i = 0; i < self.level; i++) {
            [titleShape appendString:@"#"];
        }
    } else {
        titleShape = [NSMutableString stringWithString:@"- "];
    }
    NSMutableString *space = [NSMutableString stringWithString:@"  "];
    for(int i = 0; i < self.level; i++) {
        [space appendString:@"  "];
    }
    
    NSMutableString *mString = [NSMutableString new];
    if(self.className && self.className.length > 0) {
        [mString appendFormat:@"\n%@ %@", titleShape, self.className];
        
        if(self.filePath && self.filePath.length > 0) {
//            [mString appendFormat:@"\n%@- 文件路径：%@", space, self.filePath];
        }
        
        if(self.fileRelatePath && self.fileRelatePath.length > 0) {
//            [mString appendFormat:@"\n%@- 文件相对路径：%@", space, self.fileRelatePath];
        }
        
        if(self.parentName && self.parentName.length > 0) {
//            [mString appendFormat:@"\n%@- 父类：%@", space, self.parentName];
        }
        
        if(self.authorName && self.authorName.length > 0) {
//            [mString appendFormat:@"\n%@- 创建人：%@", space, self.authorName];
        }
        
        if(self.createTime && self.createTime.length > 0) {
//            [mString appendFormat:@"\n%@- 创建时间：%@", space, self.createTime];
        }
        
        if(self.properties && self.properties.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (NSString *str in self.properties) {
                [subStr appendFormat:@"\n%@  - %@", space, str];
            }
        }
        
        if(self.protocols && self.protocols.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (NSString *str in self.protocols) {
                [subStr appendFormat:@"\n%@  - %@", space, str];
            }
        }
        
        if(self.instanceMethods && self.instanceMethods.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (NSString *str in self.instanceMethods) {
                [subStr appendFormat:@"\n%@  - %@", space, str];
            }
        }
        
        if(self.classMethods && self.classMethods.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (NSString *str in self.classMethods) {
                [subStr appendFormat:@"\n%@  - %@", space, str];
            }
        }
        
        if(self.publicMethods && self.publicMethods.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (NSString *str in self.publicMethods) {
                [subStr appendFormat:@"\n%@  - %@", space, str];
            }
        }
        
        if(self.enums && self.enums.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (NSString *str in self.enums) {
                [subStr appendFormat:@"\n%@  - %@", space, str];
            }
        }
        
        if(self.importFiles && self.importFiles.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (NSString *str in self.importFiles) {
                [subStr appendFormat:@"\n%@  - %@", space, str];
            }
        }
        
        if(self.importCommonFiles && self.importCommonFiles.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (AnalyzeCodeModel *model in self.importCommonFiles) {
                [subStr appendFormat:@"\n%@  - %@", space, model.className];
            }
        }
        
        if(self.subClasses && self.subClasses.count > 0) {
            NSMutableString *subStr = [NSMutableString new];
            for (AnalyzeCodeModel *subClassModel in self.subClasses) {
                [subStr appendFormat:@"%@  %@", space, subClassModel.description];
            }
            [mString appendFormat:@"\n%@# 子类%@", titleShape, subStr];
        }
        
        return [mString copy];
    } else {
        return @"";
    }
}

@end
