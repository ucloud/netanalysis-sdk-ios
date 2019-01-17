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

@property (nonatomic,assign) NSInteger beginTime;


+ (instancetype)uReporterPingmodelWithDict:(NSDictionary *)dict;
- (NSDictionary *)objConvertToReportDict;
@end



typedef NS_ENUM(NSInteger, UCPingStatus) {
    UCPingStatus_Start,
    UCPingStatus_FailSendPacket,
    UCPingStatus_ReceivePacket,
    UCPingStatus_ReceiveUnexpectedPacket,
    UCPingStatus_Timeout,
    UCPingStatus_Error,
    UCPingStatus_Finish,
};

@interface UPingResModel : NSObject

@property(nonatomic) NSString *originalAddress;
@property(nonatomic, copy) NSString *IPAddress;
@property(nonatomic) NSUInteger dateBytesLength;
@property(nonatomic) double     timeMilliseconds;
@property(nonatomic) NSInteger  timeToLive;
@property(nonatomic) NSInteger   tracertCount;
@property(nonatomic) NSInteger  ICMPSequence;
@property(nonatomic) UCPingStatus status;

@property (nonatomic,assign) NSInteger beginTime; // record start ping timestamp

+ (NSDictionary *)pingResultWithPingItems:(NSArray *)pingItems;

@end

NS_ASSUME_NONNULL_END
