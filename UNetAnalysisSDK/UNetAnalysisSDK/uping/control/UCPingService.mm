//
//  UCPingService.m
//  PingDemo
//
//  Created by ethan on 06/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCPingService.h"
#import "UNetAnalysisConst.h"
#include "log4cplus.h"

@interface UCPingService()<UCPingDelegate>
@property (nonatomic,strong) UCPing *uPing;
@property (nonatomic,strong) NSMutableDictionary *pingResDic;

@end

@implementation UCPingService

static UCPingService *ucPingservice_instance = NULL;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSMutableDictionary *)pingResDic
{
    if (!_pingResDic) {
        _pingResDic = [NSMutableDictionary dictionary];
    }
    return _pingResDic;
}

+ (instancetype)shareInstance
{
    if (ucPingservice_instance == NULL) {
        ucPingservice_instance = [[UCPingService alloc] init];
    }
    return ucPingservice_instance;
}

- (void)uStopPing
{
    [self.uPing stopPing];
    if (_uPing) {
        _uPing = nil;
    }
}

- (BOOL)uIsPing
{
    return [self.uPing isPing];
}

- (void)addPingResToPingResContainer:(UPingResModel *)pingItem andHost:(NSString *)host
{
    if (host == NULL || pingItem == NULL) {
        return;
    }
    
    @try {
        NSMutableArray *pingItems = [self.pingResDic objectForKey:host];
        if (pingItems == NULL) {
            pingItems = [NSMutableArray arrayWithArray:@[pingItem]];
        }else{
            [pingItems addObject:pingItem];
        }
        [self.pingResDic setObject:pingItems forKey:host];
        if (pingItem.status == UCPingStatus_Finish) {
            NSArray *pingItems = [self.pingResDic objectForKey:host];
            NSDictionary *dict = [UPingResModel pingResultWithPingItems:pingItems];
            //            NSLog(@"dict----res:%@, pingRes:%@",dict,self.pingResDic);
            UReportPingModel *reportPingModel = [UReportPingModel uReporterPingmodelWithDict:dict];
            
            [self.delegate pingResultWithUCPingService:self pingResult:reportPingModel];
            //            NSLog(@"%@",reportPingModel);
            [self removePingResFromPingResContainerWithHostName:host];
        }
    } @catch (NSException *exception) {
        log4cplus_error("UNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
    
}

- (void)removePingResFromPingResContainerWithHostName:(NSString *)host
{
    if (host == NULL) {
        return;
    }
    [self.pingResDic removeObjectForKey:host];
}

- (void)startPingAddressList:(NSArray *)addressList
{
    if (_uPing) {
        _uPing = nil;
        _uPing = [[UCPing alloc] init];

    }else{
        _uPing = [[UCPing alloc] init];
    }
    _uPing.delegate = self;
    [_uPing startPingHosts:addressList];
    
}

#pragma mark-UCPingDelegate
- (void)pingFinishedWithUCPing:(UCPing *)ucPing
{
    [self.delegate pingFinishedWithUCPingService:self];
}

- (void)pingResultWithUCPing:(UCPing *)ucPing pingResult:(UPingResModel *)pingRes pingStatus:(UCPingStatus)status
{
    [self addPingResToPingResContainer:pingRes andHost:pingRes.IPAddress];
}


@end
