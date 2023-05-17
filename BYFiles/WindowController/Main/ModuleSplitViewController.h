//
//  ModuleSplitViewController.h
//  BYFiles
//
//  Created by Liu on 2023/3/16.
//

#import <Cocoa/Cocoa.h>
#import "SplitMenuViewController.h"
#import "SplitContentViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModuleSplitViewController : NSSplitViewController

@property (nonatomic, strong) NSSplitViewItem *leftItem;
@property (nonatomic, strong) NSSplitViewItem *rightItem;

@property (nonatomic, strong) SplitMenuViewController *menuVC;
@property (nonatomic, strong) SplitContentViewController *contentVC;

@end

NS_ASSUME_NONNULL_END
