//  >>> include("latch_header.js");
//  tweak.m
//  latch
//
//  Created by Bailey Seymour on 3/24/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

@interface _NSWindow$ : NSObject
- (void)orig_setBackgroundColor:(NSColor*)backgroundColor;
- (id)orig_initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

// >>> group("Interface")
@implementation _NSWindow$ //no comment!

- (void)setBackgroundColor:(NSColor*)backgroundColor
{
    NSLog(@"alphaas are in ");
    
    [self orig_setBackgroundColor:[NSColor blueColor]];
}

//no comment!
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
    self = [self orig_initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];
    NSWindow *_self = (NSWindow *)self;
    
    [_self setAlphaValue:0.65];
    _self.titleVisibility = NSWindowTitleHidden;
    
    return self;
}

@end
// >>> group(null)


#pragma clang diagnostic pop

#import "latch.h"
__attribute__((constructor))
static void my_init()
{
    if (objc_getClass("NSWindow")) {__latch_hook(@selector(SEL_HERE), "NSWindow", "_NSWindow$", 0);
}
    // >>> init("_ungrouped")
    #warning latch group `existe` not found // >>> init("existe")
}

/*__latch_has_been_processed*/