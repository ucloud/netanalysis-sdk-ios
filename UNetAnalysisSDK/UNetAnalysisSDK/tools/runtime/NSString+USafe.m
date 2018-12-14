//
//  NSString+USafe.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/29.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "NSString+USafe.h"
#import "NSObject+USafe.h"
#import <objc/runtime.h>

@implementation NSString (USafe)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("__NSCFConstantString") swizzleSelector:@selector(substringToIndex:) withSwizzledSelector:@selector(replace_substringToIndex:)];
            [objc_getClass("__NSCFConstantString") swizzleSelector:@selector(objectForKeyedSubscript:) withSwizzledSelector:@selector(replace_objectForKeyedSubscript:)];
        }
    });
}

- (NSString *)replace_substringToIndex:(NSUInteger)to {
    if (to > self.length) {
        return nil;
    }
    
    return [self replace_substringToIndex:to];
}

- (id)replace_objectForKeyedSubscript:(NSString *)key {
    return nil;
}

@end
