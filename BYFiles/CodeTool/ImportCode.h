//
//  ImportCode.h
//  BYFiles
//
//  Created by Liu on 2022/11/4.
//

#import "BaseComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImportCode : BaseComment

/// 开始规范化代码前，请先将依赖库分析完成，才可以按照依赖库规范化
/// - Parameter paths: Pods文件路径数组
-(void)setupBaseFilesInPaths:(NSArray *)paths;

@end

NS_ASSUME_NONNULL_END
