//
//  UCNetAnalysisManager.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/9.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCNetSDKDef.h"


/**
这是 `NSObject` 的一个子类。 它是`UNetAnalysisSDK`的主要操作类，在这个类中定义了SDK的主要操作。
 
你可以利用这个类来完成该SDK所提供的主要功能，具体如下:
 
* 设置SDK的日志级别
* 注册SDK
* 设置你的应用服务地址列表
 
 */
@interface UCNetAnalysisManager : NSObject


/**
 @brief 创建一个`UCNetAnalysisManager`单例对象

 @return <#return value description#>
 */
+ (instancetype _Nullable )shareInstance;


/**
 @brief 触发网络监测
 
 @discussion sdk会检测手机网络变化并触发网络检测。你也可以调用此方法来手动触发网络检测。
 */
- (void)uNetStartDetect;

/**
 @brief 注册 `SDK`,如果`completeHandler`参数为空，则会抛出异常。
 @discussion 你应该在应用最初启动的地方调用此方法。 因为应用安装后第一次初始化应用程序时，应用将连接到 `UCloud` 服务器验证你的 `APP KEY` 。
 
 @param appkey 使用该网络数据分析SDK时`UCloud`会分配给你一个appkey
 @param appSecret 公钥，用于数据传输加密
 @param completeHandler 一个 `UCNetErrorHandler` 类型的 `block`，通过这个 `block` 来告知用户是否注册成功 `SDK`.  如果成功，则 `error` 为空。
 */
- (void)uNetRegistSdkWithAppKey:(NSString * _Nonnull)appkey
                      appSecret:(NSString * _Nonnull)appSecret
                completeHandler:(UCNetErrorHandler _Nonnull)completeHandler;

#pragma mark - public setting api

/**
 @brief 关闭自动检测功能
 
 @discussion 如果你不想使用SDK的自动触发检测逻辑，那么你可以选择将其关闭。关闭自动触发检测逻辑后，需要你手动调用执行诊断功能才会触发网络检测。
 */
- (void)uNetCloseAutoDetectNet;

/**
 @brief 设置日志级别
 @discussion  如果不设置，默认的日志级别是 `UCSDKLogLevel_ERROR`
 @param logLevel 日志级别，类型是一个枚举 `UCSDKLogLevel`
 */
- (void)uNetSettingSDKLogLevel:(UCSDKLogLevel)logLevel;

/**
 @brief 设置自定义上报字段。
 @discussion 如果你要上报的字段在注册SDK之前能获取到，则需要在注册SDK之前调用此方法；如果你要上报的字段在注册SDK的时候还没有获取到，则可以在获取到该字段时调用此方法设置，但是前期SDK诊断的数据上报时可能不含有你设置的自定义字段。
 @param fields 用户自定义上报字段。如果没有直接传nil。该字段有长度限制，最后转化为字符串的总长度不能超过1024
 @param handler `UCNetErrorHandler` 类型的 `block`，通过这个 `block` 来告知用户是设置是否成功.  如果成功，则 `error` 为空。
 */
- (void)uNetSettingUserDefineFields:(NSDictionary<NSString*,NSString*> * _Nullable)fields
                            handler:(UCNetErrorHandler _Nonnull)handler;


/**
 @brief 设置用户的服务IP地址列表
 @discussion 这个方法用来设置你想探测的服务的地址，它最好是你应用中的服务地址，当然也可以是其它对你有用的IP地址。
 @param customerIpList 应用服务IP列表
 */
- (void)uNetSettingCustomerIpList:(NSArray *_Nullable)customerIpList;

/**
 @brief 停止网络数据收集
 @discussion 当app进入非活跃状态时，可以通过调用此方法来停止数据收集。用这种方法可以解决部分 `signal pipe` 引起的APP闪退
 */
- (void)uNetStopDataCollectionWhenAppWillResignActive;


#pragma mark - get sdk info api

/**
 @brief 获取SDK的版本号

 @return SDK版本号
 */
- (NSString * _Nonnull)uNetSdkVersion;

@end
