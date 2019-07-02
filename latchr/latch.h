//
//  latch.h
//  latchr
//
//  Created by Bailey Seymour on 10/25/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#ifndef latch_h
#define latch_h

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

static inline void __latch_hook(SEL selector, const char *classname, const char *tweakclassname, int classMethod)
{
    Method hookMethod = (classMethod==1) ? class_getClassMethod(objc_getClass(tweakclassname), selector) : class_getInstanceMethod(objc_getClass(tweakclassname), selector);
    
    Method targetMethod = (classMethod==1) ? class_getClassMethod(objc_getClass(classname), selector) : class_getInstanceMethod(objc_getClass(classname), selector);
    
    class_addMethod(objc_getClass(classname), NSSelectorFromString([NSString stringWithFormat:@"orig_%@", NSStringFromSelector(selector)]), method_getImplementation(targetMethod), method_getTypeEncoding(targetMethod));
    
    if (hookMethod && targetMethod) method_setImplementation(targetMethod, method_getImplementation(hookMethod));
    
}

#endif /* latch_h */
