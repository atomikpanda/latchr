//
//  LTHook.m
//  latchr
//
//  Created by Bailey Seymour on 10/29/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import "LTHook.h"

@implementation LTHook

@synthesize selectorName=_selectorName, className=_className, containerClassName=_containerClassName, isClassMethod=_isClassMethod;

- (instancetype)initWithSelectorName:(NSString *)selName className:(NSString *)clsName containerClass:(NSString *)tweakClsName isClassMethod:(BOOL)isClsMethod;
{
    self = [self init];
    
    if (self)
    {
        self.selectorName = selName;
        self.className = clsName;
        self.containerClassName = tweakClsName;
        self.isClassMethod = isClsMethod;
    }
    
    return self;
}

- (NSString *)codeString
{
    return [NSString stringWithFormat:@"__latch_hook(@selector(%@), \"%@\", \"%@\", %d);",
            self.selectorName, self.className, self.containerClassName, self.isClassMethod];
}

- (void)dealloc
{
    self.selectorName = nil;
    self.className = nil;
    self.containerClassName = nil;
    
    [super dealloc];
}

@end
