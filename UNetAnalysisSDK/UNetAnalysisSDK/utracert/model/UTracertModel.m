//
//  UTracertModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UTracertModel.h"

@implementation UCTracerRouteResModel
- (instancetype)init:(NSInteger)hop
               count:(NSInteger)count {
    if (self = [super init]) {
        _ip = nil;
        _hop = hop;
        _durations = (NSTimeInterval*)calloc(count, sizeof(NSTimeInterval));
        _count = count;
        _status = Enum_Traceroute_Status_doing;
    }
    return self;
}

- (NSString*)description {
    NSMutableString *mutableStr = [NSMutableString string];
    for (int i = 0; i < _count; i++) {
        if (_durations[i] <= 0) {
            [mutableStr appendString:@"* "];
        }else{
            [mutableStr appendString:[NSString stringWithFormat:@" %.3fms",_durations[i] * 1000]];
        }
    }
    return [NSString stringWithFormat:@"seq:%d , dstIp:%@, routeIp:%@, durations:%@ , status:%d",(int)_hop,_dstIp,_ip,mutableStr,(int)_status];
}


- (void)dealloc {
    free(_durations);
}
@end


@implementation UReportTracertModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.src_ip = dict[@"src_ip"];
        self.dst_ip = dict[@"dst_ip"];
        self.routeReplyArray = dict[@"routeReplyArray"];
    }
    return self;
}

+ (instancetype)uReportTracertModel:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.routeReplyArray.count; i++) {
        URouteReplyModel *model = (URouteReplyModel*)self.routeReplyArray[i];
        @try {
            [array addObject:model.objConvertToDict];
        } @catch (NSException *exception) {
            NSLog(@"%s, %@",__func__,exception.description);
        }
        
    }
    
    return @{@"src_ip":self.src_ip,@"dst_ip":self.dst_ip,@"route_info":array};
}

- (NSDictionary *)objConvertToReportDict
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.routeReplyArray.count; i++) {
        URouteReplyModel *model = (URouteReplyModel*)self.routeReplyArray[i];
        @try {
            [array addObject:model.objConvertToDict];
        } @catch (NSException *exception) {
            NSLog(@"%s, %@",__func__,exception.description);
        }
        
    }
    return @{@"route_info":array};
}

- (NSString *)description
{
    NSMutableString *routeReplay = [NSMutableString string];
    for (int i = 0; i < self.routeReplyArray.count; i++) {
        URouteReplyModel *model = (URouteReplyModel*)self.routeReplyArray[i];
        [routeReplay appendString:model.description];
        [routeReplay appendString:@"\n"];
    }
    return [NSString stringWithFormat:@"src_ip:%@ , dst_ip:%@ , routeReplyArray:\n %@",self.src_ip,self.dst_ip,routeReplay];
}

@end



@implementation URouteReplyModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super  init]) {
        self.route_ip = dict[@"route_ip"];
        self.avgDelay = [dict[@"avgDelay"] floatValue];
    }
    return self;
}

+ (instancetype)uRouteReplayModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    NSDictionary *dict  = NULL;
    @try {
        dict  = @{@"route_ip":self.route_ip,@"delay":@((int)self.avgDelay)};
    } @catch (NSException *exception) {
        NSLog(@"%s,%@",__func__,exception.description);
    }
    return dict;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"route_ip:%@ , avgDelay:%@",self.route_ip,[NSString stringWithFormat:@"%.3fms",self.avgDelay]];
}
@end


@implementation UCTracertUCHostsRecord

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _currentDays = [dict[@"currentDays"] intValue];
        _currentTracertIp = dict[@"currentTracertIp"];
        _tracertUCHostsState = (Enum_Tracert_UC_Hosts_State)[dict[@"tracertUCHostsState"] intValue];
    }
    return self;
}

+ (instancetype)ucTracertUCHostsRecordWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInt:self.currentDays] forKey:@"currentDays"];
    [aCoder encodeObject:self.currentTracertIp forKey:@"currentTracertIp"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.tracertUCHostsState] forKey:@"tracertUCHostsState"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.currentDays = [[aDecoder decodeObjectForKey:@"currentDays"] intValue];
        self.currentTracertIp = [aDecoder decodeObjectForKey:@"currentTracertIp"];
        self.tracertUCHostsState = (Enum_Tracert_UC_Hosts_State)[[aDecoder decodeObjectForKey:@"tracertUCHostsState"] intValue];
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"currentDays:%d , currentTracertIp:%@ , tracertUCHostsState:%d",self.currentDays,self.currentTracertIp,(Enum_Tracert_UC_Hosts_State)self.tracertUCHostsState];
}

@end


