//
//  LoadFileWindowController.h
//  BYFiles
//
//  Created by Liu on 2021/9/3.
//

#import <Cocoa/Cocoa.h>
#import "DownloadFileTool.h"
#import "LogMsgTool.h"
#import "CombineFileTool.h"
#import "ConvertFileTool.h"
#import "ChoosePathTool.h"

#import "AFNetworking.h"
#import "BYFileTreeModel.h"

#import "NSFileManager+BY.h"
#import "NSData+BY.h"
#import "NSDate+BY.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoadFileWindowController : NSWindowController

@property (nonatomic, strong) BYFileTreeModel *fileModel;
@property (nonatomic, assign) NSInteger fileIndex;
@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, strong) NSString *categoryFolderPath;
@property (nonatomic, strong) NSString *tsFilesPath;
@property (nonatomic, copy) NSString *downloadingUrl;
@property (nonatomic, strong) NSProgress *progress;

@property (unsafe_unretained) IBOutlet NSTextView *msgTextView;
@property (weak) IBOutlet NSTextFieldCell *stateLabel;
@property (weak) IBOutlet NSProgressIndicator *progressView;

@end

NS_ASSUME_NONNULL_END
