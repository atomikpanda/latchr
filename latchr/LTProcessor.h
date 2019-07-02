//
//  LTProcessor.h
//  latchr
//
//  Created by Bailey Seymour on 10/22/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class LTContext, LTHook;

@interface LTProcessor : NSObject

+ (instancetype)processorWithFile:(NSString *)path;
- (instancetype)initWithFile:(NSString *)path;

- (NSString *)process:(BOOL *)failed;

+ (NSRegularExpression *)singleLineCommentRegEx;
+ (NSRegularExpression *)multiLineCommentRegEx;
+ (NSRegularExpression *)identifierRegEx;
+ (NSRegularExpression *)scriptPrefixRegEx;
+ (NSRegularExpression *)nextWordOrSignRegEx;

+ (NSUInteger)lineCountInString:(NSString *)string;
- (NSInteger)tmpStringOffset;
- (void)addHook:(LTHook *)hook toGroup:(NSString *)gname;

@property (nonatomic, copy, readonly) NSString *string;
@property (nonatomic, retain) NSMutableString *tmpString;
@property (nonatomic, retain) NSMutableString *constructorBody;
@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, retain) NSString *hookGroupName;
@property (nonatomic, retain) NSMutableDictionary *hookGroups;
@property (nonatomic, retain) LTContext *scriptContext;

@property (nonatomic, assign) BOOL latchEnabled;
@property (nonatomic, assign) BOOL alreadyBeenProcessed;

@end
