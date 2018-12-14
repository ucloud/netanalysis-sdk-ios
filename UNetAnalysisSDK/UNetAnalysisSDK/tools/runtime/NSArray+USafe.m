//
//  NSArray+USafe.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/29.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "NSArray+USafe.h"
#import <objc/runtime.h>
#import "NSObject+USafe.h"

@implementation NSArray (USafe)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("__NSArray0") swizzleSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(emptyObjectIndex:)];
            [objc_getClass("__NSArrayI") swizzleSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(arrObjectIndex:)];
            [objc_getClass("__NSArrayM") swizzleSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(mutableObjectIndex:)];
            [objc_getClass("__NSArrayM") swizzleSelector:@selector(insertObject:atIndex:) withSwizzledSelector:@selector(mutableInsertObject:atIndex:)];
            [objc_getClass("__NSArrayM") swizzleSelector:@selector(integerValue) withSwizzledSelector:@selector(replace_integerValue)];
        }
    });
}

- (id)emptyObjectIndex:(NSInteger)index{
    return nil;
}

- (id)arrObjectIndex:(NSInteger)index{
    if (index >= self.count || index < 0) {
        return nil;
    }
    return [self arrObjectIndex:index];
}

- (id)mutableObjectIndex:(NSInteger)index{
    if (index >= self.count || index < 0) {
        return nil;
    }
    return [self mutableObjectIndex:index];
}

- (void)mutableInsertObject:(id)object atIndex:(NSUInteger)index{
    if (object) {
        [self mutableInsertObject:object atIndex:index];
    }
}

- (NSInteger)replace_integerValue {
    return 0;
}

@end
