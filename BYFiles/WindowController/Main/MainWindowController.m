//
//  MainWindowController.m
//  BYFiles
//
//  Created by Liu on 2023/3/16.
//

#import "MainWindowController.h"
#import "ModuleSplitViewController.h"
#import "Masonry.h"

@interface MainWindowController ()<NSSplitViewDelegate>

@property (nonatomic, strong) ModuleSplitViewController *splitVC;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window.contentView addSubview:self.splitVC.view];
    [self.splitVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.window.contentView);
    }];
}

/// MARK: NSSplitViewDelegate

/* 除法器索引是从零开始的，最上面（在水平拆分视图中）或最左边（垂直）的除法器的索引为0。
 如果子视图可以折叠，则返回YES，否则返回NO。如果拆分视图没有委托，或者其委托没有响应此消息，
 则拆分视图的任何子视图都不能折叠。如果拆分视图有一个委托，并且委托响应此消息，
 则当用户单击或双击拆分视图的一个分隔符时，它将至少发送两次，
 在分隔符两侧的每个子视图发送一次，并且可能在用户继续拖动分隔符时重新发送。
 如果子视图是可折叠的，则当用户将分隔符拖到使子视图成为最小大小的位置和使其成为零大小的位置之间超过一半时，
 NSSplitView的当前实现会将其折叠。如果用户将分隔符拖回到该点之后，子视图将变为未折叠。
 -splitView:contrainMinCoordinate:ofSubviewAt:和
 -splitView:contrainMaxCoordinat:ofSubviewAt:的注释描述了如何确定子视图的最小大小。
 折叠的子视图被隐藏，但被拆分视图保留。子视图的折叠不会改变其边界，
 但可能会将其边框设置为零像素高（在水平拆分视图中）或零像素宽（垂直）。
 */
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview NS_SWIFT_UI_ACTOR {
    return YES;
}

/* 如果因为用户双击了相邻的分隔符而应该折叠子视图，则返回YES。如果拆分视图有一个委托，
 并且该委托响应此消息，则当用户双击分隔符时，它将为分隔符之前的子视图发送一次，
 并为分隔符之后的子视图再次发送，但前提是委托在发送时返回YES-splitView:canCollapseSubview:用于有问题的子视图。
 当委托指示两个子视图都应该折叠时，NSSplitView的行为是未定义的。
 */
- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    return YES;
}


/* 给定分割视图的一个分隔器的建议最小允许位置，返回分隔器的最小允许位置。如果拆分视图没有委托，或者其委托没有响应此消息，则拆分视图的行为就好像它有一个委托仅通过返回建议的最小值来响应此消息一样。如果拆分视图有一个委托，并且委托响应此消息，则当用户开始拖动拆分视图的一个分隔符时，它将至少发送一次，并且可能在用户继续拖动分隔符时重新发送。
 响应此消息并返回大于建议最小位置的数字的代表有效地声明了相关除法器上方或左侧子视图的最小大小，最小大小是建议和返回的最小位置之间的差值。此最小大小仅对分隔符拖动操作有效，在该操作期间发送-splitView:contrainMinCoordinate:ofSubviewAt:消息。当委托通过返回小于建议最小值的数字来响应此消息时，NSSplitView的行为是未定义的。
 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return dividerIndex == 0 ? 100 : 200;
}

/* 给定分割视图的一个分隔器的建议最大允许位置，返回分隔器的最大允许位置。
 如果拆分视图没有委托，或者其委托没有响应此消息，则拆分视图的行为就好像它有一个委托仅通过返回建议的最大值来响应此消息一样。
 如果拆分视图有一个委托，并且委托响应此消息，则当用户开始拖动拆分视图的一个分隔符时，它将至少发送一次，并且可能在用户继续拖动分隔符时重新发送。
 响应此消息并返回小于建议最大位置的数字的代表有效地声明了相关分隔符下方或右侧子视图的最小大小，最小大小是建议和返回的最大位置之间的差值。
 此最小大小仅对分隔符拖动操作有效，在该操作期间发送-splitView:contrainMaxCoordinate:ofSubviewAt:消息。
 当委托通过返回大于建议最大值的数字来响应此消息时，NSSplitView的行为是未定义的。
 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return dividerIndex == 0 ? 300 : CGFLOAT_MAX;
}

/* 给定拆分视图的一个分隔符的建议位置，返回用户拖动时分隔符应该放置的位置。
 如果拆分视图没有委托，或者其委托没有响应此消息，则拆分视图的行为就像它有一个委托只通过返回建议位置来响应此消息一样。
 如果拆分视图有一个委托，并且该委托响应此消息，则当用户拖动拆分视图的一个分隔符时，它将被重复发送。
 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    return 200;
}

/* 假设拆分视图已调整大小，但尚未调整其子视图以适应新的大小，并且给定拆分视图的前一个大小，则调整子视图以满足拆分视图的新大小。
 如果拆分视图没有委托，或者其委托没有响应此消息，则拆分视图的行为就好像它有一个委托只通过向拆分视图发送-adjustSubviews消息来响应此消息一样。
 响应此信息的代表应调整未折叠子视图的框架，以便在考虑到新尺寸的情况下，准确地填充拆分视图，并在拆分视图之间留出分隔物的空间。
 分隔器的厚度可以通过发送分割视图a-dividerThickness消息来确定。
 */
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    NSLog(@"");
}


