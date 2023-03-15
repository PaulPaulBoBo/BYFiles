//
//  GBTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GBTaskReportBlock)(NSString *output, NSString *error);

/** Implements a simpler interface to 'NSTask'.
 实现“NSTask”的更简单接口。
 
 The class is designed to be completely reusable - it doesn't depend on any project specific object or external library, so you can simply copy the .h and .m files to another project and use it. To run a command instantiate the class and send 'runCommand:' message. You can pass in optional arguments if needed:
 该类被设计为完全可重用-它不依赖于任何特定于项目的对象或外部库，因此您可以简单地将.h和.m文件复制到另一个项目并使用它。要运行命令，请实例化类并发送“runCommand:”消息。如果需要，可以传入可选参数：
 
    GBTask *task = [GBTask task];
    [task runCommand:@"/bin/ls", nil]; 
    [task runCommand:@"/bin/ls", @"-l", @"-a", nil];
 
 If you want to be continuously notified when output or error is reported by the command (for example when you're running lenghtier commands and want to update user interface so the user is aware something is happening), use block method 'runCommand:arguments:block':
 如果您希望在命令报告输出或错误时（例如，当您正在运行lenghtier命令并希望更新用户界面以便用户知道发生了什么事情时）得到持续通知，请使用block方法“runCommand:arguments:block”：
 
    GBTask *task = [GBTask task];
    [task runCommand:@"/bin/ls" arguments:nil block:^(NSString *output, NSString *error) {
        // do something with output and error here...
        // 在这里处理输出和错误。。。
    }];
 
 You can affect how the output and error is reported through by changing the value of 'reportIndividualLines'.
 您可以通过更改“reportIndividualLines”的值来影响输出和错误的报告方式。
 
 You can reuse the same instance for any number of commands. After the command is finished, you can examine it's results through 'lastStandardOutput' and 'lastStandardError' properties. You can also check the actual command line string used for running the command through 'lastCommandLine'; this value includes the command and all parameters in a single string. If any parameter contains whitespace, it is embedded into quotes. All these properties work the same regardless of the way you run the command.
 可以对任意数量的命令重用同一实例。命令完成后，可以通过“lastStandardOutput”和“lastStandardError”属性检查其结果。您还可以通过“lastCommandLine”检查用于运行命令的实际命令行字符串；该值包括命令和单个字符串中的所有参数。如果任何参数包含空格，则将其嵌入引号中。无论您运行命令的方式如何，所有这些属性都是相同的。
  
 GBTask *task = [GBTask task];
 [task runCommand:@"/bin/ls", nil];
 [task runCommand:@"/bin/ls", @"-l", @"-a", nil] 。
  */
@interface GBTask :NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
/// 初始化与处理
///---------------------------------------------------------------------------------------

/** Returns autoreleased instance of the class.
 返回该类的自动释放实例。
 */
+ (id)task;

///---------------------------------------------------------------------------------------
/// @name Running commands
/// 运行命令
///---------------------------------------------------------------------------------------

/** Runs the given command with optional arguments.
 使用可选参数运行给定命令。
 
 The command is run synchronously; the application is halted until the command completes. All standard output and error from the command is copied to 'lastStandardOutput' and 'lastStandardError' properties. If you're interested in these values, check the values. The result of the method is determined from 'lastStandardError' value - if it contains non-empty string, error is reported, otherwise success. This should work for most commands, but if you use it on a command that emits errors to standard output, you should not rely solely on method result to determine success - you should instead parse the output string for indications of errors!
 命令同步运行；应用程序停止，直到命令完成。命令中的所有标准输出和错误都复制到“lastStandardOutput”和“lastStandardError”属性中。如果您对这些值感兴趣，请检查这些值。方法的结果由“lastStandardError”值确定-如果它包含非空字符串，则报告错误，否则成功。这应该适用于大多数命令，但如果您在向标准输出发出错误的命令上使用它，则不应仅依赖方法结果来确定是否成功，而是应解析输出字符串以获取错误指示！
 
 Internally, sending this message is equivalent to sending 'runCommand:arguments:block:' with wrapping all the arguments into an 'NSArray' and passing 'nil' for block!
 在内部，发送此消息相当于发送“runCommand:arguments:block：”，将所有参数包装到“NSArray”中，并为block传递“nil”！
  
 @param command Full path to the command to run.要运行的命令的完整路径。
 @param ... A comma separated list of arguments to substitute into the format.以逗号分隔的参数列表，用于将其替换成格式。
 @return Returns 'YES' if command succedded, 'NO' otherwise.如果命令成功执行，返回 "YES"，否则返回 "NO"。
 @exception NSException Thrown if the given command is invalid or cannot be started. NSException 如果给定的命令无效或不能启动，则抛出。
 @see runCommand:arguments:block:
 @see lastCommandLine
 @see lastStandardOutput
 @see lastStandardError
 */
