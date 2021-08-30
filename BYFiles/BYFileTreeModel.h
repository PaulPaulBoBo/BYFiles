//
//  BYFileTreeModel.h
//  BYCategory
//
//  Created by Liu on 2021/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 文件属性模型
 */
@interface BYFileAttributeModel : NSObject

/**文件或文件夹大小*/
@property (nonatomic, strong) NSNumber *fileSize;
/**创建时间*/
@property (nonatomic, strong) NSDate *createDate;
/**修改时间*/
@property (nonatomic, strong) NSDate *changeDate;
/**创建人*/
@property (nonatomic, strong) NSString *owner;
/**类型*/
@property (nonatomic, strong) NSString *type;
/**位置*/
@property (nonatomic, strong) NSString *path;

@end


/**
 * 文件模型
 */
@interface BYFileModel : NSObject

/**文件名*/
@property (nonatomic, strong) NSString *fileName;
/**位置*/
@property (nonatomic, strong) NSString *filePath;
/**全部属性*/
@property (nonatomic, strong) BYFileAttributeModel *fileAttribute;
/**所在层级*/
@property (nonatomic, strong) NSNumber *level;
/**是否展开*/
@property (nonatomic, assign) BOOL isOpen;

@end


/**
 * 文件目录模型
 */
@interface BYFileTreeModel : NSObject
/**文件夹名*/
@property (nonatomic, strong) NSString *pathName;
/**全路径*/
@property (nonatomic, strong) NSString *fullPath;
/**全部属性*/
@property (nonatomic, strong) BYFileAttributeModel *pathAttribute;
/**子目录文件*/
@property (nonatomic, strong) NSArray *files;
/**子目录*/
@property (nonatomic, strong) NSArray<BYFileTreeModel *> *subPaths;
/**所在层级*/
@property (nonatomic, strong) NSNumber *level;
/**是否展开*/
@property (nonatomic, assign) BOOL isOpen;

@end

NS_ASSUME_NONNULL_END
