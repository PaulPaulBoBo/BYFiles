//
//  ModuleSplitViewController.m
//  BYFiles
//
//  Created by Liu on 2023/3/16.
//

#import "ModuleSplitViewController.h"

@interface ModuleSplitViewController ()

@end

@implementation ModuleSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.splitView setVertical:YES];
    [self addSplitViewItem:self.leftItem];
    [self addSplitViewItem:self.rightItem];
}


/// MARK: lazy

- (NSSplitViewItem *)leftItem {
    if(_leftItem == nil) {
        _leftItem = [[NSSplitViewItem alloc] init];
        _leftItem.viewController = self.menuVC;
        _leftItem.canCollapse = NO;
    }
    return _leftItem;
}

- (NSSplitViewItem *)rightItem {
    if(_rightItem == nil) {
        _rightItem = [[NSSplitViewItem alloc] init];
        _rightItem.viewController = self.contentVC;
        _rightItem.canCollapse = NO;
    }
    return _rightItem;
}

- (SplitMenuViewController *)menuVC {
    if(_menuVC == nil) {
        _menuVC = [[SplitMenuViewController alloc] initWithNibName:@"SplitMenuViewController" bundle:[NSBundle mainBundle]];
        [_menuVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.greaterThanOrEqualTo(@150);
            make.width.lessThanOrEqualTo(@300);
        }];
    }
    return _menuVC;
}

- (SplitContentViewController *)contentVC {
    if(_contentVC == nil) {
        _contentVC = [[SplitContentViewController alloc] initWithNibName:@"SplitContentViewController" bundle:[NSBundle mainBundle]];
        [_contentVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.greaterThanOrEqualTo(@400);
        }];
    }
    return _contentVC;
}

@end
