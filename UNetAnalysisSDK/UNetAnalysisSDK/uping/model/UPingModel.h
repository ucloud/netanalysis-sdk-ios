//
//  UPingModel.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UReportPingModel : NSObject

@property (nonatomic,assign) int loss;
@property (nonatomic,assign) float delay;
@property (nonatomic,assign) int ttl;
@property (nonatomic,copy)   NSString *src_ip;
@property (nonatomic,copy)   NSString *dst_ip;


+ (instancetype)uReporterPingmodelWithDict:(NSDictionary *)dict;
- (NSDictionary *)objConvertToReportDict;
@end



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

NS_ASSUME_NONNULL_END
