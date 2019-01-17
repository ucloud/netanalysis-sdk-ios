//
//  UNetQueue.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/1/22.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "UNetQueue.h"

@interface UNetQueue()
+ (instancetype)shareInstance;

@property (nonatomic) dispatch_queue_t pingQueue;
@property (nonatomic) dispatch_queue_t traceQueue;

@end

@implementation UNetQueue

+ (instancetype)shareInstance
{
    static UNetQueue *unetQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unetQueue = [[self alloc] init];
    });
    return unetQueue;
}

- (instancetype)init
{
    if (self = [super init]) {
        _pingQueue = dispatch_queue_create("unet_ping_queue", DISPATCH_QUEUE_SERIAL);
        _traceQueue = dispatch_queue_create("unet_trace_queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (void)unet_ping_sync:(dispatch_block_t)block
{
    dispatch_async([UNetQueue shareInstance].pingQueue, ^{
        block();
    });
}

+ (void)unet_trace_async:(dispatch_block_t)block
{
    dispatch_async([UNetQueue shareInstance].traceQueue , ^{
        block();
    });
}
@end
