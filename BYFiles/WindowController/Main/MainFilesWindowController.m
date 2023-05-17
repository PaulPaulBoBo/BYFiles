//
//  MainFilesWindowController.m
//  BYFiles
//
//  Created by Liu on 2022/11/11.
//

#import "MainFilesWindowController.h"
#import "BYCodeFormatWindowController.h"
#import "BYCodeImportFormatWindowController.h"
#import "BYCodeClassMapWindowController.h"
#import "BYCodeClassImportWindowController.h"
#import "BYCodeClassRelationWindowController.h"
#import "BYCodeMarkAddWindowController.h"
#import "BYCodeMarkFixWindowController.h"
#import "BYSourceCheckWindowController.h"
#import "BYFindConnectClassesWindowController.h"
#import "BYFindRouterWindowController.h"
#import "BYFindUnusedImportWindowController.h"
#import "BYAnalyzeCommonClassUseStateWindowController.h"
#import "MainWindowController.h"

@interface MainFilesWindowController ()<BYBaseWindowControllerProtocol>

/// 格式化不规范代码按钮
@property (weak) IBOutlet NSButton *codeFormatBtn;
/// 头文件引用格式化按钮
@property (weak) IBOutlet NSButton *codeImportFormatBtn;
/// 绘制类图按钮
@property (weak) IBOutlet NSButton *codeClassMapBtn;
/// 分析引用关系按钮
@property (weak) IBOutlet NSButton *codeClassImportBtn;
/// 分析类层次按钮
@property (weak) IBOutlet NSButton *codeClassRelationBtn;
/// 补全注释按钮
@property (weak) IBOutlet NSButton *codeMarkAddBtn;
/// 修复原有不规范注释按钮
@property (weak) IBOutlet NSButton *codeMarkFixBtn;
/// 检查无用的图片资源按钮
@property (weak) IBOutlet NSButton *checkImageBtn;
/// 查找相关类按钮
@property (weak) IBOutlet NSButton *findConnectClassesBtn;
/// 查找路由按钮
@property (weak) IBOutlet NSButton *findRouterBtn;
/// 查找无用import按钮
@property (weak) IBOutlet NSButton *findUnusedImportBtn;
/// 查找共同引用common组件中类的业务类按钮
@property (weak) IBOutlet NSButton *analyzeCommonClassUseStateBtn;

/// 格式化不规范代码控制器
@property (nonatomic, strong) BYCodeFormatWindowController *codeFormatVC;
/// 头文件引用格式化控制器
@property (nonatomic, strong) BYCodeImportFormatWindowController *codeImportFormatVC;
/// 绘制类图控制器
@property (nonatomic, strong) BYCodeClassMapWindowController *codeClassMapVC;
/// 分析引用关系控制器
@property (nonatomic, strong) BYCodeClassImportWindowController *codeClassImportVC;
/// 分析类层次控制器
@property (nonatomic, strong) BYCodeClassRelationWindowController *codeClassRelationVC;
/// 补全注释控制器
@property (nonatomic, strong) BYCodeMarkAddWindowController *codeMarkAddVC;
/// 修复原有不规范注释控制器
@property (nonatomic, strong) BYCodeMarkFixWindowController *codeMarkFixVC;
/// 检查无用图片资源控制器
@property (nonatomic, strong) BYSourceCheckWindowController *checkImageVC;
/// 查找相关类控制器
@property (nonatomic, strong) BYFindConnectClassesWindowController *findConnectClassesVC;
/// 查找所有路由
@property (nonatomic, strong) BYFindRouterWindowController *findRouterVC;
/// 查找无用的import
@property (nonatomic, strong) BYFindUnusedImportWindowController *unusedImport;
/// 查找共同引用common组件中类的业务类
@property (nonatomic, strong) BYAnalyzeCommonClassUseStateWindowController *analyzeCommonClassUseState;

@end

@implementation MainFilesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupBtnsAction];
//    MainWindowController *mainVC = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
//    [self showNewWindow:mainVC];
}

