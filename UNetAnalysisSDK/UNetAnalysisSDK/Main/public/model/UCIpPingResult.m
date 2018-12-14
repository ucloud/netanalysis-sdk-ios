//
//  UCIpPingResult.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCIpPingResult.h"

@implementation UCIpPingResult

- (instancetype)initUIpPingResultWithIp:(NSString *)ip loss:(int)loss delay:(float)delay
{
    if (self = [super init]) {
        _ip = ip;
        _loss = loss;
        _delay = delay;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ip:%@, loss:%d, delay:%d",_ip,_loss,_delay];
}
@end
