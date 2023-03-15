//
//  AnalyzeCode.h
//  BYFiles
//
//  Created by Liu on 2022/10/19.
//

#import "BaseComment.h"
#import "AnalyzeCodeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnalyzeCode : BaseComment

/// 读取文件信息
/// - Parameters:
///   - files: 文件路径数组
///   - completion: 完成回调，将生成的文件信息数组返回
-(void)loadHFilesInfoInPath:(NSArray *)files completion:(void(^)(NSArray<AnalyzeCodeModel *> *arr))completion;

@end

NS_ASSUME_NONNULL_END
