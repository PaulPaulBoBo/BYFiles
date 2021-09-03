//
//  RBasePresenter.m
//  RApp
//
//  Created by l on 2021/3/13.
//

#import "RBasePresenter.h"
#import "RFNetworking.h"

@interface RBasePresenter()

@end

@implementation RBasePresenter

+(void)requestUrl:(NSString *)url param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail {
    [RBasePresenter loadUrl:url methodType:(RRequestMethodGET) param:param requestFinish:requestFinish requestFail:requestFail];
}

+ (void)requestUrl:(NSString *)url param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail parseData:(parseData)parseData {[RBasePresenter loadUrl:url methodType:(RRequestMethodGET) param:param requestFinish:requestFinish requestFail:requestFail parseData:parseData];
}

+(void)postUrl:(NSString *)url param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail {
    [RBasePresenter loadUrl:url methodType:(RRequestMethodPOST) param:param requestFinish:requestFinish requestFail:requestFail];
}

+ (void)postUrl:(NSString *)url param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail parseData:(parseData)parseData {
    [RBasePresenter loadUrl:url methodType:(RRequestMethodPOST) param:param requestFinish:requestFinish requestFail:requestFail parseData:parseData];
}



+(void)loadUrl:(NSString *)url methodType:(RRequestMethod)methodType param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail {
    [self loadUrl:url methodType:methodType param:param requestFinish:requestFinish requestFail:requestFail parseData:nil];
}

+(void)loadUrl:(NSString *)url methodType:(RRequestMethod)methodType param:(NSDictionary *)param requestFinish:(RequestFinish)requestFinish requestFail:(RequestFail)requestFail parseData:(parseData)parseData {
    RFNetworking *netWorking = [RFNetworking shareInstance];
    NSString *method = [self convertMethodType:methodType];
    NSString *urlStr = url;
    [netWorking dataTaskWithHTTPMethod:method URLString:urlStr header:@{} parameters:param uploadProgress:nil completionBlock:^(NSDictionary * _Nonnull response, BOOL isSuccess) {
#ifdef DEBUG
        NSLog(@"__request:%@\n%@\n__respons:%@", urlStr, param, response);
#endif
        [self dealCompletionData:isSuccess parseData:parseData requestFail:requestFail requestFinish:requestFinish response:response url:url];
    }];
}

+ (NSString *)convertMethodType:(RRequestMethod)methodType {
    NSString *method = @"GET";
    switch (methodType) {
        case RRequestMethodGET:
            method = @"GET";
            break;
        case RRequestMethodPOST:
            method = @"POST";
            break;
        case RRequestMethodPUT:
            method = @"PUT";
            break;
        case RRequestMethodDELETE:
            method = @"DELETE";
            break;
    }
    return method;
}

+ (void)dealCompletionData:(BOOL)isSuccess parseData:(parseData)parseData requestFail:(RequestFail)requestFail requestFinish:(RequestFinish)requestFinish response:(NSDictionary * _Nonnull)response url:(NSString *)url {
    NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
    if([code isEqual:@"5000"]) {
        if(requestFail) {
            requestFail(@"请求失败");
        }
        return;
    }
    
    if([code isEqual:@"5105"] || [code isEqual:@"5109"] || [code isEqual:@"401"]) {
        if(requestFail) {
            requestFail(response[@"message"]?response[@"message"]:@"请求失败");
        }
    } else {
        if (isSuccess) {
            if(requestFinish) {
                if([response isKindOfClass:[NSDictionary class]]) {
                    requestFinish(response, response[@"message"], YES);
                    return;
                }
            }
            
            if(requestFail) {
                requestFail(response[@"message"] ? response[@"message"] : @"请求失败");
            }
        } else {
            if(requestFail) {
                requestFail(@"请求失败");
            }
        }
    }
}

@end