/* 假设拆分视图已经调整了大小，并且正在调整其子视图以适应新的大小，
 如果-adjustSubviews可以更改索引子视图的大小，则返回YES，否则返回NO-adjustSubview可以更改索引子视图的原点，
 而不管此方法返回什么-adjustSubview也可以调整不可调整的子视图的大小，以防止无效的子视图布局。
 如果拆分视图没有委托，或者其委托没有响应此消息，则拆分视图的行为就像它有一个委托在发送此消息时返回YES一样。
 */
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    return YES;
}

/* 假设拆分视图已经调整了大小，并且正在调整其子视图以适应新的大小，
 或者用户正在拖动分隔符，则返回“是”以允许将分隔符从拆分视图的边缘拖动或调整到不可见的位置。
 如果拆分视图没有委托，或者其委托没有响应此消息，则拆分视图的行为就像它有一个委托在发送此消息时返回no一样。
 */
- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    return YES;
}

/* 给定分割线的绘制帧（在分割视图边界建立的坐标系中），返回鼠标单击应启动分割线拖动的帧。
 如果拆分视图没有委托，或者其委托没有响应此消息，则拆分视图的行为就好像它有一个委托在发送此消息时返回proposedEffectiveRect一样。
 带有粗分隔线的拆分视图建议将绘制的框架作为有效框架。带有薄分隔符的拆分视图提出了一个比绘制的框架稍大的有效框架，以便于用户实际抓取分隔符。
 */
- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex {
    return NSMakeRect(0, 0, 0, 0);
}

/* 给定一个分隔符索引，返回一个额外的矩形区域（在分割视图边界建立的坐标系中），在该区域中单击鼠标也应启动分隔符拖动，
 或者NSZeroRect不添加分隔符。如果拆分视图没有代理，或者其代理没有响应此消息，则只有在分隔符的有效帧内单击鼠标才能启动分隔符拖动。
 */
- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
    return NSMakeRect(0, 0, 0, 0);
}

/* 按照代理已注册NSSplitViewDidResizeSubviewsNotification或NSSplitView WillResizeSubViewsNotification通知的方式进行响应，如下所述。
 拆分视图的行为不会受到委托是否有能力响应这些消息的明确影响，尽管委托可能会向拆分视图发送消息以响应这些消息。
 */
- (void)splitViewWillResizeSubviews:(NSNotification *)notification {
    NSLog(@"");
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    NSLog(@"");
}

-(NSView *)menuContentView {
    return self.splitVC.splitView.arrangedSubviews.firstObject;
}

-(NSView *)mainContentView {
    return self.splitVC.splitView.arrangedSubviews.lastObject;
}

/// MARK: lazy

- (ModuleSplitViewController *)splitVC {
    if(_splitVC == nil) {
        _splitVC = [[ModuleSplitViewController alloc] init];
    }
    return _splitVC;
}

@end
