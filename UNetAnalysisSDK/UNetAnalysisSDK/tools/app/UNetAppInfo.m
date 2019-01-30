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

NSString * const U_NO_NETWORK   = @"NO NETWORK";
NSString * const U_WIFI         = @"WIFI";
NSString * const U_GPRS         = @"GPRS";
NSString * const U_2G           = @"2G";
NSString * const U_2_75G_EDGE   = @"2.75G EDGE";
NSString * const U_3G           = @"3G";
NSString * const U_3_5G_HSDPA   = @"3.5G HSDPA";
NSString * const U_3_5G_HSUPA   = @"3.5G HSUPA";
NSString * const U_HRPD         = @"HRPD";
NSString * const U_4G           = @"4G";


@implementation UNetAppInfo

+ (NSString *)uGetAppName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)uGetAppBundleId
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)uGetAppVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)uIosVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)uScreenResolution
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenRect.size;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenX = screenSize.width*scale;
    CGFloat screenY = screenSize.height*scale;
    
    return [NSString stringWithFormat:@"%d * %d",(int)screenX,(int)screenY];
}

+ (NSString*)uDeviceModelName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7 (CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7 (GSM)";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus (CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus (GSM)";
    
    if ([deviceModel isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    
    if ([deviceModel isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])    return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,4"])    return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,6"])    return @"iPhone XS Max";
    
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    //iPod
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    //iPad
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,11"])     return @"iPad Pro 9.7 5Gen";
    if ([deviceModel isEqualToString:@"iPad6,12"])     return @"iPad Pro 9.7 5Gen";
    if ([deviceModel isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9 2Gen";
    if ([deviceModel isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9 2Gen";
    if ([deviceModel isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5";
    if ([deviceModel isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5";
    
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceModel isEqualToString:@"iPad4,4"]
        ||[deviceModel isEqualToString:@"iPad4,5"]
        ||[deviceModel isEqualToString:@"iPad4,6"])      return @"iPad mini 2";
    
    if ([deviceModel isEqualToString:@"iPad4,7"]
        ||[deviceModel isEqualToString:@"iPad4,8"]
        ||[deviceModel isEqualToString:@"iPad4,9"])      return @"iPad mini 3";
    
    if ([deviceModel isEqualToString:@"iPad5,1"] || [deviceModel isEqualToString:@"iPad5,2"])      return @"iPad mini 4";
    
    return deviceModel;
}

+ (NSString*)uGetNetworkType
{
    NSString *netType = @"";
    UCReachability *reachNet = [UCReachability reachabilityWithHostName:@"www.apple.com"];
    UCNetworkStatus net_status = [reachNet currentReachabilityStatus];
    switch (net_status) {
        case Reachable_None:
            netType = U_NO_NETWORK;
            break;
        case Reachable_WiFi:
            netType = U_WIFI;
            break;
        case Reachable_WWAN:
        {
            CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
            NSString *curreNetType = netInfo.currentRadioAccessTechnology;
            if ([curreNetType isEqualToString:CTRadioAccessTechnologyGPRS]) {
                netType = U_GPRS;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyEdge]){
                netType = U_2_75G_EDGE;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyWCDMA] ||
                     [curreNetType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                     [curreNetType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                     [curreNetType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
                netType = U_3G;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyHSDPA]){
                netType = U_3_5G_HSDPA;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyHSUPA]){
                netType = U_3_5G_HSUPA;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyeHRPD]){
                netType = U_HRPD;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyLTE]){
                netType = U_4G;
            }
        }
            break;
            
        default:
            break;
    }
    
    return netType;
}

@end
