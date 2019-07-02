//
//  main.cpp
//  latchr
//
//  Created by Bailey Seymour on 10/19/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#include <iostream>
#import "LTProcessor.h"

int main(int argc, const char * argv[])
{
    LTProcessor *proc = [LTProcessor processorWithFile:@"/Users/baileyseymour/Developer/Projects/latchr/latchr/example.m"];
    [proc makeBackup];
    BOOL didFail;
    NSString *finalRe = [proc process:&didFail];
    
    if (didFail && [proc alreadyBeenProcessed])
    {
        NSLog(@"failed: file already processed!");
//        return 1;
    }
    
    [finalRe writeToFile:proc.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [proc moveBackupBack];
    
    NSLog(@"latch is %d", proc.latchEnabled);
    
    NSLog(@"\n%@", finalRe);
    
    return 0;
}
