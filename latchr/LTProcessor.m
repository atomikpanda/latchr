//
//  LTProcessor.m
//  latchr
//
//  Created by Bailey Seymour on 10/22/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import "LTProcessor.h"
#import "LTCommentSection.h"
#import "LTContext.h"

@implementation LTProcessor

@synthesize string=_string, scriptContext=_scriptContext, filePath=_filePath, latchEnabled=_latchEnabled;
@synthesize tmpString=_tmpString, constructorBody=_constructorBody, hookGroupName=_hookGroupName, hookGroups=_hookGroups;

+ (NSRegularExpression *)singleLineCommentRegEx
{
    return [NSRegularExpression regularExpressionWithPattern:@"\\/\\/(.+)" options:0 error:nil];
}

+ (NSRegularExpression *)multiLineCommentRegEx
{
    return [NSRegularExpression regularExpressionWithPattern:@"\\/\\*([\\s\\S]*?)\\*\\/" options:0 error:nil];
}

+ (NSRegularExpression *)identifierRegEx
{
    return [NSRegularExpression regularExpressionWithPattern:@"\\!(.+)" options:0 error:nil];
}

+ (NSRegularExpression *)scriptPrefixRegEx
{
    return [NSRegularExpression regularExpressionWithPattern:@"((?:\\s|\\n)*>>>(?:\\s|\\n)*)" options:0 error:nil];
}

+ (NSRegularExpression *)nextWordOrSignRegEx
{
    return [NSRegularExpression regularExpressionWithPattern:@"\\s((?:[A-Za-z_]|\\$)+)" options:0 error:nil];
}

- (instancetype)initWithFile:(NSString *)path
{
    self = [self init];
    
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    if (self)
    {
        if (fileContents)
            [self setString:fileContents];
        
        _filePath = [path copy];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.hookGroupName = nil;
        self.hookGroups = [NSMutableDictionary dictionary];
        
        self.constructorBody = [NSMutableString string];
        self.scriptContext = [[[LTContext alloc] initWithProcessor:self] autorelease];
    }
    
    return self;
}

+ (NSUInteger)lineCountInString:(NSString *)string
{
    
//    NSUInteger numberOfLines, index, stringLength = [string length];
//    
//    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
//        index = NSMaxRange([string lineRangeForRange:NSMakeRange(index, 0)]);
//    
//    return numberOfLines +1; // idx started at 0
    return [[string componentsSeparatedByString:@"\n"] count];

}

- (NSInteger)tmpStringOffset
{
    return (self.tmpString.length - self.string.length);
}

- (void)setString:(NSString *)string
{
    [self setTmpString:[NSMutableString stringWithString:string]];
    _string = [string copy];
}

- (NSString *)process:(BOOL *)failed
{
    if ([self alreadyBeenProcessed])
    {
        *failed = YES;
        return nil;
    }
    
    
    NSMutableArray *comments = [NSMutableArray array];
    
    NSArray *singleCmts = [[LTProcessor singleLineCommentRegEx] matchesInString:self.tmpString options:0 range:NSMakeRange(0, self.tmpString.length)];
    
    NSArray *multiCmts = [[LTProcessor multiLineCommentRegEx] matchesInString:self.tmpString options:0 range:NSMakeRange(0, self.tmpString.length)];
    
    for (int i=0; singleCmts.count > i; i++)
    {
        LTCommentSection *sect = [[[LTCommentSection alloc] initWithResult:[singleCmts objectAtIndex:i] processor:self multiLine:NO] autorelease];
        
        [comments addObject:sect];
    }
    
    for (int i=0; multiCmts.count > i; i++)
    {
        LTCommentSection *sect = [[[LTCommentSection alloc] initWithResult:[multiCmts objectAtIndex:i] processor:self multiLine:YES] autorelease];
        
        [comments addObject:sect];
    }
    
    // sort comments by line
    [comments sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = @([(LTCommentSection *)a numberOfLinesInFile]);
        NSNumber *second = @([(LTCommentSection *)b numberOfLinesInFile]);
        
        return [first compare:second];
    }];
    
    for (int i=0; comments.count > i; i++)
    {
        LTCommentSection *sect = [comments objectAtIndex:i];
        
        if ([sect scriptString] && [sect scriptString].length > 0 && [sect isLatchComment])
        {
            [self.scriptContext[@"set_comment_sect"] callWithArguments:@[sect]];
            [self.scriptContext evaluateScript:sect.scriptString];
            // modifications below
//            [self.tmpString replaceCharactersInRange:sect.result.range withString:@"///s"];
        }
    }
    
    if (self.latchEnabled)
    {
        
    }
    
    NSLog(@"ello to: %@", [self.scriptContext[@"ello"] toString]);
    
    NSString *h = [self latchAPIHeader];
    
    BOOL alreadyBeen = [self alreadyBeenProcessed];
    
    NSString *con = [self constructorFunctionText];
    
    [self.tmpString appendString:@"\n/*__latch_has_been_processed*/"];

    
    return self.tmpString;
}

