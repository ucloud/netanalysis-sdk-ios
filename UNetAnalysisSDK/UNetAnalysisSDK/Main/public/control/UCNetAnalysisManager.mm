//
//  UCNetAnalysisManager.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/9.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCNetAnalysisManager.h"
#import "UNetAnalysisConst.h"
#import "UCNetAnalysis.h"
#import "UNetTools.h"
#import "log4cplus.h"



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

- (void)uNetRegistSdkWithAppKey:(NSString * _Nonnull)appkey
                    publicToken:(NSString * _Nonnull)publickToken
                completeHandler:(UCNetRegisterSdkCompleteHandler _Nonnull)completeHandler
{
    if (!completeHandler) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"no UCNetRegisterSdkCompleteHandler"
                                     userInfo:nil];
        return;
    }
    NSString *errorInfo = nil;
    if ([UNetTools un_isEmpty:appkey]) {
        errorInfo = @"no APPKEY";
    }
    else if ([UNetTools un_isEmpty:publickToken]) {
        errorInfo = @"no PUBLIC TOKEN";
    }
//    else if(optReportField && [UCOptReportField validOptReportField:optReportField] ){
//        errorInfo = [UCOptReportField validOptReportField:optReportField];
//    }
    if (errorInfo) {
        log4cplus_warn("UNetSDK", "regist sdk error , error info->%s",[errorInfo UTF8String]);
        completeHandler([UCError sysErrorWithInvalidArgument:errorInfo]);
        return;
    }
    int res = [[UCNetAnalysis shareInstance] registSdkWithAppKey:appkey publicToken:publickToken optReportField:nil];
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
    if (completeHandler == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"no UCNetManualNetDiagCompleteHandler"
                                     userInfo:nil];
        return;
    }
    [[UCNetAnalysis shareInstance] manualDiagNetStatus:completeHandler];
}

@end
