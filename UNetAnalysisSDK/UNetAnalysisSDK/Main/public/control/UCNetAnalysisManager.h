//
//  UCNetAnalysisManager.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/9.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCManualNetDiagResult.h"


/**
 @brief 这是一个枚举类型，定义日志级别
 */
typedef enum UCNetSDKLogLevel
{
    /**
     * FATAL 级别
     */
    UCNetSDKLogLevel_FATAL = 0,
    /**
     * ERROR 级别
     */
    UCNetSDKLogLevel_ERROR,
    /**
     * WARN 级别
     */
    UCNetSDKLogLevel_WARN,
    /**
     * INFO 级别
     */
    UCNetSDKLogLevel_INFO,
    /**
     * DEBUG 级别
     */
    UCNetSDKLogLevel_DEBUG
}UCNetSDKLogLevel;

/**
 @brief 注册SDK的block
 @discussion 该block用于告知用户是否注册结果。`error`为空则注册成功； 反之注册失败。
 */
typedef void(^UCNetRegisterSdkCompleteHandler)(NSError *_Nullable error);

/**
 @brief 手动诊断网络状况的block
 @discussion 该block用于告知用户网络诊断的结果，包含设备信息，网络信息，应用信息等。详见 `UCManualNetDiagResult`
 */
typedef void(^UCNetManualNetDiagCompleteHandler)(UCManualNetDiagResult *_Nullable manualNetDiagRes);

/* for sdk demo */
typedef void(^UNetPingResultHandler)(NSString *_Nullable pingres);
typedef void(^UNetTracerouteResultHandler)(NSString *_Nullable tracertRes ,NSString *_Nullable destIp);


/**
这是 `NSObject` 的一个子类。 它是`UNetAnalysisSDK`的主要操作类，在这个类中定义了SDK的主要操作。
 
你可以利用这个类来完成该SDK所提供的主要功能，具体如下:
 
* 设置SDK的日志级别
* 注册SDK
* 设置你的应用服务地址列表
* 手动诊断网络状况
 
 */
@interface UCNetAnalysisManager : NSObject

/**
 @brief 创建一个 `UCNetAnalysisManager` 实例
 @return 返回一个 `UCNetAnalysisManager` 实例
 */
+ (instancetype _Nonnull )shareInstance;

/**
 @brief 注册 `SDK`
 @discussion 你应该在应用最初启动的地方调用此方法。 因为应用安装后第一次初始化应用程序时，应用将连接到 `UCloud` 服务器验证你的 `APP KEY`
 @param completeHandler 一个 `UCNetRegisterSdkCompleteHandler` 类型的 `block`，通过这个 `block` 来告知用户是否注册成功 `SDK`.  如果成功，则 `error` 为空。
 */
- (void)uNetRegistUNetAnalysisSdkWithCompleteHandler:(UCNetRegisterSdkCompleteHandler _Nonnull )completeHandler;

#pragma mark - public setting api
/**
 @brief 设置日志级别
 @discussion  如果不设置，默认的日志级别是 `UCNetSDKLogLevel_ERROR`
 @param logLevel 日志级别，类型是一个枚举 `UCNetSDKLogLevel`
 */
- (void)uNetSettingSDKLogLevel:(UCNetSDKLogLevel)logLevel;

/**
 @brief 设置用户的服务IP地址列表
 @discussion 这个方法用来设置你想探测的服务的地址，它最好是你应用中的服务地址，当然也可以是其它对你有用的IP地址。
 这些ip地址不仅仅被用于网络分析，`SDK`中的手动诊断功能，诊断的就是这些IP地址。
 @param customerIpList 应用服务IP列表
 */
- (void)uNetSettingCustomerIpList:(NSArray *_Nullable)customerIpList;


/**
 @brief 手动诊断网络状况功能
 @discussion 当手机网络不好时，使用此功能可以获取你设置的服务IP列表的网络情况(ping结果)，还有其它相关信息等。详情请查阅 `UCManualNetDiagResult`
 @param completeHandler 一个 `UCNetManualNetDiagCompleteHandler`类型的block，该block用于接收网络诊断结果。
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
