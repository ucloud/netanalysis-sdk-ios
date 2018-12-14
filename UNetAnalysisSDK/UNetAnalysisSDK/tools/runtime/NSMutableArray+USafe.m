//
//  NSMutableArray+USafe.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/29.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "NSMutableArray+USafe.h"
#import <objc/runtime.h>
#import "NSObject+USafe.h"

#pragma mark - NSArray

@interface NSArray (XTSafe)

@end

@implementation NSArray (XTSafe)

+ (Method)methodOfSelector:(SEL)selector
{
    return class_getInstanceMethod(NSClassFromString(@"__NSArrayI"),selector);
}

- (id)xt_objectAtIndexI:(NSUInteger)index
{
    if (index >= self.count)
    {
//        NSLog(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
//                NSStringFromClass([self class]),
//                NSStringFromSelector(_cmd),
//                (unsigned long)index,
//                MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
    
    return [self xt_objectAtIndexI:index];
}

+ (id)xt_arrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    id validObjects[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        if (objects[i])
        {
            validObjects[count] = objects[i];
            count++;
        }
        else
        {
//            NSLog(@"[%@ %@] NIL object at index {%lu}",
//                    NSStringFromClass([self class]),
//                    NSStringFromSelector(_cmd),
//                    (unsigned long)i);
            
        }
    }
    
    return [self xt_arrayWithObjects:validObjects count:count];
}

@end

#pragma mark - NSMutableArray

@implementation NSMutableArray(USafe)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(removeObject:)
         withSwizzledSelector:@selector(hdf_safeRemoveObject:)];
        
        [objc_getClass("__NSArrayM") swizzleSelector:@selector(addObject:)
                                withSwizzledSelector:@selector(hdf_safeAddObject:)];
        [objc_getClass("__NSArrayM") swizzleSelector:@selector(removeObjectAtIndex:)
                                withSwizzledSelector:@selector(hdf_safeRemoveObjectAtIndex:)];
        
        [objc_getClass("__NSArrayM") swizzleSelector:@selector(insertObject:atIndex:)
                                withSwizzledSelector:@selector(hdf_insertObject:atIndex:)];
        
        [objc_getClass("__NSPlaceholderArray") swizzleSelector:@selector(initWithObjects:count:) withSwizzledSelector:@selector(hdf_initWithObjects:count:)];
        
        [objc_getClass("__NSArrayM") swizzleSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(hdf_objectAtIndex:)];
    });
}

- (instancetype)hdf_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
    BOOL hasNilObject = NO;
    for (NSUInteger i = 0; i < cnt; i++) {
        if ([objects[i] isKindOfClass:[NSArray class]]) {
//            NSLog(@"%@", objects[i]);
        }
        if (objects[i] == nil) {
            hasNilObject = YES;
//            NSLog(@"%s object at index %lu is nil, it will be filtered", __FUNCTION__, i);
            
            #if DEBUG
            
                  NSString *errorMsg = [NSString stringWithFormat:@"数组元素不能为nil，其index为: %lu", i];
                  NSAssert(objects[i] != nil, errorMsg);
            #endif
        }
    }
    
    // 因为有值为nil的元素，那么我们可以过滤掉值为nil的元素
    if (hasNilObject) {
        id __unsafe_unretained newObjects[cnt];
        
        NSUInteger index = 0;
        for (NSUInteger i = 0; i < cnt; ++i) {
            if (objects[i] != nil) {
                newObjects[index++] = objects[i];
            }
        }
        
        return [self hdf_initWithObjects:newObjects count:index];
    }
    
    return [self hdf_initWithObjects:objects count:cnt];
}


- (void)hdf_safeAddObject:(id)obj {
    if (obj == nil) {
//        NSLog(@"%s can add nil object into NSMutableArray", __FUNCTION__);
    } else {
        [self hdf_safeAddObject:obj];
    }
}

- (void)hdf_safeRemoveObject:(id)obj {
    if (obj == nil) {
//        NSLog(@"%s call -removeObject:, but argument obj is nil", __FUNCTION__);
        return;
    }
    
    [self hdf_safeRemoveObject:obj];
}

- (void)hdf_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject == nil) {
//        NSLog(@"%s can't insert nil into NSMutableArray", __FUNCTION__);
    } else if (index > self.count) {
//        NSLog(@"%s index is invalid", __FUNCTION__);
    } else {
        [self hdf_insertObject:anObject atIndex:index];
    }
}

- (id)hdf_objectAtIndex:(NSUInteger)index {
    if (self.count == 0) {
//        NSLog(@"%s can't get any object from an empty array", __FUNCTION__);
        return nil;
    }
    
    if (index > self.count) {
//        NSLog(@"%s index out of bounds in array", __FUNCTION__);
        return nil;
    }
    
    return [self hdf_objectAtIndex:index];
}

- (void)hdf_safeRemoveObjectAtIndex:(NSUInteger)index {
    if (self.count <= 0) {
//        NSLog(@"%s can't get any object from an empty array", __FUNCTION__);
        return;
    }
    
    if (index >= self.count) {
//        NSLog(@"%s index out of bound", __FUNCTION__);
        return;
    }
    
    [self hdf_safeRemoveObjectAtIndex:index];
}

@end
