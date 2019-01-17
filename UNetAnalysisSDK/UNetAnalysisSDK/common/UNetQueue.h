//
//  UNetQueue.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/1/22.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UNetQueue : NSObject

+ (void)unet_ping_sync:(dispatch_block_t)block;
+ (void)unet_trace_async:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
