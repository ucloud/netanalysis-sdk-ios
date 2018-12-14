//
//  UCAppNetInfo.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCAppNetInfo.h"


@implementation UCAppNetInfo

- (instancetype)initUAppNetInfoWithPublicIp:(NSString *)publicIp networkType:(NSString *)type
{
    if (self = [super init]) {
        _publicIp = publicIp;
        _networkType = type;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"publicIp:%@, networkType:%@",_publicIp,_networkType];
}

@end
