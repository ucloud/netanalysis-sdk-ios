//
//  UPingResModel.h
//  PingDemo
//
//  Created by ethan on 31/07/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UCloudPingStatus) {
    UCloudPingStatusDidStart,
    UCloudPingStatusDidFailToSendPacket,
    UCloudPingStatusDidReceivePacket,
    UCloudPingStatusDidReceiveUnexpectedPacket,
    UCloudPingStatusDidTimeout,
    UCloudPingStatusError,
    UCloudPingStatusFinished,
};

@interface UPingResModel : NSObject

@property(nonatomic) NSString *originalAddress;
@property(nonatomic, copy) NSString *IPAddress;
@property(nonatomic) NSUInteger dateBytesLength;
@property(nonatomic) double     timeMilliseconds;
@property(nonatomic) NSInteger  timeToLive;
@property(nonatomic) NSInteger   tracertCount;
@property(nonatomic) NSInteger  ICMPSequence;
@property(nonatomic) UCloudPingStatus status;

+ (NSDictionary *)pingResultWithPingItems:(NSArray *)pingItems;

@end
