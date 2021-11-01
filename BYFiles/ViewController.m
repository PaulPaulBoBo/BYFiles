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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)choosePath:(id)sender {
    self.firstVC = nil;
    [self.firstVC.window orderFront:nil];
}

-(LoadFileWindowController *)firstVC {
    if(_firstVC == nil) {
        _firstVC = [[LoadFileWindowController alloc] initWithWindowNibName:@"LoadFileWindowController"];
    }
    return _firstVC;
}

@end

