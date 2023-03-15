//
//  FindUnusedImport.h
//  BYFiles
//
//  Created by Liu on 2023/1/10.
//

#import "BaseComment.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FindUnusedImportCompletion)(NSArray *paths);

@interface FindUnusedImport : BaseComment

@property (nonatomic, strong) FindUnusedImportCompletion findCompletion;

/// 配置目标类路径 必须在调用start方法前
/// - Parameter orderClassesPaths: 目标类路径数组
-(void)configOrderClassPaths:(NSArray * __nonnull)orderClassesPaths;

/// 选择完依赖的文件夹主动调用，开始分析所有相关的类文件
-(void)analyzeFolder;

@end

NS_ASSUME_NONNULL_END
