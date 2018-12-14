//
//  UCDeviceInfo.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCDeviceInfo.h"
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
