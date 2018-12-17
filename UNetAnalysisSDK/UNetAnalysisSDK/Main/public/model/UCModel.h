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
 `NSObject`的子类。 该类定义的是设备信息，具体包括： 操作系统版本，屏幕分辨率，设备型号
 */
@interface UCDeviceInfo : NSObject

/**
 @brief 操作系统版本
 */
@property (nonatomic,readonly) NSString *osVersion;

/**
 @brief 屏幕分辨率
 */
@property (nonatomic,readonly) NSString *screenResolution;

/**
 @brief 设备型号
 */
@property (nonatomic,readonly) NSString *deviceModelName;
@end


/**
 `NSObject`的子类。 该类定义的是APP信息，具体包括： app名称，app的bundleID，app版本
 */
@interface UCAppInfo : NSObject

/**
 @brief app名称
 */
@property (nonatomic,readonly) NSString *appName;

/**
 @brief app的bundleID
 */
@property (nonatomic,readonly) NSString *appBundleId;

/**
 @brief app版本
 */
@property (nonatomic,readonly) NSString *appVersion;
@end


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
 `NSObject`的子类。 该类定义的是APP网络信息，具体包括： 手机公网IP，网络类型
 */
@interface UCAppNetInfo : NSObject

/**
 @brief 手机公网IP
 */
@property (nonatomic,readonly) NSString *publicIp;

/**
 @brief 手机网络类型
 */
@property (nonatomic,readonly) NSString *networkType;

- (instancetype)initUAppNetInfoWithPublicIp:(NSString *)publicIp networkType:(NSString *)type;
@end


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

NS_ASSUME_NONNULL_END
