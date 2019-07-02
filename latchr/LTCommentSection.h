//
//  LTCommentSection.h
//  latchr
//
//  Created by Bailey Seymour on 10/22/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LTProcessor;

@interface LTCommentSection : NSObject

- (instancetype)initWithResult:(NSTextCheckingResult *)result processor:(LTProcessor *)proc multiLine:(BOOL)isMultiLine;
- (NSString *)scriptString;

@property (nonatomic, copy) NSString *commentText;
@property (nonatomic, assign) BOOL multiLine;
@property (nonatomic, retain) NSTextCheckingResult *result;
@property (nonatomic, copy, readonly) NSTextCheckingResult *origResult;
@property (nonatomic, assign) LTProcessor *processor;
@property (nonatomic, readonly) NSUInteger numberOfLinesInFile;
- (BOOL)isLatchComment;

@end
