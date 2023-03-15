//
//  GBTask+Finder.m
//  BYFiles
//
//  Created by Liu on 2022/12/20.
//

#import "GBTask+Finder.h"

@implementation GBTask (Finder)

+(void)mkdir:(NSString *)path completion:(void(^)(void))completion {
    GBTask *mkdirTask = [GBTask task];
    [mkdirTask runCommand:@"/bin/mkdir" arguments:@[path] block:^(NSString *output, NSString *error) {
        if(completion) {
            completion();
        }
    }];
}

+(void)rmdir:(NSString *)path completion:(void(^)(void))completion {
    GBTask *mkdirTask = [GBTask task];
    [mkdirTask runCommand:@"/bin/rmdir" arguments:@[@"-R", path] block:^(NSString *output, NSString *error) {
        if(completion) {
            completion();
        }
    }];
}

+(void)rmfile:(NSString *)path completion:(void(^)(void))completion {
    GBTask *mkdirTask = [GBTask task];
    [mkdirTask runCommand:@"/bin/rm" arguments:@[@"-f", path] block:^(NSString *output, NSString *error) {
        if(completion) {
            completion();
        }
    }];
}

+(void)copy:(NSString *)sourceFilePath orderFilePath:(NSString *)orderFilePath completion:(void(^)(void))completion {
    GBTask *cpTask = [GBTask task];
    [cpTask runCommand:@"/bin/cp" arguments:@[sourceFilePath, orderFilePath] block:^(NSString *output, NSString *error) {
        if(completion) {
            completion();
        }
    }];
}

+(void)move:(NSString *)sourceFilePath orderFilePath:(NSString *)orderFilePath completion:(void(^)(void))completion {
    GBTask *cpTask = [GBTask task];
    [cpTask runCommand:@"/bin/mv" arguments:@[sourceFilePath, orderFilePath] block:^(NSString *output, NSString *error) {
        if(completion) {
            completion();
        }
    }];
}



@end
