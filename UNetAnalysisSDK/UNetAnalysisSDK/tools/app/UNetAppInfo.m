//
//  UNetAppInfo.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/10.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UNetAppInfo.h"
#import "UCReachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h>

@implementation UNetAppInfo

+ (NSString *)uGetAppBundleId
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)uIosVersion
{
    return [UIDevice currentDevice].systemVersion;
}

@end
