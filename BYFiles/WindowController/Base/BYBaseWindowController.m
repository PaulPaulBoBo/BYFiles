//
//  BYBaseWindowController.m
//  BYFiles
//
//  Created by Liu on 2022/11/11.
//

#import "BYBaseWindowController.h"

@interface BYBaseWindowController ()

@end

@implementation BYBaseWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self updateCheckState];
    [[GeneralConfig shareInstance] updateSetting:self.config];
    [self addNotification];
}

-(void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillMiniaturize:) name:NSWindowWillMiniaturizeNotification object:nil];
}

-(void)windowWillClose:(NSNotification *)notification {
    if(self.windowsDelegate && [self.windowsDelegate respondsToSelector:@selector(windowClose:)]) {
        [self.windowsDelegate windowClose:self];
    }
}

-(void)windowWillMiniaturize:(NSNotification *)notification {
    if(self.windowsDelegate && [self.windowsDelegate respondsToSelector:@selector(windowMiniaturize:)]) {
        [self.windowsDelegate windowMiniaturize:self];
    }
}

-(void)choosePath {
    [self.tool.files removeAllObjects];
    __weak typeof(self) weakSelf = self;
    [ChoosePathTool openPanelCanChooseFiles:NO finish:^(NSArray * _Nonnull paths) {
        if(paths == nil || paths.count == 0) {
            return;
        }
        NSString *path = paths.firstObject;
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"已选择路径：%@", path] tag:[self className] toTextView:strongSelf.msgTextView];
        [LogMsgTool updateMsg:@"开始读取文件目录" tag:[self className] toTextView:strongSelf.msgTextView];
        
        [strongSelf.tool findFileInPath:path];
        strongSelf.tool.path = path;
        strongSelf.tool.fileCount = strongSelf.tool.files.count;
        [LogMsgTool updateMsg:[NSString stringWithFormat:@"读取文件目录完成，共%@个文件将要被处理", @(strongSelf.tool.files.count)] tag:[self className] toTextView:strongSelf.msgTextView];
        
        [[GeneralConfig shareInstance] updateSetting:@{}];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.pathTextView.string = path;
            [strongSelf choosePathFinish];
        });
    }];
}

/// 选择路径完成
-(void)choosePathFinish {
    
}

-(void)chooseFilss {
    __weak typeof(self) weakSelf = self;
    [ChoosePathTool openPanelCanChooseFiles:YES canMultipleSelection:YES finish:^(NSArray * _Nonnull paths) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.filePaths addObjectsFromArray:paths];
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.pathTextView.string = [strongSelf.filePaths componentsJoinedByString:@"\n"];
            [LogMsgTool updateMsg:[paths componentsJoinedByString:@"\n"] tag:[self className] toTextView:strongSelf.msgTextView];
        });
    }];
}

-(void)clearPaths {
    self.pathTextView.string = @"";
}

-(void)start {
    [self updateCheckState];
    [[GeneralConfig shareInstance] updateSetting:self.config];
    [self.tool start];
}

-(void)setupViews {
    for (NSView *view in [self.boxView.contentView subviews]) {
        if(view.subviews.count == 2) {
            if([[view.subviews.firstObject subviews].firstObject isKindOfClass:[NSStackView class]]) {
                self.btnBgView = view.subviews.lastObject;
                NSView *topBtnBgView = [view.subviews.firstObject subviews].firstObject;
                for (NSButton *btn in [topBtnBgView subviews]) {
                    if([btn isKindOfClass:[NSButton class]]) {
                        if([btn.title isEqual:@"全选"]) {
                            [btn setAction:@selector(clickCheckAllBtns:)];
                        } else if([btn.title isEqual:@"取消全选"]) {
                            [btn setAction:@selector(clickCheckNoneBtns:)];
                        } else {
                            [btn setAction:@selector(clickCheckReverseBtns:)];
                        }
                    }
                }
            } else {
                if([view.subviews.firstObject isKindOfClass:[NSScrollView class]]) {
                    NSScrollView *scrollView = view.subviews.firstObject;
                    self.pathTextView = [[scrollView subviews].firstObject subviews].lastObject;
                    NSView *actionBtnBgView = view.subviews.lastObject;
                    for (NSButton *btn in [actionBtnBgView subviews]) {
                        if([btn.title isEqual:@"choose folder"]) {
                            [btn setAction:@selector(choosePathAction:)];
                        } else if([btn.title isEqual:@"choose files"]) {
                            [btn setAction:@selector(chooseFilseAction:)];
                        } else if([btn.title isEqual:@"clear paths"]) {
                            [btn setAction:@selector(clearPathsAction:)];
                        } else if([btn.title isEqual:@"start"]) {
                            [btn setAction:@selector(startAction:)];
                        }
                    }
                }
            }
        } else if(view.subviews.count == 3) {
            for (NSView *subView in view.subviews) {
                if([subView isKindOfClass:[NSScrollView class]]) {
                    self.msgTextScrollView = (NSScrollView *)subView;
                    self.msgTextView = [[subView subviews].firstObject subviews].lastObject;
                } else if([subView isKindOfClass:[NSTextField class]]) {
                    self.stateLabel = (NSTextField *)subView;
                } else if([subView isKindOfClass:[NSProgressIndicator class]]) {
                    self.progressView = (NSProgressIndicator *)subView;
                }
            }
        }
    }
}

