//
//  UCTraceRoute.h
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCNetDiagnosisHelper.h"
#import "UTracertModel.h"

const int kTracertRouteCount_noRes               = 5;     // 连续无响应的route个数
const int kTracertMaxTTL                         = 32;    // Max 32 hops（最多32跳）
const int kTracertSendIcmpPacketTimes            = 3;     // 对一个中间节点，发送3个icmp包
const int kIcmpPacketTimeoutTime                 = 330;   // ICMP包超时时间(ms)

@class UCTraceRoute;
@protocol UCTraceRouteDelegate<NSObject>
- (void)tracerouteWithUCTraceRoute:(UCTraceRoute *)ucTraceRoute tracertResult:(UCTracerRouteResModel *)tracertRes;
- (void)tracerouteFinishedWithUCTraceRoute:(UCTraceRoute *)ucTraceRoute;
@optional


@end

@interface UCTraceRoute : NSObject
@property (nonatomic,strong) id<UCTraceRouteDelegate> delegate;

- (void)startTracerouteHosts:(NSArray *)hostlist;

- (void)stopTracert;
- (BOOL)isTracert;
@end
