//
//  UCModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCModel.h"
#import "UNetAppInfo.h"

@implementation UCDeviceInfo

- (instancetype)init
{
    if (self = [super init]) {
        _osVersion = [UNetAppInfo uIosVersion];
        _screenResolution = [UNetAppInfo uScreenResolution];
        _deviceModelName = [UNetAppInfo uDeviceModelName];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"osVersion:%@, screenResolution:%@, deviceModel:%@",_osVersion,_screenResolution,_deviceModelName];
}
@end


@implementation UCAppInfo

- (instancetype)init
{
    if (self = [super init]) {
        _appName = [UNetAppInfo uGetAppName];
        _appBundleId = [UNetAppInfo uGetAppBundleId];
        _appVersion = [UNetAppInfo uGetAppVersion];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"appName:%@, bundleId:%@, appVersion:%@",_appName,_appBundleId,_appVersion];
}


@end


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




