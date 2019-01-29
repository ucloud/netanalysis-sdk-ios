//
//  UCNetAnalysisManager.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/9.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCModel.h"


/**
 @brief 这是一个枚举类型，定义日志级别
 
 @discussion 建议开发的时候，把SDK的日志级别设置为`UCSDKLogLevel_DEBUG`,这样便于开发调试。等上线时再把级别改为较高级别的`UCSDKLogLevel_ERROR`

 - UCSDKLogLevel_FATAL: FATAL级别
 - UCSDKLogLevel_ERROR: ERROR级别（如果不设置，默认是该级别）
 - UCSDKLogLevel_WARN:  WARN级别
 - UCSDKLogLevel_INFO:  INFO级别
 - UCSDKLogLevel_DEBUG: DEBUG级别
 */
typedef NS_ENUM(NSUInteger,UCSDKLogLevel)
{
    UCSDKLogLevel_FATAL,
    UCSDKLogLevel_ERROR,
    UCSDKLogLevel_WARN,
    UCSDKLogLevel_INFO,
    UCSDKLogLevel_DEBUG
};

/**
 @brief 注册SDK的block
 @discussion 该block用于告知用户是否注册结果。`ucError`为空则注册成功； 反之注册失败。
 */
typedef void(^UCNetRegisterSdkCompleteHandler)(UCError *_Nullable ucError);

/**
 @brief 手动诊断网络状况的block
 @discussion 该block用于告知用户网络诊断的结果，包含设备信息，网络信息，应用信息等。详见 `UCManualNetDiagResult`
 */
typedef void(^UCNetManualNetDiagCompleteHandler)(UCManualNetDiagResult *_Nullable manualNetDiagRes,UCError *_Nullable ucError);


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
 @brief 注册 `SDK`,如果`completeHandler`参数为空，则会抛出异常。
 @discussion 你应该在应用最初启动的地方调用此方法。 因为应用安装后第一次初始化应用程序时，应用将连接到 `UCloud` 服务器验证你的 `APP KEY` 。
 
 关于`optField`用户可选上报字段的规则：SDK把尊重用户隐私看为重中之重，所以请务必不要上传带有用户隐私的信息，包括但不局限于：用户姓名，手机号，
 身份证号等用户个人信息以及设备的`device id`等设备唯一id信息。除此之外上报字段还有以下内容校验规则：1.长度最大为100； 2.不能包含半角逗号和等号。

 @param appkey 使用该网络数据分析SDK时`UCloud`会分配给你一个appkey
 @param publickToken 公钥，用于数据传输加密
 @param optField 用户可选择上报的字段(请特别注意该字段的命名规则)。如果没有，则设置为`nil`
 @param completeHandler 一个 `UCNetRegisterSdkCompleteHandler` 类型的 `block`，通过这个 `block` 来告知用户是否注册成功 `SDK`.  如果成功，则 `error` 为空。
 */
- (void)uNetRegistSdkWithAppKey:(NSString * _Nonnull)appkey
                    publicToken:(NSString * _Nonnull)publickToken
                 optReportField:(NSString * _Nullable)optField
                completeHandler:(UCNetRegisterSdkCompleteHandler _Nonnull)completeHandler;

#pragma mark - public setting api
/**
 @brief 设置日志级别
 @discussion  如果不设置，默认的日志级别是 `UCSDKLogLevel_ERROR`
 @param logLevel 日志级别，类型是一个枚举 `UCSDKLogLevel`
 */
- (void)uNetSettingSDKLogLevel:(UCSDKLogLevel)logLevel;

/**
 @brief 设置用户的服务IP地址列表
 @discussion 这个方法用来设置你想探测的服务的地址，它最好是你应用中的服务地址，当然也可以是其它对你有用的IP地址。
 这些ip地址不仅仅被用于网络分析，`SDK`中的手动诊断功能，诊断的就是这些IP地址。
 @param customerIpList 应用服务IP列表
 */
- (void)uNetSettingCustomerIpList:(NSArray *_Nullable)customerIpList;


/**
 @brief 手动诊断网络状况功能，如果`completeHandler`参数为空，则会抛出异常。
 @discussion 当手机网络不好时，使用此功能可以获取你设置的服务IP列表的网络情况(ping结果)，还有其它相关信息等。详情请查阅 `UCManualNetDiagResult`
 @param completeHandler 一个 `UCNetManualNetDiagCompleteHandler`类型的block，该block用于接收网络诊断结果。
 */
- (void)uNetManualDiagNetStatus:(UCNetManualNetDiagCompleteHandler _Nonnull)completeHandler;


/**
 @brief 获取SDK的版本号

 @return SDK版本号
 */
- (NSString * _Nonnull)uNetSdkVersion;

@end
