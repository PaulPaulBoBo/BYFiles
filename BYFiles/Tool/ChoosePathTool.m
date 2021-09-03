//
//  ChoosePathTool.m
//  BYFiles
//
//  Created by Liu on 2021/9/2.
//

#import "ChoosePathTool.h"

@implementation ChoosePathTool

+(void)openPanelCanChooseFiles:(BOOL)canChooseFiles finish:(void(^)(NSString *path))finish {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    //是否可以创建文件夹
    panel.canCreateDirectories = !canChooseFiles;
    //是否可以选择文件夹
    panel.canChooseDirectories = !canChooseFiles;
    //是否可以选择文件
    panel.canChooseFiles = canChooseFiles;
    //是否可以多选
    [panel setAllowsMultipleSelection:canChooseFiles];
    //显示
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSInteger result) {
        //是否点击open 按钮
        if (result == NSModalResponseOK) {
            if(finish) {
                NSString *pathString = [panel.URLs.firstObject path];
                finish(pathString);
            }
        }
    }];
}

+(void)openFinderPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    [[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:) withObject:url afterDelay:0.11];
}

@end
