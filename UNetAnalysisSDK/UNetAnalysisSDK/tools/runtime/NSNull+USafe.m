//
//  NSNull+Exception.m
//  UNetAnalysisSDK
//  
//  Created by ethan on 2018/10/29.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "NSNull+USafe.h"
#import "NSObject+USafe.h"
#import <objc/runtime.h>

@implementation NSNull (USafe)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("NSNull") swizzleSelector:@selector(length) withSwizzledSelector:@selector(replace_length)];
        }
    });
}

- (NSInteger)replace_length {
    return 0;
}

@end
