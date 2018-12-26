//
//  UCTraceRouteService.m
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCTraceRouteService.h"

@interface UCTraceRouteService()<UCTraceRouteDelegate>
@property (nonatomic,strong) UCTraceRoute *ucTraceroute;
@property (nonatomic,strong) NSMutableDictionary *tracerouteResDict;
@property (nonatomic,strong) dispatch_queue_t serialQueue;
@end

@implementation UCTraceRouteService

static UCTraceRouteService *ucTraceRouteService_instance = NULL;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSMutableDictionary *)tracerouteResDict
{
    if (!_tracerouteResDict) {
        _tracerouteResDict = [NSMutableDictionary dictionary];
    }
    return _tracerouteResDict;
}

- (dispatch_queue_t)serialQueue
{
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("tracertResBoxSq",
                                             DISPATCH_QUEUE_SERIAL);
    }
    return _serialQueue;
}

+ (instancetype)shareInstance
{
    if (ucTraceRouteService_instance == NULL) {
        ucTraceRouteService_instance = [[UCTraceRouteService alloc] init];
    }
    return ucTraceRouteService_instance;
}

- (void)uStopTracert
{
    [self.ucTraceroute stopTracert];
}

- (BOOL)uIsTracert
{
    return [self.ucTraceroute isTracert];
}

- (void)uStartTracerouteAddressList:(NSArray *)addressList
{
    if (_ucTraceroute) {
        _ucTraceroute = nil;
    }
    _ucTraceroute = [[UCTraceRoute alloc] init];
    _ucTraceroute.delegate = self;
    [_ucTraceroute startTracerouteHosts:addressList];
}

- (UReportTracertModel *)constructTracertReportModelUseTracertRes:(UCTracerRouteResModel *)tracertRes andHost:(NSString *)host
{
        NSArray *tracertItems = [self.tracerouteResDict objectForKey:host];
        NSMutableArray *routeReplayArray = [NSMutableArray array];
        
        int kCount = tracertRes.ip== NULL ? (int)tracertItems.count-1 : (int)tracertItems.count;
        
        for (int i = 0; i < kCount; i++) {
            UCTracerRouteResModel *tracertResModel = (UCTracerRouteResModel *)tracertItems[i];
            NSString *routeIp = @"*";
            float  avgDelay = 0;
            if (tracertResModel.ip) {
                routeIp = tracertResModel.ip;
                
                for (int m = 0; m < kTracertSendIcmpPacketTimes; m++) {
                    avgDelay += tracertResModel.durations[m] *1000;
                }
                avgDelay = avgDelay/kTracertSendIcmpPacketTimes;
            }
            
            URouteReplyModel *routeReplay = [URouteReplyModel uRouteReplayModelWithDict:@{@"route_ip":routeIp, @"avgDelay":[NSNumber numberWithFloat:avgDelay]}];
            [routeReplayArray addObject:routeReplay];
        }
        
        UReportTracertModel *reportTracertModel = [UReportTracertModel uReportTracertModel:@{@"src_ip":@"device ip",@"dst_ip":host,@"routeReplyArray":routeReplayArray}];
        return reportTracertModel;
}

- (void)addTracerouteResModelToTracerouteResContainer:(UCTracerRouteResModel *)tracertRes andHost:(NSString *)host
{
    if (host == NULL || tracertRes == NULL) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        NSMutableArray *tracertItems = [self.tracerouteResDict objectForKey:host];
        if (tracertItems == NULL) {
            tracertItems = [NSMutableArray arrayWithArray:@[tracertRes]];
        }else{
            [tracertItems addObject:tracertRes];
        }
        [self.tracerouteResDict setObject:tracertItems forKey:host];
//        NSLog(@"%@",self.tracerouteResDict);
        
        if (tracertRes.status == Enum_Traceroute_Status_finish) {
            UReportTracertModel *reportTracertModel = [self constructTracertReportModelUseTracertRes:tracertRes andHost:host];
            [self.delegate tracerouteResultWithUCTraceRouteService:self tracerouteResult:reportTracertModel];
//            NSLog(@"%@",reportTracertModel);
            
            [self removePingResFromPingResContainerWithHostName:host];
            
            
        }
        
    });
}

- (void)removePingResFromPingResContainerWithHostName:(NSString *)host
{
    if (host == NULL) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        [self.tracerouteResDict removeObjectForKey:host];
    });
}

#pragma mark -UCTraceRouteDelegate
- (void)tracerouteWithUCTraceRoute:(UCTraceRoute *)ucTraceRoute tracertResult:(UCTracerRouteResModel *)tracertRes
{
    [self addTracerouteResModelToTracerouteResContainer:tracertRes andHost:tracertRes.dstIp];
    [self.delegate tracerouteDetailWithUCTraceRouteService:self tracertResModel:tracertRes];
}

- (void)tracerouteFinishedWithUCTraceRoute:(UCTraceRoute *)ucTraceRoute
{
    [self.delegate tracerouteFinishedWithUCTraceRouteService:self];
}

@end
