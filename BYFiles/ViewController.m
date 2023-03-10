//
//  ViewController.m
//  BYFiles
//
//  Created by Liu on 2021/8/28.
//

#import "ViewController.h"
#import "LoadFileWindowController.h"

@interface ViewController ()

@property (nonatomic, strong) LoadFileWindowController *firstVC;
@property (nonatomic, strong) LoadFileWindowController *secVC;
@property (nonatomic, strong) LoadFileWindowController *thirVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)choosePath:(id)sender {
    self.firstVC = nil;
    self.secVC = nil;
    self.thirVC = nil;
    [self.firstVC.window orderFront:nil];
    [self.secVC.window orderFront:nil];
    [self.thirVC.window orderFront:nil];
}

-(LoadFileWindowController *)firstVC {
    if(_firstVC == nil) {
        _firstVC = [[LoadFileWindowController alloc] initWithWindowNibName:@"LoadFileWindowController"];
    }
    return _firstVC;
}

-(LoadFileWindowController *)secVC {
    if(_secVC == nil) {
        _secVC = [[LoadFileWindowController alloc] initWithWindowNibName:@"LoadFileWindowController"];
    }
    return _secVC;
}

-(LoadFileWindowController *)thirVC {
    if(_thirVC == nil) {
        _thirVC = [[LoadFileWindowController alloc] initWithWindowNibName:@"LoadFileWindowController"];
    }
    return _thirVC;
}

@end

