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
        _status = UCTracertStatus_Doing;
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

//- (NSDictionary *)objConvertToReportDict
//{
//    NSMutableArray *array = [NSMutableArray array];
//    for (int i = 0; i < self.routeReplyArray.count; i++) {
//        URouteReplyModel *model = (URouteReplyModel*)self.routeReplyArray[i];
//        @try {
//            [array addObject:model.objConvertToDict];
//        } @catch (NSException *exception) {
//            NSLog(@"%s, %@",__func__,exception.description);
//        }
//
//    }
//    return @{@"route_info":array};
//}

- (NSDictionary *)objConvertToReportDict
{
    NSMutableArray *array_delay = [NSMutableArray array];
    NSMutableArray *array_loss = [NSMutableArray array];
    NSMutableArray *array_route = [NSMutableArray array];
    for (int i = 0; i < self.routeReplyArray.count; i++) {
        URouteReplyModel *model = (URouteReplyModel*)self.routeReplyArray[i];
        @try {
            [array_route addObject:model.route_ip];
            [array_delay addObject:[NSNumber numberWithInt:(int)(model.avgDelay)]];
            [array_loss addObject:[NSNumber numberWithInt:model.loss]];
        } @catch (NSException *exception) {
            NSLog(@"%s, %@",__func__,exception.description);
        }
    }
    return @{@"route_list":array_route,@"delay_list":array_delay,@"loss_list":array_loss};
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
        self.loss = [dict[@"loss"] intValue];
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
        dict  = @{@"route_ip":self.route_ip,@"delay":@((int)self.avgDelay),@"loss":@(self.loss)};
    } @catch (NSException *exception) {
        NSLog(@"%s,%@",__func__,exception.description);
    }
    return dict;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"route_ip:%@ , avgDelay:%@ , loss:%@" ,self.route_ip,[NSString stringWithFormat:@"%.3fms",self.avgDelay],[NSString stringWithFormat:@"%d",self.loss]];
}
@end


