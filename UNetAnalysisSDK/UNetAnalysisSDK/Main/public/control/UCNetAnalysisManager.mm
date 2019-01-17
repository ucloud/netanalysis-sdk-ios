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

- (void)uNetSettingSDKLogLevel:(UCSDKLogLevel)logLevel
{
    [[UCNetAnalysis shareInstance] settingSDKLogLevel:logLevel];
}

+ (BOOL)validRegistParamsWithAppKey:(NSString *)appkey
                        publicToken:(NSString * _Nonnull)publickToken
                     optReportField:(NSString * _Nullable)optField
            completeHandler:(UCNetRegisterSdkCompleteHandler _Nonnull)completeHandler
{
    if (!completeHandler) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"no UCNetRegisterSdkCompleteHandler"
                                     userInfo:nil];
        return NO;
    }
    NSString *errorInfo = nil;
    if ([UNetTools un_isEmpty:appkey]) {
        errorInfo = @"no APPKEY";
    }else if(![UNetTools validAppkey:appkey]){
        errorInfo = @"APPKEY error";
    }
    else if ([UNetTools un_isEmpty:publickToken]) {
        errorInfo = @"no PUBLIC TOKEN";
    }else if(![UNetTools validRSAPublicKey:publickToken]){
        errorInfo = @"PUBLICK TOKEN error";
    }
    else if([UNetTools validOptReportField:optField]){
        errorInfo = [UNetTools validOptReportField:optField];
    }
    if (errorInfo) {
        log4cplus_warn("UNetSDK", "regist sdk error , error info->%s",[errorInfo UTF8String]);
        completeHandler([UCError sysErrorWithInvalidArgument:errorInfo]);
        return NO;
    }
    return YES;
    
}

- (void)uNetRegistSdkWithAppKey:(NSString * _Nonnull)appkey
                    publicToken:(NSString * _Nonnull)publickToken
                 optReportField:(NSString * _Nullable)optField
                completeHandler:(UCNetRegisterSdkCompleteHandler _Nonnull)completeHandler
{
    if (![UCNetAnalysisManager validRegistParamsWithAppKey:appkey publicToken:publickToken optReportField:optField completeHandler:completeHandler]) {
        return;
    }
    int res = [[UCNetAnalysis shareInstance] registSdkWithAppKey:appkey publicToken:publickToken optReportField:optField];
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
