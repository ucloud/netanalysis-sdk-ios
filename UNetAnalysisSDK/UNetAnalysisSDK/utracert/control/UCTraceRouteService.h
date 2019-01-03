//
//  UCTraceRouteService.h
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCTraceRoute.h"
#import "UTracertModel.h"

@class UCTraceRouteService;
@protocol UCTraceRouteServiceDelegate <NSObject>

@optional
- (void)tracerouteResultWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService tracerouteResult:(UReportTracertModel *)uReportTracertModel;
- (void)tracerouteFinishedWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService;

@end

@interface UCTraceRouteService : NSObject

@property (nonatomic,strong) id<UCTraceRouteServiceDelegate> delegate;


+ (instancetype)shareInstance;

/*!
 @discussion
 Start traceroute a set of host addresses
 
 @param addressList host addresses
 */
- (void)uStartTracerouteAddressList:(NSArray *)addressList;

- (void)uStopTracert;
- (BOOL)uIsTracert;
@end
