//
//  UCModel.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The network type is NO NETWORK .
 */
extern NSString *const U_NO_NETWORK;

/**
 *  The network type is WIFI .
 */
extern NSString *const U_WIFI;

/**
 *  The network type is GPRS .
 */
extern NSString *const U_GPRS;

/**
 *  The network type is 2G .
 */
extern NSString *const U_2G;

/**
 *  The network type is 2.75G EDGE .
 */
extern NSString *const U_2_75G_EDGE;

/**
 *  The network type is 3G .
 */
extern NSString *const U_3G;

/**
 *  The network type is 3.5G HSDPA .
 */
extern NSString *const U_3_5G_HSDPA;

/**
 *  The network type is 3.5G HSUPA .
 */
extern NSString *const U_3_5G_HSUPA;

/**
 *  The network type is HRPD .
 */
extern NSString *const U_HRPD;

/**
 *  The network type is 4G .
 */
extern NSString *const U_4G;


/**
 `NSObject`的子类。 该类定义的是对IP地址诊断(`ping`)的结果，具体包括：目的ip，平均丢包率，平均延迟
 */
@interface UCIpPingResult : NSObject

/**
 @brief 目的ip
 */
@property (nonatomic,readonly) NSString *ip;

/**
 @brief 平均丢包率
 */
@property (nonatomic,readonly) int    loss;

/**
 @brief 平均延迟，单位是毫秒
 */
@property (nonatomic,readonly) int  delay;

- (instancetype)initUIpPingResultWithIp:(NSString *)ip loss:(int)loss delay:(float)delay;
@end


/**
 这是`NSObject`的一个子类。 该类包含手动诊断网络的结果，例如: app信息，手机信息，app网络信息等。
 */
@interface UCManualNetDiagResult : NSObject

/**
 @brief 手机网络类型
 */
@property (nonatomic,readonly) NSString *networkType;

/**
 @brief 用户服务地址诊断结果
 @discussion 对用户设置的服务地址列表的ping的结果。详情可查看 `UCIpPingResult`
 */
@property (nonatomic,readonly) NSMutableArray<UCIpPingResult *> *pingInfo;


/**
 @brief 实例化手动诊断结果(内部使用)

 @param pingRes 对用户设置的ip列表ping的结果
 @return 手动诊断结果实例
 */
+ (instancetype)instanceWithPingRes:(NSMutableArray *)pingRes;

@end


/**
  @brief 这是一个枚举定义，定义SDK错误类型

 - UCErrorType_Sys: 非服务器错误，包括参数错误，逻辑业务错误等，可通过错误的具体描述获知错误原因
 - UCErrorType_Server: 服务器错误，可通过错误的具体描述获取错误原因
 */
typedef NS_ENUM(NSUInteger,UCErrorType)
{
    UCErrorType_Sys,
    UCErrorType_Server
};

@interface UCError : NSObject

/**
 *  错误类型，请参考`UCErrorType`
 */
@property (nonatomic,readonly)  UCErrorType type;

/**
 *  系统错误信息
 */
@property (nonatomic,readonly)  NSError     *error;

/**
 @brief 构造错误(参数错误，内部使用)
 
 @param desc 错误信息
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidArgument:(NSString *)desc;

/**
 @brief 构造错误(容器中的元素非法，内部使用)
 
 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidElements:(NSString *)desc;

/**
 @brief 构造错误(调用SDK中的方法时，条件不满足。内部使用)
 
 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidCondition:(NSString *)desc;

/**
 构造错误
 
 @param error 系统错误实例(内部使用)
 @return 错误实例
 */
+ (instancetype)sysErrorWithError:(NSError *)error;


@end


NS_ASSUME_NONNULL_END
