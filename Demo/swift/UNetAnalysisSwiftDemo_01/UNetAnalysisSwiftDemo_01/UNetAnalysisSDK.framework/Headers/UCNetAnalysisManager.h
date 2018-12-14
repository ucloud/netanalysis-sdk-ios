//
//  UCNetAnalysisManager.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/9.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCManualNetDiagResult.h"

/* Define SDK debug log level */
typedef enum UCNetSDKLogLevel
{
    UCNetSDKLogLevel_FATAL = 0,
    UCNetSDKLogLevel_ERROR,
    UCNetSDKLogLevel_WARN,
    UCNetSDKLogLevel_INFO,
    UCNetSDKLogLevel_DEBUG
}UCNetSDKLogLevel;

typedef void(^UCNetRegisterSdkCompleteHandler)(NSError *_Nullable error);
typedef void(^UCNetManualNetDiagCompleteHandler)(UCManualNetDiagResult *_Nullable manualNetDiagRes);

/* for sdk demo */
typedef void(^UNetPingResultHandler)(NSString *_Nullable pingres);
typedef void(^UNetTracerouteResultHandler)(NSString *_Nullable tracertRes ,NSString *_Nullable destIp);

@interface UCNetAnalysisManager : NSObject


#pragma mark - init & regist method
/*!
 @discussion
 Init a UCNetAnalysisManager instance.
 
 @return a UCNetAnalysisManager instance.
 */
+ (instancetype)shareInstance;

/*!
 @discussion
 The first time the app is initialized after installation, the app connects to a UCloud Server
 through the  internet to verify the Application Key.
 
 @param completeHandler a block used for notification user the registration result
 */
- (void)uNetRegistUNetAnalysisSdkWithCompleteHandler:(UCNetRegisterSdkCompleteHandler _Nonnull )completeHandler;

#pragma mark - public setting api
/*!
 @discussion
 setting SDK debug log level.  The default is UCNetSDKLogLevel_ERROR
 
 @param logLevel sdk log level
 */
- (void)uNetSettingSDKLogLevel:(UCNetSDKLogLevel)logLevel;

/*!
 Setting ip list . Set up your own sevice IP list , which is used to detect network connectivity.
 
 @param customerIpList the ip list
 */
- (void)uNetSettingCustomerIpList:(NSArray *_Nullable)customerIpList;


/*!
 @discussion
 Manual network diagnostics
 
 @param completeHandler net work diagnostics results
 */
- (void)uNetManualDiagNetStatus:(UCNetManualNetDiagCompleteHandler _Nonnull)completeHandler;


#pragma mark - interface for SDK Demo

/*!
 @description
 setting is auto collection the device network status or not
 
 @param isClose  YES: close auto collection ;  NO: open auto collection ;   the default is open auto collection
 */
- (void)uNetSettingIsCloseAutoAnalysisNet:(BOOL)isClose;


/*!
 @description
 Get current automatic network analysis function is available

 @return YES ： is available;  NO: unavailable
 */
- (BOOL)uNetAutoAnalysisNetIsAvailable;

/*！
 @description
 ping function

 @param host ip address or domain name
 @param handler ping detail information
 */
- (void)uNetStartPing:(NSString *_Nonnull)host pingResultHandler:(UNetPingResultHandler _Nonnull)handler;

/*!
 @description

 @param host ip address or domain name
 @param handler traceroute detail information
 */
- (void)uNetStartTraceroute:(NSString *_Nonnull)host tracerouteResultHandler:(UNetTracerouteResultHandler _Nonnull)handler;
@end
