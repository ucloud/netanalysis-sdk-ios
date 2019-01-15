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


/**
 这是`NSObject`的一个子类。 该类包含手动诊断网络的结果，例如: app信息，手机信息，app网络信息等。
 */
@interface UCManualNetDiagResult : NSObject

/**
 @brief 应用信息
 @discussion 例如： app版本，app名称，app的bundleID 等
 */
@property (nonatomic,strong) UCAppInfo       *appInfo;

/**
 @brief 手机信息
 @discussion 例如： 设备型号，操作系统版本
 */
@property (nonatomic,strong) UCDeviceInfo    *deviceInfo;

/**
 @brief 应用网络信息
 @discussion 应用的网络信息， 例如： 网络类型，公网IP等
 */
@property (nonatomic,strong) UCAppNetInfo    *appNetInfo;         // The app net info. eg: net type,public ip,etc..

/**
 @brief 用户服务地址诊断结果
 @discussion 对用户设置的服务地址列表的ping的结果。详情可查看 `UCIpPingResult`
 */
@property (nonatomic,strong) NSMutableArray<UCIpPingResult *> *pingInfo;

@end



/**
 `NSObject`的子类。该类定义的是用户自定义上报的字段。
 */
@interface UCOptReportField : NSObject

/**
 @brief 上报字段对应的key(规则：长度最大为20且不能包含半角逗号和等号)
 */
@property (nonatomic,strong) NSString *key;

/**
 @brief 上报字段的key所对应的内容(规则：长度最大为90且不能包含半角逗号和等号)
 */
@property (nonatomic,strong) NSString *value;

/**
 @brief 实例化上报字段.
 
 @discussion 该字段是用户自定义的上报字段，SDK把尊重用户隐私看为重中之重，所以请务必不要上传带有用户隐私的信息，包括但不局限于：用户姓名，手机号，
 身份证号等用户个人信息以及设备的`device id`等设备唯一id信息。除此之外还要注意上报字段的命名规则(key&value命名规则)：
 
 * key: 长度最大为20
 * value: 长度最大为90
 * 两者都不能包含半角逗号和等号

 @param key 上报字段对应的key，最大长度为20且不能包含半角逗号和等号
 @param value 报字段的key所对应的内容，最大长度为90且不能包含半角逗号和等号
 @return 上报字段实例
 */
+ (instancetype)instanceWithKey:(NSString *)key andValue:(NSString *)value;


/**
 @brief 校验`UCOptReportField`对象(内部使用)

 @param field `UCOptReportField`对象
 @return 如果内容非法，则返回非法信息；如果内容合法，则返回空
 */
+ (NSString *)validOptReportField:(UCOptReportField *)field;

/**
 @brief 转化为key:value 格式的字符串 (内部使用)

 @return key:value 字符串
 */
- (NSString *)convertToKeyValueStr;

@end


NS_ASSUME_NONNULL_END
