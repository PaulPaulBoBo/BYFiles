//
//  RFNetworking.m
//  RFNetworking
//
//  Created by 张涛 on 2020/7/9.
//

#import "RFNetworking.h"
#import "AFNetworkReachabilityManager.h"

@interface RFNetworking ()

@end

static RFNetworking *networking = nil;

@implementation RFNetworking

+(instancetype)shareInstance {
    if(networking == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            networking = [[RFNetworking alloc] init];
        });
    }
    return networking;
}

+ (void)startMonitoring{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
    
+ (BOOL)isNetReachable{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (void)networkReachabilityStatus:(RFNetworkReachabilityStatusBlock)block{
    if (block) {
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:{
                    block(RFNetworkReachabilityStatusNotReachable);
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWiFi:{
                    block(RFNetworkReachabilityStatusReachableViaWiFi);
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWWAN:{
                    block(RFNetworkReachabilityStatusReachableViaWWAN);
                    break;
                }
                default:{
                    block(RFNetworkReachabilityStatusUnknown);
                    break;
                }
            }
        }];
    }
}


+ (RFNetworkReachabilityStatus)currentNetworkReachabilityStatus{
    NSInteger status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    return status;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method URLString:(NSString *)URLString header:(NSDictionary *)header parameters:(id)parameters uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress completionBlock:(RFRequestCompletionBlock)completionBlock {
    NSError *error = nil;
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    while([URLString rangeOfString:@" "].length > 0) {
        URLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    self.request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&error];
    self.request.allHTTPHeaderFields = header;
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.manager dataTaskWithRequest:self.request uploadProgress:uploadProgress downloadProgress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *_error) {
        if(completionBlock) {
            NSStringEncoding stringEncoding = NSUTF8StringEncoding;
            NSString *encodingName = [dataTask.response.textEncodingName copy];
            if (encodingName) {
                CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName);
                if (encoding != kCFStringEncodingInvalidId) {
                    stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
                }
            }
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:stringEncoding];
            NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            completionBlock(dic, (error==nil&&err==nil));
        }
    }];
    [dataTask resume];
    return dataTask;
}

-(AFHTTPSessionManager *)manager {
    if(_manager == nil) {
        _manager = [[AFHTTPSessionManager alloc] init];
        AFHTTPResponseSerializer *serializer = [[AFHTTPResponseSerializer alloc] init];
        serializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
        serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
        _manager.responseSerializer = serializer;
    }
    return _manager;
}

@end
