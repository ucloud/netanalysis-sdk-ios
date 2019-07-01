//
//  UCTraceRouteService.m
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCTraceRouteService.h"
#import "UNetAnalysisConst.h"
#include "log4cplus.h"

@interface UCTraceRouteService()<UCTraceRouteDelegate>
@property (nonatomic,strong) UCTraceRoute *ucTraceroute;
@property (nonatomic,strong) NSMutableDictionary *tracerouteResDict;
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

+ (instancetype)shareInstance
{
    if (!ucTraceRouteService_instance) {
        ucTraceRouteService_instance = [[UCTraceRouteService alloc] init];
    }
    return ucTraceRouteService_instance;
}

- (void)uStopTracert
{
    [self.ucTraceroute stopTracert];
    if (_ucTraceroute) {
        _ucTraceroute = nil;
    }
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
    if (_tracerouteResDict) {
        _tracerouteResDict = nil;
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
            int    recCount = kTracertSendIcmpPacketTimes;
            if (tracertResModel.ip) {
                routeIp = tracertResModel.ip;
                
                int validToute = 0;
                for (int m = 0; m < kTracertSendIcmpPacketTimes; m++) {
                    validToute++;
                    avgDelay += tracertResModel.durations[m] *1000;
                    if (tracertResModel.durations[m] == 0) {
                        validToute--;
                        recCount--;
                    }
                }
                if (validToute) {
                    avgDelay = avgDelay/validToute;
                }
            }else{
                recCount = 0;
            }
            float lossPercent = (kTracertSendIcmpPacketTimes - recCount)/MAX(1.0, kTracertSendIcmpPacketTimes) * 100;
            URouteReplyModel *routeReplay = [URouteReplyModel uRouteReplayModelWithDict:@{@"route_ip":routeIp, @"avgDelay":[NSNumber numberWithFloat:avgDelay],@"loss":[NSNumber numberWithInt:(int)lossPercent]}];
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
    
    @try {
        NSMutableArray *tracertItems = [self.tracerouteResDict objectForKey:host];
        if (tracertItems == NULL) {
            tracertItems = [NSMutableArray arrayWithArray:@[tracertRes]];
        }else{
            [tracertItems addObject:tracertRes];
        }
        [self.tracerouteResDict setObject:tracertItems forKey:host];
        //        NSLog(@"%@",self.tracerouteResDict);
        
        if (tracertRes.status == UCTracertStatus_Finish) {
            UReportTracertModel *reportTracertModel = [self constructTracertReportModelUseTracertRes:tracertRes andHost:host];
            reportTracertModel.beginTime = tracertRes.beginTime;
            [self.delegate tracerouteResultWithUCTraceRouteService:self tracerouteResult:reportTracertModel];
            //            NSLog(@"%@",reportTracertModel);
            [self removePingResFromPingResContainerWithHostName:host];
        }
    } @catch (NSException *exception) {
        log4cplus_error("UNetTracert", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);

    }
    
}

- (void)removePingResFromPingResContainerWithHostName:(NSString *)host
{
    if (host == NULL) {
        return;
    }
    [self.tracerouteResDict removeObjectForKey:host];
}

#pragma mark -UCTraceRouteDelegate
- (void)tracerouteWithUCTraceRoute:(UCTraceRoute *)ucTraceRoute tracertResult:(UCTracerRouteResModel *)tracertRes
{
    [self addTracerouteResModelToTracerouteResContainer:tracertRes andHost:tracertRes.dstIp];
}

- (void)tracerouteFinishedWithUCTraceRoute:(UCTraceRoute *)ucTraceRoute
{
    [self.delegate tracerouteFinishedWithUCTraceRouteService:self];
}

@end
