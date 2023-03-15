//
//  GeneralConfig.h
//  BYFiles
//
//  Created by Liu on 2021/12/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeneralConfig : NSObject

/// 单例
+ (instancetype)shareInstance;

/// 更新设置
/// @param param 设置参数
- (void)updateSetting:(NSDictionary *)param;

/// 读取某个设置的布尔值
/// @param key 设置的key
- (BOOL)readSettionWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