/// MARK: Btn Actions

-(void)setupBtnsAction {
    [self.codeFormatBtn setAction:@selector(clickCodeFormatBtn)];
    [self.codeImportFormatBtn setAction:@selector(clickCodeImportFormatBtn)];
    [self.codeClassMapBtn setAction:@selector(clickCodeClassMapBtn)];
    [self.codeClassImportBtn setAction:@selector(clickCodeClassImportBtn)];
    [self.codeClassRelationBtn setAction:@selector(clickCodeClassRelationBtn)];
    [self.codeMarkAddBtn setAction:@selector(clickCodeMarkAddBtn)];
    [self.codeMarkFixBtn setAction:@selector(clickCodeMarkFixBtn)];
    [self.checkImageBtn setAction:@selector(clickCheckImageBtn)];
    [self.findConnectClassesBtn setAction:@selector(clickFindConnectClassesBtn)];
    [self.findRouterBtn setAction:@selector(clickFindRouterBtn)];
    [self.findUnusedImportBtn setAction:@selector(clickUnusedImportBtn)];
    [self.analyzeCommonClassUseStateBtn setAction:@selector(clickAnalyzeCommonClassUseStateBtn)];
    
}

/// 格式化不规范代码
-(void)clickCodeFormatBtn {
    _codeFormatVC = nil;
    [self showNewWindow:self.codeFormatVC];
}

/// 头文件引用格式化
-(void)clickCodeImportFormatBtn {
    _codeImportFormatVC = nil;
    [self showNewWindow:self.codeImportFormatVC];
}

/// 绘制类图
-(void)clickCodeClassMapBtn {
    _codeClassMapVC = nil;
    [self showNewWindow:self.codeClassMapVC];
}

/// 分析引用关系
-(void)clickCodeClassImportBtn {
    _codeClassImportVC = nil;
    [self showNewWindow:self.codeClassImportVC];
}

/// 分析类层次
-(void)clickCodeClassRelationBtn {
    _codeClassRelationVC = nil;
    [self showNewWindow:self.codeClassRelationVC];
}

/// 补全注释
-(void)clickCodeMarkAddBtn {
    _codeMarkAddVC = nil;
    [self showNewWindow:self.codeMarkAddVC];
}

/// 修复原有不规范注释
-(void)clickCodeMarkFixBtn {
    _codeMarkFixVC = nil;
    [self showNewWindow:self.codeMarkFixVC];
}

/// 检查无用图片资源
-(void)clickCheckImageBtn {
    _checkImageVC = nil;
    [self showNewWindow:self.checkImageVC];
}

/// 找出相关类
-(void)clickFindConnectClassesBtn {
    _findConnectClassesVC = nil;
    [self showNewWindow:self.findConnectClassesVC];
}

/// 找出路由
-(void)clickFindRouterBtn {
    _findRouterVC = nil;
    [self showNewWindow:self.findRouterVC];
}

/// 找出无用import
-(void)clickUnusedImportBtn {
    _unusedImport = nil;
    [self showNewWindow:self.unusedImport];
}

/// 查找共同引用common组件中类的业务类
-(void)clickAnalyzeCommonClassUseStateBtn {
    _analyzeCommonClassUseState = nil;
    [self showNewWindow:self.analyzeCommonClassUseState];
}

-(void)showNewWindow:(NSWindowController *)windowVC {
    [windowVC showWindow:self];
    [windowVC.window center];
    [windowVC.window makeKeyWindow];
}

/// MARK: BYBaseWindowControllerProtocol

-(void)windowClose:(BYBaseWindowController *)window {
    
}

-(void)windowMiniaturize:(BYBaseWindowController *)window {
    
}

/// MARK: lazy

- (BYCodeFormatWindowController *)codeFormatVC {
    if(_codeFormatVC == nil) {
        _codeFormatVC = [[BYCodeFormatWindowController alloc] initWithWindowNibName:@"BYCodeFormatWindowController"];
        _codeFormatVC.windowsDelegate = self;
    }
    return _codeFormatVC;
}

