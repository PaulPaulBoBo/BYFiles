//
//  RFNetworking.h
//  RFNetworking
//
//  Created by 张涛 on 2020/7/9.
//

#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

/**网络类型*/
typedef NS_ENUM(NSInteger, RFNetworkReachabilityStatus) {
    RFNetworkReachabilityStatusUnknown          = -1, /**<未知类型*/
    RFNetworkReachabilityStatusNotReachable     = 0,  /**<网络未连接*/
    RFNetworkReachabilityStatusReachableViaWWAN = 1,  /**<3G、4G网络*/
    RFNetworkReachabilityStatusReachableViaWiFi = 2,  /**<wifi网络*/
};

/**RealReachability网络监听*/
typedef void(^RFNetworkReachabilityStatusBlock)(RFNetworkReachabilityStatus status);

/**请求完成回调*/
typedef void(^RFRequestCompletionBlock)(NSDictionary *response, BOOL isSuccess);

/**
 * 网络请求类
 */
@interface RFNetworking : NSObject

/**网络类型*/
@property (readonly, nonatomic, assign) RFNetworkReachabilityStatus networkReachabilityStatus;

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableURLRequest *request;

+(instancetype)shareInstance;

/// 开始监听网络状态（建议放入appdelegate执行）
+ (void)startMonitoring;

/// 判断有无网络 YES：有网 NO：无网
+ (BOOL)isNetReachable;

/// 网络变化监听
/// @param block RealReachability网络监听
+ (void)networkReachabilityStatus:(RFNetworkReachabilityStatusBlock)block;

/// 获取当前网络类型
+ (RFNetworkReachabilityStatus)currentNetworkReachabilityStatus;

/// 网络请求
/// @param method 请求方法 GET POST PUT DELETE
/// @param URLString 请求地址 全地址
/// @param header 请求头 字典
/// @param parameters 请求参数 字典
/// @param uploadProgress 进度回调
/// @param completionBlock 完成回调
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method URLString:(NSString *)URLString header:(NSDictionary *)header parameters:(id)parameters uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress completionBlock:(RFRequestCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
