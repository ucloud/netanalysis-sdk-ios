//
//  UCNetClient.h
//  UNetAnalysisSDK
//
//  Created by ethan on 26/07/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,UCTriggerDetectType)
{
    UCTriggerDetectType_Auto,
    UCTriggerDetectType_Manual
};


@interface UCNetClient : NSObject

+ (instancetype _Nonnull)shareInstance;
- (int)registSdkWithAppKey:(NSString * _Nonnull)appkey
               publicToken:(NSString * _Nonnull)publicToken;
- (void)startDetect;
- (void)settingCustomerIpList:(NSArray *_Nullable)customerIpList;
- (void)settingUserDefineJsonFields:(NSString * _Nullable)fields;
- (void)closePingAndTracert;
- (void)closeAutoDetech;
@end