- (void)makeBackup
{
    // copy self.filePath to self.filePath.latch.origextension
    if (!self.alreadyBeenProcessed) return;
    
    NSString *origExt = [self.filePath pathExtension];
    
    NSString *start = self.filePath;
    NSString *dest = [[self.filePath stringByDeletingPathExtension] stringByAppendingFormat:@".latch.%@", origExt];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dest])
        [[NSFileManager defaultManager] removeItemAtPath:dest error:nil];
    
    [[NSFileManager defaultManager] copyItemAtPath:start toPath:dest error:nil];
}

- (void)moveBackupBack
{
    // copy self.filePath.latch.origextension to self.filePath
    NSString *origExt = [self.filePath pathExtension];
    
    NSString *start = [[self.filePath stringByDeletingPathExtension] stringByAppendingFormat:@".latch.%@", origExt];
    NSString *dest = self.filePath;
    
    [[NSFileManager defaultManager] copyItemAtPath:start toPath:dest error:nil];
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:start])
//        [[NSFileManager defaultManager] removeItemAtPath:start error:nil];
}

- (BOOL)latchEnabled
{
    JSValue *val = self.scriptContext[@"latch_enabled"];
    if ([val isBoolean])
    {
        return [val toBool];
    }
    
    return NO;
}

- (NSString *)latchAPIHeader
{
    NSString *header = nil;
    NSString *hPath = [self.scriptContext[@"latch_api_header"] toString];
    
    if (hPath)
        header = [NSString stringWithContentsOfFile:hPath encoding:NSUTF8StringEncoding error:nil];
    
    if (!header)
    {
        header = [NSString stringWithFormat:@"#error latch API header not found at `%@`", hPath];
    }
    
    return header;
}

+ (instancetype)processorWithFile:(NSString *)path
{
    return [[[self alloc] initWithFile:path] autorelease];
}

- (BOOL)alreadyBeenProcessed
{
    if ([self.string rangeOfString:@"/*__latch_has_been_processed*/" options:NSBackwardsSearch].location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

- (NSString *)constructorFunctionText
{
    NSString *declaration = [NSString stringWithFormat:@"__attribute__((constructor))\nstatic void __latch_local_init_%lu()", (unsigned long)[self.filePath hash]];
    NSString *cfn = [NSString stringWithFormat:@"%@\n{\n%@\n}", declaration, self.constructorBody];
    
    return cfn;
}

- (void)addHook:(LTHook *)hook toGroup:(NSString *)gname
{
    if (gname == nil) gname = @"_ungrouped";
    
    NSMutableArray *hooks = [self.hookGroups objectForKey:gname];
    
    if (!hooks)
    {
        [self.hookGroups setObject:[NSMutableArray array] forKey:gname];
        hooks = [self.hookGroups objectForKey:gname];
    }
    
    [hooks addObject:hook];
    
}

- (void)dealloc
{
    if (_string)
        [_string release];
    
    if (_hookGroupName)
        [_hookGroupName release];
    
    if (_hookGroups)
        [_hookGroups release];
    
    if (_tmpString)
        [_tmpString release];
    
    if (_constructorBody)
        [_constructorBody release];
    
    if (_filePath)
        [_filePath release];
    
    if (_scriptContext)
        [_scriptContext release];
    
    [super dealloc];
}

@end
