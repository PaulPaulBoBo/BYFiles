//
//  GeneralConfig.m
//  BYFiles
//
//  Created by Liu on 2021/12/2.
//

#import "GeneralConfig.h"

@interface GeneralConfig ()

/// 设置字典
@property (nonatomic, strong) NSMutableDictionary *settings;

@end

static GeneralConfig *config = nil;

@implementation GeneralConfig

+ (instancetype)shareInstance {
    if(config == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            config = [[GeneralConfig alloc] init];
            config.settings = [NSMutableDictionary new];
        });
    }
    return config;
}

/// 更新设置
/// @param param 设置参数
- (void)updateSetting:(NSDictionary *)param {
    if(param && param.allKeys.count > 0) {
        self.settings = [NSMutableDictionary dictionaryWithDictionary:param];
    }
}

/// 读取某个设置的布尔值
/// @param key 设置的key
- (BOOL)readSettionWithKey:(NSString *)key {
    if(key && key.length > 0 && self.settings && [[self.settings allKeys] containsObject:key]) {
        return [[self.settings objectForKey:key] isEqual:@"1"];
    }
    return NO;
}

@end