- (BOOL)runCommand:(NSString *)command, ... NS_REQUIRES_NIL_TERMINATION;

/** Runs the given command and optional arguments using the given block to continuously report back any output or error received from the command while it's running.
 使用给定的块运行给定的命令和可选参数，以在命令运行时连续报告从命令接收的任何输出或错误。
 
 In contrast to 'runCommand:', this method uses the given block to report any string received on standard output or error, immediately when the command emits it. The block reports only the type of input received - if output is received only, error is 'nil' and vice versa. In addition, all strings are concatenated and copied into 'lastStandardOutput' and 'lastStandardError' respectively. However these properties are only useful after the method returns. To change the way reporting is handled, use 'reportIndividualLines' property. Note that if 'nil' is passed for block, the method simply reverts to normal handling and doesn't use block.
 与“runCommand:”不同，此方法使用给定的块在命令发出时立即报告标准输出或错误中接收到的任何字符串。该块仅报告接收到的输入类型-如果仅接收到输出，则错误为“nil”，反之亦然。此外，所有字符串都被连接并分别复制到“lastStandardOutput”和“lastStandardError”中。然而，这些属性只有在方法返回后才有用。要更改报告的处理方式，请使用“reportIndividualLines”属性。请注意，如果为块传递了'nil'，则该方法只会恢复到正常处理，而不使用块。
 
 The command is run synchronously; the application is halted until the command completes. All standard output and error from the command is copied to 'lastStandardOutput' and 'lastStandardError' properties. The result of the method is determined from 'lastStandardError' value - if it contains non-empty string, error is reported, otherwise success. This should work for most commands, but if you use it on a command that emits errors to standard output, you should not rely solely on method results to determine success - you should instea parse the output string for indications of errors!
 与“runCommand:”不同，此方法使用给定的块在命令发出时立即报告标准输出或错误中接收到的任何字符串。该块仅报告接收到的输入类型-如果仅接收到输出，则错误为“nil”，反之亦然。此外，所有字符串都被连接并分别复制到“lastStandardOutput”和“lastStandardError”中。然而，这些属性只有在方法返回后才有用。要更改报告的处理方式，请使用“reportIndividualLines”属性。请注意，如果为块传递了'nil'，则该方法只会恢复到正常处理，而不使用块。
 
 @param command Full path to the command to run. 要运行的命令的完整路径。
 @param arguments Array of arguments or 'nil' if no arguments are used. 参数数组，如果不使用参数则为'nil'。
 @param block Block to use for continuous reporting or 'nil' to not use block. 用于连续报告的区块或'nil'不使用区块。
 @return Returns 'YES' if command succedded, 'NO' otherwise. 如果命令成功执行，返回 "YES"，否则返回 "NO"。
 @exception NSException Thrown if the given command is invalid or cannot be started. NSException 如果给定的命令无效或不能启动，则抛出。
 @see runCommand:
 @see lastCommandLine
 @see lastStandardOutput
 @see lastStandardError
 */
- (BOOL)runCommand:(NSString *)command arguments:(NSArray *)arguments block:(GBTaskReportBlock)block;

/** Specifies whether output reported while the command is running is split to individual lines or not.
 指定命令运行时报告的输出是否拆分为单独的行。
 
 If set to 'YES', any output from standard output and error is first split to individual lines, then each line is reported separately. This can be useful in cases where multiple lines are reported in one block call, but we want to handle them line by line. Turning the option on does reduce runtime performance, so be sure to measure it. Defaults to 'NO'.
 如果设置为“是”，则标准输出和错误的任何输出都将首先拆分为单独的行，然后分别报告每一行。这在一个块调用中报告了多行，但我们希望逐行处理这些行的情况下非常有用。启用该选项确实会降低运行时性能，因此请确保对其进行测量。默认为“NO”。
 */
@property (nonatomic, assign) BOOL reportIndividualLines;

///---------------------------------------------------------------------------------------
/// @name Last results
/// 最后的结果
///---------------------------------------------------------------------------------------

/** Returns last command line including all arguments as passed to 'runCommand:' the last it was sent.
 返回最后一个命令行，包括上次发送时传递给“runCommand:”的所有参数。
  
 @see runCommand:
 @see runCommand:arguments:block:
 @see lastStandardOutput
 @see lastStandardError
 */
@property (readonly, strong) NSString *lastCommandLine;

/** Returns string emited to standard output pipe the last time 'runCommand:' was sent.
 返回上次发送“runCommand:”时发送到标准输出管道的字符串。
  
 @see runCommand:
 @see runCommand:arguments:block:
 @see lastStandardError
 */
@property (readonly, strong) NSString *lastStandardOutput;

/** Returns string emited to standard error pipe the last time 'runCommand:' was sent.
 返回最后一次发送'runCommand:'时向标准错误发出的字符串。
 
 @see runCommand:
 @see runCommand:arguments:block:
 @see lastStandardOutput
 */
@property (readonly, strong) NSString *lastStandardError;

@end
