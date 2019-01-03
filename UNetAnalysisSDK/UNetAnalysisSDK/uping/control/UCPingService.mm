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
@property (nonatomic,strong) dispatch_queue_t serialQueue;
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

- (dispatch_queue_t)serialQueue
{
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("sq_pingres",
                                             DISPATCH_QUEUE_SERIAL);
    }
    return _serialQueue;
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
    
    dispatch_async(self.serialQueue, ^{
        NSMutableArray *pingItems = [self.pingResDic objectForKey:host];
        if (pingItems == NULL) {
            pingItems = [NSMutableArray arrayWithArray:@[pingItem]];
        }else{

            try {
                [pingItems addObject:pingItem];
            } catch (NSException *exception) {
                log4cplus_error("UNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
            }
        }
        
        try {
            [self.pingResDic setObject:pingItems forKey:host];
            //        NSLog(@"%@",self.pingResDic);
        } catch (NSException *exception) {
            log4cplus_error("UNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
        }
        
        if (pingItem.status == UCloudPingStatusFinished) {
            NSArray *pingItems = [self.pingResDic objectForKey:host];
            NSDictionary *dict = [UPingResModel pingResultWithPingItems:pingItems];
//            NSLog(@"dict----res:%@, pingRes:%@",dict,self.pingResDic);
            UReportPingModel *reportPingModel = [UReportPingModel uReporterPingmodelWithDict:dict];
            
            [self.delegate pingResultWithUCPingService:self pingResult:reportPingModel];
//            NSLog(@"%@",reportPingModel);
            
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
        [self.pingResDic removeObjectForKey:host];
    });
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

- (void)pingResultWithUCPing:(UCPing *)ucPing pingResult:(UPingResModel *)pingRes pingStatus:(UCloudPingStatus)status
{
    @try {
        [self addPingResToPingResContainer:pingRes andHost:pingRes.IPAddress];
    } @catch (NSException *exception) {
         log4cplus_error("UNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
}


@end
