//
//  LTContext.h
//  latchr
//
//  Created by Bailey Seymour on 10/28/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@class LTProcessor;

@interface LTContext : JSContext

- (instancetype)initWithProcessor:(LTProcessor *)processor;

@property (nonatomic, assign) LTProcessor *processor;

@end
