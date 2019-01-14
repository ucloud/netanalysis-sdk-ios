//
//  UCNetAnalysis.h
//  UNetAnalysisSDK
//
//  Created by ethan on 26/07/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCNetAnalysisManager.h"


@interface UCNetAnalysis : NSObject

+ (instancetype _Nonnull)shareInstance;
- (int)registSdkWithAppKey:(NSString * _Nonnull)appkey
               publicToken:(NSString * _Nonnull)publicToken
           optReportField:(UCOptReportField * _Nullable)field;
- (void)settingSDKLogLevel:(UCNetSDKLogLevel)logLevel;
- (void)settingCustomerIpList:(NSArray *_Nullable)customerIpList;
- (void)manualDiagNetStatus:(UCNetManualNetDiagCompleteHandler _Nonnull)completeHandler;
@end
