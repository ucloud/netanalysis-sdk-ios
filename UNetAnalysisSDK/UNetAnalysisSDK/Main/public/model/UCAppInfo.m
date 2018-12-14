//
//  UCAppInfo.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCAppInfo.h"
#import "UNetAppInfo.h"

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
