//
//  UPingModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UPingModel.h"

@implementation UReportPingModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.loss  = [dict[@"loss"] intValue];
        self.delay = [dict[@"delay"] floatValue];
        self.ttl   = [dict[@"ttl"] intValue];
        self.src_ip = dict[@"src_ip"];
        self.dst_ip = dict[@"dst_ip"];
    }
    return self;
}

+ (instancetype)uReporterPingmodelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    return @{@"loss":@(self.loss),@"delay":@((int)self.delay),@"src_ip":self.src_ip,@"dst_ip":self.dst_ip,@"TTL":@(self.ttl)};
}

- (NSDictionary *)objConvertToReportDict
{
    return @{@"delay":@((int)self.delay),@"loss":@(self.loss)};
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"src_ip:%@ , dst_ip:%@ , loss:%d , delay:%@ , ttl:%d ",self.src_ip,self.dst_ip,self.loss,[NSString stringWithFormat:@"%.3fms",self.delay],self.ttl];
}

@end




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
