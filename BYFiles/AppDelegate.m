//
//  AppDelegate.m
//  BYFiles
//
//  Created by Liu on 2021/8/28.
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *paths = [defaults valueForKey:@"paths"];
    if(paths.count > 0) {
        NSString *path = paths.firstObject;
        NSURL *url = [NSURL URLWithString:path];
        NSData *bookmarkData = [url bookmarkDataWithOptions:(NSURLBookmarkCreationWithSecurityScope) includingResourceValuesForKeys:nil relativeToURL:nil error:nil];
        BOOL bookmarkDataIsStale = NO;
        NSURL *allowedUrl = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope|NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:NULL];
        @try {
            [allowedUrl startAccessingSecurityScopedResource];
        } @finally {
            [allowedUrl stopAccessingSecurityScopedResource];
        }
    }
//    NSString *path = NSHomeDirectory();
//    path = [NSBundle mainBundle].resourcePath;
//    NSLog(@"%@", path);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
