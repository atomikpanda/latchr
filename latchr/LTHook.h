//
//  LTHook.h
//  latchr
//
//  Created by Bailey Seymour on 10/29/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTHook : NSObject

- (instancetype)initWithSelectorName:(NSString *)selName className:(NSString *)clsName containerClass:(NSString *)tweakClsName isClassMethod:(BOOL)isClsMethod;
- (NSString *)codeString;

@property (nonatomic, copy) NSString *selectorName;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *containerClassName;
@property (nonatomic, assign) BOOL isClassMethod;

@end
