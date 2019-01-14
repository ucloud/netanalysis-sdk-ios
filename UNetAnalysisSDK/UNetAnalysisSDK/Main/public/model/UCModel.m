//
//  UCModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCModel.h"
#import "UNetAppInfo.h"
#import "UNetTools.h"
#import <objc/runtime.h>


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

@implementation UCManualNetDiagResult

@end


@implementation UCOptReportField

- (instancetype)initWithKey:(NSString *)key andValue:(NSString *)value
{
    if (self = [super init]) {
        _key = key;
        _value = value;
    }
    return self;
}

+ (instancetype)instanceWithKey:(NSString *)key andValue:(NSString *)value
{
    return [[self alloc] initWithKey:key andValue:value];
}

+ (NSString *)validOptReportField:(UCOptReportField *)field
{
    if ([[self class] validElement:field.key elementName:@"key"]) {
        return [[self class] validElement:field.key elementName:@"key"];
    }
    if ([[self class] validElement:field.value elementName:@"value"]) {
        return [[self class] validElement:field.value elementName:@"value"];
    }
    return nil;
}

+ (NSString *)validElement:(NSString *)element elementName:(NSString *)name
{
    int eleLength = 90;
    if ([name isEqualToString:@"key"]) {
        eleLength = 20;
    }
    if ([UNetTools un_isEmpty:element] ) {
        return [NSString stringWithFormat:@"%@ 非法(不能为空或空串)",name];
    }
    if (element.length > eleLength || [element containsString:@","] || [element containsString:@"，"] || [element containsString:@"="]) {
        return [NSString stringWithFormat:@"%@ 非法(长度最大为%d且不能包含半角逗号和等号)",name,eleLength];
    }
    return nil;
}


- (NSString *)convertToKeyValueStr
{
    return [NSString stringWithFormat:@"%@=%@",self.key,self.value];
}
@end



