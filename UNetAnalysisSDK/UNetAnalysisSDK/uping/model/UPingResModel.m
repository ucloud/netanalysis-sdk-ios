//
//  UPingResModel.m
//  PingDemo
//
//  Created by ethan on 31/07/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UPingResModel.h"

@implementation UPingResModel

- (NSString *)description {
    return [NSString stringWithFormat:@"ICMPSequence:%d , originalAddress:%@ , IPAddress:%@ , dateBytesLength:%d , timeMilliseconds:%@ , timeToLive:%d , tracertCount:%d , status：%d",(int)_ICMPSequence,_originalAddress,_IPAddress,(int)_dateBytesLength,[NSString stringWithFormat:@"%.3fms",_timeMilliseconds],(int)_timeToLive,(int)_tracertCount,(int)_status];
}

+ (NSDictionary *)pingResultWithPingItems:(NSArray *)pingItems
{
    
    NSString *address = [pingItems.firstObject originalAddress];
    NSString *dst     = [pingItems.firstObject IPAddress];
    __block NSInteger receivedCount = 0, allCount = 0;
    __block NSInteger ttlSum = 0;
    __block double    timeSum = 0;
    [pingItems enumerateObjectsUsingBlock:^(UPingResModel *obj, NSUInteger idx, BOOL *stop) {
        if (obj.status != UCloudPingStatusFinished && obj.status != UCloudPingStatusError) {
            allCount ++;
            if (obj.status == UCloudPingStatusDidReceivePacket) {
                receivedCount ++;
                ttlSum += obj.timeToLive;
                timeSum += obj.timeMilliseconds;
            }
        }
    }];
    
    float lossPercent = (allCount - receivedCount) / MAX(1.0, allCount) * 100;
    double avgTime = 0; NSInteger avgTTL = 0;
    if (receivedCount > 0) {
        avgTime = timeSum/receivedCount;
        avgTTL = ttlSum/receivedCount;
    }else{
        avgTime = 0;
        avgTTL = 0;
    }
    //        NSLog(@"address:%@ ,loss:%f,ttl:%ld, time:%f",address,lossPercent,avgTTL,avgTime);
    
    if (address == NULL) {
        address = @"null";
    }
    
    NSDictionary *dict = NULL;
    @try {
        dict = @{@"src_ip":address,@"dst_ip":dst, @"loss":[NSNumber numberWithFloat:lossPercent],@"delay":[NSNumber  numberWithDouble:avgTime],@"ttl":[NSNumber numberWithLong:avgTTL]};
    } @catch (NSException *exception) {
        NSLog(@"%s, %@",__func__,exception.description);
    }
    
    return dict;
}
@end
