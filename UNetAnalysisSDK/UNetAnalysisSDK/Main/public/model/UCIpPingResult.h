//
//  UCIpPingResult.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `NSObject`的子类。 该类定义的是对IP地址诊断(`ping`)的结果，具体包括：目的ip，平均丢包率，平均延迟
 */
@interface UCIpPingResult : NSObject

/**
 @brief 目的ip
 */
@property (nonatomic,readonly) NSString *ip;

/**
 @brief 平均丢包率
 */
@property (nonatomic,readonly) int    loss;

/**
 @brief 平均延迟，单位是毫秒
 */
@property (nonatomic,readonly) int  delay;

- (instancetype)initUIpPingResultWithIp:(NSString *)ip loss:(int)loss delay:(float)delay;
@end
