//
//  UCIpPingResult.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCIpPingResult : NSObject
@property (nonatomic,readonly) NSString *ip;
@property (nonatomic,readonly) int    loss;     // average loss
@property (nonatomic,readonly) int  delay;    // average delay

- (instancetype)initUIpPingResultWithIp:(NSString *)ip loss:(int)loss delay:(float)delay;
@end