- (BYCodeImportFormatWindowController *)codeImportFormatVC {
    if(_codeImportFormatVC == nil) {
        _codeImportFormatVC = [[BYCodeImportFormatWindowController alloc] initWithWindowNibName:@"BYCodeImportFormatWindowController"];
        _codeImportFormatVC.windowsDelegate = self;
    }
    return _codeImportFormatVC;
}

- (BYCodeClassMapWindowController *)codeClassMapVC {
    if(_codeClassMapVC == nil) {
        _codeClassMapVC = [[BYCodeClassMapWindowController alloc] initWithWindowNibName:@"BYCodeClassMapWindowController"];
        _codeClassMapVC.windowsDelegate = self;
    }
    return _codeClassMapVC;
}

- (BYCodeClassImportWindowController *)codeClassImportVC {
    if(_codeClassImportVC == nil) {
        _codeClassImportVC = [[BYCodeClassImportWindowController alloc] initWithWindowNibName:@"BYCodeClassImportWindowController"];
        _codeClassImportVC.windowsDelegate = self;
    }
    return _codeClassImportVC;
}

- (BYCodeClassRelationWindowController *)codeClassRelationVC {
    if(_codeClassRelationVC == nil) {
        _codeClassRelationVC = [[BYCodeClassRelationWindowController alloc] initWithWindowNibName:@"BYCodeClassRelationWindowController"];
        _codeClassRelationVC.windowsDelegate = self;
    }
    return _codeClassRelationVC;
}

- (BYCodeMarkAddWindowController *)codeMarkAddVC {
    if(_codeMarkAddVC == nil) {
        _codeMarkAddVC = [[BYCodeMarkAddWindowController alloc] initWithWindowNibName:@"BYCodeMarkAddWindowController"];
        _codeMarkAddVC.windowsDelegate = self;
    }
    return _codeMarkAddVC;
}

- (BYCodeMarkFixWindowController *)codeMarkFixVC {
    if(_codeMarkFixVC == nil) {
        _codeMarkFixVC = [[BYCodeMarkFixWindowController alloc] initWithWindowNibName:@"BYCodeMarkFixWindowController"];
        _codeMarkFixVC.windowsDelegate = self;
    }
    return _codeMarkFixVC;
}

- (BYSourceCheckWindowController *)checkImageVC {
    if(_checkImageVC == nil) {
        _checkImageVC = [[BYSourceCheckWindowController alloc] initWithWindowNibName:@"BYSourceCheckWindowController"];
    }
    return _checkImageVC;
}

- (BYFindConnectClassesWindowController *)findConnectClassesVC {
    if(_findConnectClassesVC == nil) {
        _findConnectClassesVC = [[BYFindConnectClassesWindowController alloc] initWithWindowNibName:@"BYFindConnectClassesWindowController"];
    }
    return _findConnectClassesVC;
}

- (BYFindRouterWindowController *)findRouterVC {
    if(_findRouterVC == nil) {
        _findRouterVC = [[BYFindRouterWindowController alloc] initWithWindowNibName:@"BYFindRouterWindowController"];
    }
    return _findRouterVC;
}

- (BYFindUnusedImportWindowController *)unusedImport {
    if(_unusedImport == nil) {
        _unusedImport = [[BYFindUnusedImportWindowController alloc] initWithWindowNibName:@"BYFindUnusedImportWindowController"];
    }
    return _unusedImport;
}

- (BYAnalyzeCommonClassUseStateWindowController *)analyzeCommonClassUseState {
    if(_analyzeCommonClassUseState == nil) {
        _analyzeCommonClassUseState = [[BYAnalyzeCommonClassUseStateWindowController alloc] initWithWindowNibName:@"BYAnalyzeCommonClassUseStateWindowController"];
    }
    return _analyzeCommonClassUseState;
}

@end
