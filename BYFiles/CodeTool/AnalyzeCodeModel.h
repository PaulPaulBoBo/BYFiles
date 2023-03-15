//
//  AnalyzeCodeModel.h
//  BYFiles
//
//  Created by Liu on 2022/10/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnalyzeCodeModel : NSObject

/// 类名
@property (nonatomic, copy) NSString *moduleName;
/// 类名
@property (nonatomic, copy) NSString *className;
/// 创建人
@property (nonatomic, copy) NSString *authorName;
/// 父类类名
@property (nonatomic, copy) NSString *parentName;
/// 文件路径
@property (nonatomic, copy) NSString *filePath;
/// 文件相对路径
@property (nonatomic, copy) NSString *fileRelatePath;
/// 文件名
@property (nonatomic, copy) NSString *fileName;
/// 创建时间
@property (nonatomic, copy) NSString *createTime;
/// 属性数组
@property (nonatomic, strong) NSMutableArray *properties;
/// 遵守的协议数组
@property (nonatomic, strong) NSMutableArray *protocols;
/// 实例方法数组
@property (nonatomic, strong) NSMutableArray *instanceMethods;
/// 类方法数组
@property (nonatomic, strong) NSMutableArray *classMethods;
/// 公共方法数组
@property (nonatomic, strong) NSMutableArray *publicMethods;
/// 子类数组
@property (nonatomic, strong) NSMutableArray<AnalyzeCodeModel *> *subClasses;
/// 枚举数组
@property (nonatomic, strong) NSMutableArray *enums;
/// 引用文件数组
@property (nonatomic, strong) NSMutableArray *importFiles;
/// 引用common组件的类名数组 特殊情况才使用 需要额外逻辑处理赋值后才能使用 默认是空数组
@property (nonatomic, strong) NSMutableArray *importCommonFiles;
/// 子类层级
@property (nonatomic, assign) NSInteger level;

@end

NS_ASSUME_NONNULL_END
