//
//  NSMutableString+USafe.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/29.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "NSMutableString+USafe.h"
#import <objc/runtime.h>
#import "NSObject+USafe.h"

@implementation NSMutableString (USafe)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("__NSCFString") swizzleSelector:@selector(replaceCharactersInRange:withString:) withSwizzledSelector:@selector(alert_replaceCharactersInRange:withString:)];
            [objc_getClass("__NSCFString") swizzleSelector:@selector(objectForKeyedSubscript:) withSwizzledSelector:@selector(replace_objectForKeyedSubscript:)];
        }
    });
}

- (void)alert_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    if ((range.location + range.length) > self.length) {
        NSLog(@"error: Range or index out of bounds");
    }else {
        [self alert_replaceCharactersInRange:range withString:aString];
    }
}

- (id)replace_objectForKeyedSubscript:(NSString *)key {
    return nil;
}

@end
