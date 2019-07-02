//
//  LTCommentSection.m
//  latchr
//
//  Created by Bailey Seymour on 10/22/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import "LTCommentSection.h"
#import "LTProcessor.h"

@implementation LTCommentSection

@synthesize commentText=_commentText, processor=_processor, result=_result, numberOfLinesInFile=_numberOfLinesInFile;
@synthesize origResult=_origResult;

- (instancetype)initWithResult:(NSTextCheckingResult *)result processor:(LTProcessor *)proc multiLine:(BOOL)isMultiLine
{
    self = [self init];
    
    if (self)
    {
        self.commentText = [[proc string] substringWithRange:[result rangeAtIndex:1]];
        self.result = result;
        _origResult = [result copy];
        self.processor = proc;
        self.multiLine = isMultiLine;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@" commentText:%@", self.commentText];
}

- (BOOL)isLatchComment
{
    if ([[self.commentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasPrefix:@">>>"])
    {
        return YES;
    }
    
    return NO;
}

- (NSTextCheckingResult *)result
{
    if (_origResult)
    {
        [self setResult:[_origResult resultByAdjustingRangesWithOffset:[self.processor tmpStringOffset]]];
    }
    
    return _result;
}

- (NSString *)commentText
{
    
    [self setCommentText:[self.processor.tmpString substringWithRange:[self.result rangeAtIndex:1]]];
    
    return _commentText;
}

- (NSUInteger)numberOfLinesInFile
{
    NSRange r = [self.result rangeAtIndex:1];
    return [LTProcessor lineCountInString:[self.processor.string substringWithRange:NSMakeRange(0, r.location+r.length)]];
}

- (NSString *)scriptString
{
    return [[LTProcessor scriptPrefixRegEx] stringByReplacingMatchesInString:self.commentText options:0 range:NSMakeRange(0, self.commentText.length) withTemplate:@""];
}

- (void)dealloc
{
    self.commentText = nil;
    self.result = nil;
    
    if (_origResult)
        [_origResult release];
    
    [super dealloc];
}

@end