-(void)clickCheckAllBtns:(NSButton *)btn {
    btn.state = NSControlStateValueOn;
    [self updateCheckAllBtns:self.btnBgView.subviews];
}

-(void)clickCheckNoneBtns:(NSButton *)btn {
    btn.state = NSControlStateValueOff;
    [self updateCheckNoneBtns:self.btnBgView.subviews];
}

-(void)clickCheckReverseBtns:(NSButton *)btn {
    [self updateCheckReverseBtns:self.btnBgView.subviews];
}

-(void)choosePathAction:(NSButton *)sender {
    [self choosePath];
}

-(void)chooseFilseAction:(NSButton *)sender {
    [self chooseFilss];
}

-(void)clearPathsAction:(NSButton *)sender {
    [self clearPaths];
}

-(void)startAction:(NSButton *)sender {
    [self start];
}

/// 全选按钮
/// @param senders 按钮数组
-(void)updateCheckAllBtns:(NSArray *)senders {
    for (int i = 0; i < senders.count; i++) {
        NSButton *btn = senders[i];
        if(btn) {
            btn.state = NSControlStateValueOn;
        }
    }
}

/// 取消全选
/// @param senders 按钮数组
-(void)updateCheckNoneBtns:(NSArray *)senders {
    for (int i = 0; i < senders.count; i++) {
        NSButton *btn = senders[i];
        if(btn) {
            btn.state = NSControlStateValueOff;
        }
    }
}

/// 反选多个按钮
/// @param senders 按钮数组
-(void)updateCheckReverseBtns:(NSArray *)senders {
    for (int i = 0; i < senders.count; i++) {
        NSButton *btn = senders[i];
        if(btn.state == NSControlStateValueOn) {
            btn.state = NSControlStateValueOff;
        } else {
            btn.state = NSControlStateValueOn;
        }
    }
}

/// 更新所有复选按钮状态到配置
-(void)updateCheckState {
    NSMutableArray *btns = [NSMutableArray new];
    [btns addObjectsFromArray:[self loadBtnsInView:self.btnBgView]];
    for (int i = 0; i < btns.count; i++) {
        [self updateBtn:btns[i]];
    }
}

/// 获取视图中的所有按钮
/// @param view 背景视图
-(NSArray *)loadBtnsInView:(NSView *)view {
    if(view == nil || view.subviews.count == 0) {
        return @[];
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < view.subviews.count; i++) {
        NSView *subView = view.subviews[i];
        if([subView isKindOfClass:[NSButton class]]) {
            [arr addObject:subView];
        }
    }
    return [arr copy];
}

/// 更新单个复选按钮选中状态到配置 key取tag
/// @param sender 复选按钮
-(void)updateBtn:(NSButton *)sender {
    if(sender == nil || sender.tag == 0) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%@", @(sender.tag)];
    [self.config setValue:sender.state == NSControlStateValueOn?@"1":@"0" forKey:key];
}

/// 点击check btn 改变选中状态
/// @param btn check btn
-(void)clickSelectBtn:(NSButton *)btn {
    if(btn.state == NSControlStateValueOn) {
        btn.state = NSControlStateValueOn;
    } else {
        btn.state = NSControlStateValueOff;
    }
}

/// MARK: lazy

-(NSMutableDictionary *)config {
    if(_config == nil) {
        _config = [[NSMutableDictionary alloc] init];
    }
    return _config;
}

- (NSMutableArray *)filePaths {
    if(_filePaths == nil) {
        _filePaths = [[NSMutableArray alloc] init];
    }
    return _filePaths;
}

- (NSBox *)boxView {
    if(_boxView == nil) {
        _boxView = [self.window.contentView subviews].firstObject;
    }
    return _boxView;
}

@end
