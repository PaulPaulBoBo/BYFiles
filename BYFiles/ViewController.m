//
//  ViewController.m
//  BYFiles
//
//  Created by Liu on 2021/8/28.
//

#import "ViewController.h"
#import "MainFilesWindowController.h"

@interface ViewController ()

@property (nonatomic, strong) MainFilesWindowController *mainVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)choosePath:(id)sender {
    [self.mainVC showWindow:self];
    [self.mainVC.window center];
    [self.mainVC.window makeKeyWindow];
}

/// MARK: lazy

- (MainFilesWindowController *)mainVC {
    if(_mainVC == nil) {
        _mainVC = [[MainFilesWindowController alloc] initWithWindowNibName:@"MainFilesWindowController"];
    }
    return _mainVC;
}

@end

