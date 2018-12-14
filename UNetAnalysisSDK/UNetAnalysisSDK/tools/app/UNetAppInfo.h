//
//  UNetAppInfo.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/10.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNetAppInfo : NSObject
+ (NSString *)uGetAppName;
+ (NSString *)uGetAppBundleId;
+ (NSString *)uGetAppVersion;
+ (NSString *)uIosVersion;
+ (NSString *)uScreenResolution;
+ (NSString*)uDeviceModelName;
+ (NSString*)uGetNetworkType;
@end
