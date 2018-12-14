//
//  UCAppNetInfo.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

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
