//
//  NSData+BY.h
//  BYCategory
//
//  Created by Liu on 2021/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 提供data和string、array、dic的相互转换方法
@interface NSData (BY)

/// String转Data
/// @param string string
+(NSData *)dataWithString:(NSString *)string;

/// array转Data
/// @param array array
+(NSData *)dataWithArray:(NSArray *)array;

/// Dic转Data
/// @param dic dic
+(NSData *)dataWithDic:(NSDictionary *)dic;

/// data转string
-(NSString *)dataToString;

/// data转array
-(NSArray *)dataToArray;

/// data转dic
-(NSDictionary *)dataToDic;

@end

NS_ASSUME_NONNULL_END
