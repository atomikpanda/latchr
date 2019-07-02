//
//  LTContext.m
//  latchr
//
//  Created by Bailey Seymour on 10/28/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import "LTContext.h"
#import "LTProcessor.h"
#import "LTCommentSection.h"
#import "LTHook.h"

@implementation LTContext

@synthesize processor=_processor;

- (instancetype)initWithProcessor:(LTProcessor *)processor
{
    self = [self init];
    
    if (self)
    {
        self.processor = processor;
        [self loadLatchFunctions];
    }
    
    return self;
}

- (void)loadLatchFunctions
{
    [self setExceptionHandler:^(JSContext *context, JSValue *exception){
        NSLog(@"js: %@", exception.toString);
    }];
    
    self[@"include"] = ^(NSString *path) {
        
        if (path.pathComponents.count == 1)
        {
            path = [[self.processor.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:path.lastPathComponent];
            
        }
        
        NSString *jsFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        if (jsFile)
            [[LTContext currentContext] evaluateScript:jsFile];
        
    };
    
    self[@"set_comment_sect"] = ^(LTCommentSection *sect) {
        [LTContext currentContext][@"comment_sect"] = sect;
    };
    
    self[@"hook"] = ^(NSString *className) {
        LTCommentSection *sect = (LTCommentSection *)[[LTContext currentContext][@"comment_sect"] toObject];
        NSString *tweakClassName = nil;
        
        NSRange atImp = [self.processor.tmpString rangeOfString:@"@implementation" options:NSBackwardsSearch range:NSMakeRange(0, sect.result.range.location+sect.result.range.length)];
        
        
        if (atImp.location != NSNotFound)
        {
            NSTextCheckingResult *wordClass = [[LTProcessor nextWordOrSignRegEx] firstMatchInString:self.processor.tmpString options:0 range:NSMakeRange(atImp.location, self.processor.tmpString.length-atImp.location)];
            
            tweakClassName = [self.processor.tmpString substringWithRange:[wordClass rangeAtIndex:1]];
        }
        int isClsMethod = 0;
        //            NSLog(@"%lu: hook this %@", sect.numberOfLinesInFile, class);
//        [self.processor.constructorBody appendFormat:@"__latch_hook(@selector(%@), \"%@\", \"%@\", %d);\n",
//         @"SEL_HERE", className, tweakClassName, isClsMethod];
        
        LTHook *hook = [[LTHook alloc] initWithSelectorName:@"SEL_HERE" className:className containerClass:tweakClassName isClassMethod:(BOOL)isClsMethod];
        [hook autorelease];
        
        [self.processor addHook:hook toGroup:self.processor.hookGroupName];
    };
    
    self[@"group"] = ^(JSValue *name) {
        
        if ([name isNull])
        {
            // group end
            self.processor.hookGroupName = nil;
        }
        else if ([name isString])
        {
            // in a group @name
            self.processor.hookGroupName = [name toString];
        }
        
    };

    self[@"init"] = ^(NSString *groupName) {
      if ([self.processor.hookGroups objectForKey:groupName])
      {
          NSMutableArray *hooksInGroup = [self.processor.hookGroups objectForKey:groupName];
          NSMutableString *codeText = [NSMutableString string];
          
          for (int i=0; hooksInGroup.count > i; i++)
          {
              LTHook *hook = [hooksInGroup objectAtIndex:i];
              [codeText appendFormat:@"%@\n", [hook codeString]];
          }
          
          LTCommentSection *sect = (LTCommentSection *)[[JSContext currentContext][@"comment_sect"] toObject];
          [self.processor.tmpString replaceCharactersInRange:[sect.result rangeAtIndex:0] withString:codeText];
      }
      else if (![groupName isEqualToString:@"_ungrouped"])
      {
          LTCommentSection *sect = (LTCommentSection *)[[JSContext currentContext][@"comment_sect"] toObject];
          NSString *message = [NSString stringWithFormat:@"#warning latch group `%@` not found ", groupName];
          [self.processor.tmpString insertString:message atIndex:[sect.result rangeAtIndex:0].location];
      }
    };
    
    
    self[@"log"] = ^(NSString *str) {
        NSLog(@"%@", str);
        LTCommentSection *sect = (LTCommentSection *)[[JSContext currentContext][@"comment_sect"] toObject];
        [self.processor.tmpString replaceCharactersInRange:[sect.result rangeAtIndex:1] withString:@"no comment!"];
    };
    
    self[@"latch_api_header"] = @"/usr/local/include/latch.h";
    self[@"class_prefix"] = @"";
    self[@"class_suffix"] = @"";
    self[@"compiled_class_prefix"] = @"";
}

- (void)dealloc
{
    self.processor = nil;
    
    [super dealloc];
}

@end
