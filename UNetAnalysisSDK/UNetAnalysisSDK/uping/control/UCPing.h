//
//  UCPing.h
//  PingDemo
//
//  Created by ethan on 03/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPingModel.h"
#import "UCNetDiagnosisHelper.h"

@class UCPing;

@protocol UCPingDelegate  <NSObject>

@optional
- (void)pingFinishedWithUCPing:(UCPing *)ucPing;
- (void)pingResultWithUCPing:(UCPing *)ucPing pingResult:(UPingResModel *)pingRes pingStatus:(UCloudPingStatus)status;


@end

@interface UCPing : NSObject

@property (nonatomic,strong) id<UCPingDelegate> delegate;

- (void)startPingHosts:(NSArray *)hostlist;

- (void)stopPing;
- (BOOL)isPing;
@end
