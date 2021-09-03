//
//  RBasePresenter.h
//  RApp
//
//  Created by l on 2021/3/13.
//  请求类基类

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RRequestMethod) {
    RRequestMethodGET,
    RRequestMethodPOST,
    RRequestMethodPUT,
    RRequestMethodDELETE,
};

/**无网络或从有网状态切到无网络*/
static NSString *NetWorkNotification_Loss_Net = @"NetWorkNotification_Loss_Net";
/**从其他状态切到wifi*/
static NSString *NetWorkNotification_Switch_WiFi = @"NetWorkNotification_Switch_WIFI";
/**从其他状态切到流量*/
static NSString *NetWorkNotification_Switch_WWAN = @"NetWorkNotification_Switch_WWAN";

/**请求成功回调*/
typedef void(^RequestFinish)(id obj, NSString *msg, BOOL isSuc);
/**请求失败回调*/
typedef void(^RequestFail)(NSString *msg);
/**处理数据的回调*/
typedef void(^parseData)(id obj);
/**上传成功回调*/
typedef void(^UploadFinish)(id obj, NSString *msg, BOOL isSuc);

/**
 * Presenter基类 提供请求的基本方法 get、post、upload
 */
@interface RBasePresenter : NSObject

/// GET 请求基类 默认取serverUrl、RRequestCachePolicyNet、RRequestSerializerTypeJSON
/// @param url 请求路由
/// @param param 请求参数
/// @param requestFinish 完成回调
/// @param requestFail 请求失败
+(void)requestUrl:(NSString *)url param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail;


/// GET 请求基类 默认取serverUrl、RRequestCachePolicyNet、RRequestSerializerTypeJSON
/// @param url 请求路由
/// @param param 请求参数
/// @param requestFinish 完成回调
/// @param requestFail 请求失败
/// @param parseData 处理数据 block是异步处理，不要做数据处理以外的UI线程的操作。
+(void)requestUrl:(NSString *)url param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail parseData:(parseData)parseData;

/// POST 请求基类 默认取serverUrl、RRequestCachePolicyNet、RRequestSerializerTypeJSON
/// @param url 请求路由
/// @param param 请求参数
/// @param requestFinish 完成回调
/// @param requestFail 请求失败
+(void)postUrl:(NSString *)url param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail;

/// POST 请求基类 默认取serverUrl、RRequestCachePolicyNet、RRequestSerializerTypeJSON
/// @param url 请求路由
/// @param param 请求参数
/// @param requestFinish 完成回调
/// @param requestFail 请求失败
/// @param parseData 处理数据 block是异步处理，不要做数据处理以外的UI线程的操作。
+(void)postUrl:(NSString *)url param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail parseData:(parseData)parseData;

/// 上传图片
/// @param imageData 图片Data
/// @param url 上传地址
/// @param uploadFinish 上传结束
/// @param requestFail 请求失败
+(void)uploadImage:(NSData *)imageData url:(NSString *)url uploadFinish:(UploadFinish)uploadFinish requestFail:(RequestFail)requestFail;

/// 上传文件
/// @param data 文件Data
/// @param type 文件类型
/// @param fileName 文件名
/// @param uploadFinish 上传结束
/// @param requestFail 请求失败
+(void)uploadFile:(NSData *)data type:(NSString *)type fileName:(NSString *)fileName uploadFinish:(UploadFinish)uploadFinish requestFail:(RequestFail)requestFail;

/// 请求基类 默认取serverUrl、RRequestCachePolicyNet、RRequestSerializerTypeJSON
/// @param url 请求路由
/// @param methodType 请求类型 RRequestMethodGET,RRequestMethodPOST,RRequestMethodHEAD,RRequestMethodPUT,RRequestMethodDELETE,RRequestMethodPATCH,
/// @param param 请求参数
/// @param requestFinish 完成回调
/// @param requestFail 请求失败
+(void)loadUrl:(NSString *)url methodType:(RRequestMethod)methodType param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail;

@end

NS_ASSUME_NONNULL_END
