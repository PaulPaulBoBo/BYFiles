//
//  ChoosePathTool.m
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import "ChoosePathTool.h"

@implementation ChoosePathTool

+(void)openPanelCanChooseFiles:(BOOL)canChooseFiles finish:(void(^)(NSArray *paths))finish {
    [ChoosePathTool openPanelCanChooseFiles:canChooseFiles canMultipleSelection:NO finish:finish];
}

+ (void)saveDefaultFileURL:(NSURL *)pathURL {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [defaults arrayForKey:@"paths"];
    NSMutableSet *paths = [NSMutableSet new];
    if(arr != nil) {
        [paths addObjectsFromArray:arr];
    }
    [paths addObject:pathURL.absoluteString];
    [defaults setValue:[paths allObjects] forKey:@"paths"];
    [defaults synchronize];
}

+(void)openPanelCanChooseFiles:(BOOL)canChooseFiles canMultipleSelection:(BOOL)canMultipleSelection finish:(void(^)(NSArray *paths))finish {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    //是否可以创建文件夹
    panel.canCreateDirectories = !canChooseFiles;
    //是否可以选择文件夹
    panel.canChooseDirectories = !canChooseFiles;
    //是否可以选择文件
    panel.canChooseFiles = canChooseFiles;
    //是否可以多选
    [panel setAllowsMultipleSelection:canMultipleSelection];
    //显示
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSInteger result) {
        //是否点击open 按钮
        if (result == NSModalResponseOK) {
            if(finish) {
                NSMutableArray *mArr = [NSMutableArray new];
                for (NSURL *pathURL in panel.URLs) {
                    [mArr addObject:[pathURL path]];
                    [self saveDefaultFileURL:pathURL];
                }
                
                finish([mArr copy]);
            }
        }
    }];
}

+(BOOL)accessFileURL:(NSURL *)fileURL withBlock:(void(^)(void))block {
    [self saveDefaultFileURL:fileURL];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *bookmarkData = [defaults valueForKey:fileURL.path];
    if(bookmarkData) {
        BOOL bookMarkIsStale = NO;
        NSError *error = nil;
        NSURL *allowURL = [NSURL URLByResolvingBookmarkData:bookmarkData options:(NSURLBookmarkResolutionWithoutUI|NSURLBookmarkResolutionWithSecurityScope) relativeToURL:nil bookmarkDataIsStale:&bookMarkIsStale error:&error];
        if(bookMarkIsStale) {
            [self persistPermissionURL:fileURL];
        }
        @try {
            [allowURL startAccessingSecurityScopedResource];
            if(block) {
                block();
            }
            return YES;
        } @finally {
            [allowURL stopAccessingSecurityScopedResource];
        }
    } else {
        [self persistPermissionURL:fileURL];
    }
    return NO;
}

+(void)persistPermissionURL:(NSURL *)url {
    [self saveDefaultFileURL:url];
    NSError *error = nil;
    NSData *bookmarkData = [url bookmarkDataWithOptions:(NSURLBookmarkCreationWithSecurityScope) includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    if(bookmarkData == nil) {
        bookmarkData = [NSURL bookmarkDataWithContentsOfURL:url error:&error];
    }
    if(bookmarkData) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:bookmarkData forKey:url.path];
        [defaults synchronize];
    }
}

+(void)openFinderPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    [[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:) withObject:url afterDelay:0.11];
}

@end
