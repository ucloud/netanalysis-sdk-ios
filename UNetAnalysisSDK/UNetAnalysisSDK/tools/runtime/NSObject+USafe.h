//
//  NSObject+USafe.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/29.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (USafe)
+ (void)swizzleSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector;
@end
