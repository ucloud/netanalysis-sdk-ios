//
//  UCNetAnalysisManager.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/9.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCNetAnalysisManager.h"
#import "UCNetAnalysis.h"

@implementation UCNetAnalysisManager

static UCNetAnalysisManager *sdkManager_instance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t ucloudNetAnalysis_onceToken;
    dispatch_once(&ucloudNetAnalysis_onceToken, ^{
        sdkManager_instance = [[super allocWithZone:NULL] init];
    });
    return sdkManager_instance;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [UCNetAnalysisManager shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [UCNetAnalysisManager shareInstance];
}

- (void)uNetSettingSDKLogLevel:(UCNetSDKLogLevel)logLevel
{
    [[UCNetAnalysis shareInstance] settingSDKLogLevel:logLevel];
}


- (void)uNetRegistUNetAnalysisSdkWithCompleteHandler:(UCNetRegisterSdkCompleteHandler _Nonnull )completeHandler
{
    int res = [[UCNetAnalysis shareInstance] registUNetAnalysisSdk];
    if (res == 0) {
        completeHandler(nil);
    }
}

- (void)uNetSettingCustomerIpList:(NSArray *_Nullable)customerIpList
{
    [[UCNetAnalysis shareInstance] settingCustomerIpList:customerIpList];
}

- (void)uNetManualDiagNetStatus:(UCNetManualNetDiagCompleteHandler _Nonnull)completeHandler
{
    [[UCNetAnalysis shareInstance] manualDiagNetStatus:completeHandler];
    
}

#pragma mark - interface for SDK Demo
- (void)uNetSettingIsCloseAutoAnalysisNet:(BOOL)isClose;
{
    [[UCNetAnalysis shareInstance] settingIsCloseAutoAnalysisNet:isClose];
}

- (BOOL)uNetAutoAnalysisNetIsAvailable
{
    return [[UCNetAnalysis shareInstance] autoAnalysisNetIsAvailable];
}

- (void)uNetStartPing:(NSString *)host pingResultHandler:(UNetPingResultHandler _Nonnull)handler
{
    [[UCNetAnalysis shareInstance] startPing:host pingResultHandler:handler];
}

- (void)uNetStartTraceroute:(NSString *_Nonnull)host tracerouteResultHandler:(UNetTracerouteResultHandler _Nonnull)handler
{
    [[UCNetAnalysis shareInstance] startTraceroute:host tracerouteResultHadler:handler];
}

@end
